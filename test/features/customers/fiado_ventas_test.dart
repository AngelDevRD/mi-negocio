import 'dart:convert';

import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/dashboard/data/datasources/dashboard_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fiado_fixture.dart';

void main() {
  late FiadoFixture f;

  setUp(() async {
    f = await FiadoFixture.crear();
    await f.abrirCaja();
  });

  tearDown(() async {
    await f.cerrar();
  });

  Future<int> montoActualDeCaja() async =>
      (await DashboardDao(f.db).watchCajaActual().first)!.montoActual.cents;

  Future<void> verificarNadaEscrito() async {
    expect(await f.cantidadEn('ventas'), 0);
    expect(await f.cantidadEn('venta_items'), 0);
    expect(await f.cantidadEn('venta_pagos'), 0);
    expect(await f.cantidadEn('movimientos_cliente'), 0);
    expect(await f.cantidadEn('caja_movimientos'), 0);
    expect(await f.cantidadEn('movimientos_inventario'), 0);
    expect(await f.stock(), 100);
  }

  void esperarFallo(
    Result<String> r, {
    required String contiene,
    String? regla,
  }) {
    r.when(
      ok: (_) => fail('debió fallar'),
      fail: (fallo) {
        expect(fallo.message, contains(contiene));
        if (regla != null) expect((fallo as BusinessRuleFailure).rule, regla);
      },
    );
  }

  test('venta a crédito: venta_pagos credito + cargo al cliente y NINGÚN '
      'movimiento de caja', () async {
    final id = await f.nuevoCliente();
    final antes = await montoActualDeCaja();

    final ventaId = (await f.vender(
      cantidad: 2,
      metodo: MetodoPago.credito,
      clienteId: id,
    )).valueOrNull!;

    final pagos = await f.db.select(f.db.ventaPagos).get();
    expect(pagos.single.metodo, MetodoPago.credito);
    expect(pagos.single.monto, 30000);

    final movs = await f.db.select(f.db.movimientosCliente).get();
    expect(movs, hasLength(1));
    expect(movs.single.tipo, TipoMovimientoCliente.cargo);
    expect(movs.single.monto, 30000);
    expect(movs.single.ventaId, ventaId);
    expect(movs.single.clienteId, id);

    expect(await f.cantidadEn('caja_movimientos'), 0);
    expect(await montoActualDeCaja(), antes);
    expect(await f.saldo(id), 30000);
    expect(await f.stock(), 98); // la venta sí descuenta stock
  });

  test('crédito SIN cliente falla y no escribe nada', () async {
    final r = await f.vender(metodo: MetodoPago.credito);

    expect(r.isOk, isFalse);
    r.when(
      ok: (_) {},
      fail: (fallo) => expect(fallo, isA<ValidationFailure>()),
    );
    await verificarNadaEscrito();
  });

  test('cliente inexistente o inactivo: falla sin escribir', () async {
    final inexistente = await f.vender(
      metodo: MetodoPago.credito,
      clienteId: 'no-existe',
    );
    expect(inexistente.isOk, isFalse);

    final id = await f.nuevoCliente();
    await f.clientes.establecerActivo(
      id: id,
      activo: false,
      usuarioId: f.usuarioId,
    );
    final inactivo = await f.vender(metodo: MetodoPago.credito, clienteId: id);
    esperarFallo(inactivo, contiene: 'inactivo');

    await verificarNadaEscrito();
  });

  test(
    'límite de crédito superado: BusinessRuleFailure y NADA escrito',
    () async {
      // Límite RD$ 400; la venta de 3 libras (RD$ 450) lo supera.
      final id = await f.nuevoCliente(limite: const Money(40000));

      final r = await f.vender(
        cantidad: 3,
        metodo: MetodoPago.credito,
        clienteId: id,
      );

      esperarFallo(
        r,
        contiene:
            'El fiado supera el límite de crédito de Doña Rosa: saldo '
            'RD\$ 0.00, límite RD\$ 400.00.',
        regla: 'FIADO-LIMITE',
      );
      await verificarNadaEscrito();
    },
  );

  test('el límite cuenta el saldo previo y JUSTO en el límite pasa', () async {
    final id = await f.nuevoCliente(limite: const Money(45000));
    expect(
      (await f.vender(
        cantidad: 2,
        metodo: MetodoPago.credito,
        clienteId: id,
      )).isOk,
      isTrue,
    ); // saldo 300
    // 1 libra más = 450 = exactamente el límite: pasa.
    expect(
      (await f.vender(
        cantidad: 1,
        metodo: MetodoPago.credito,
        clienteId: id,
      )).isOk,
      isTrue,
    );
    expect(await f.saldo(id), 45000);

    // Un centavo más ya no cabe.
    final r = await f.vender(
      cantidad: 0.01,
      metodo: MetodoPago.credito,
      clienteId: id,
    );
    esperarFallo(
      r,
      contiene: 'saldo RD\$ 450.00, límite RD\$ 450.00',
      regla: 'FIADO-LIMITE',
    );
    expect(await f.saldo(id), 45000);
  });

  test('sin límite (null) no hay tope', () async {
    final id = await f.nuevoCliente();

    final r = await f.vender(
      cantidad: 50,
      metodo: MetodoPago.credito,
      clienteId: id,
    );

    expect(r.isOk, isTrue);
    expect(await f.saldo(id), 750000);
  });

  test('anular una venta a crédito deja el saldo como antes y no toca la '
      'caja', () async {
    final id = await f.nuevoCliente();
    await f.vender(cantidad: 1, metodo: MetodoPago.credito, clienteId: id);
    final saldoAntes = await f.saldo(id); // 150
    final ventaId = (await f.vender(
      cantidad: 2,
      metodo: MetodoPago.credito,
      clienteId: id,
    )).valueOrNull!;
    expect(await f.saldo(id), saldoAntes + 30000);
    final cajaAntes = await montoActualDeCaja();

    final r = await f.ventas.anularVenta(ventaId, usuarioId: f.usuarioId);

    expect(r.isOk, isTrue);
    expect(await f.saldo(id), saldoAntes);
    final anulaciones = await (f.db.select(
      f.db.movimientosCliente,
    )..where((t) => t.tipo.equalsValue(TipoMovimientoCliente.anulacion))).get();
    expect(anulaciones, hasLength(1));
    expect(anulaciones.single.monto, -30000);
    expect(anulaciones.single.ventaId, ventaId);
    expect(await f.cantidadEn('caja_movimientos'), 0);
    expect(await montoActualDeCaja(), cajaAntes);
    expect(await f.stock(), 99); // el stock sí se revierte
  });

  test(
    'una venta en efectivo o tarjeta NO genera movimientos de cliente',
    () async {
      await f.vender(metodo: MetodoPago.efectivo);
      await f.vender(metodo: MetodoPago.tarjeta);

      expect(await f.cantidadEn('movimientos_cliente'), 0);
    },
  );

  test('el detalle muestra método crédito y el nombre del cliente', () async {
    final id = await f.nuevoCliente(nombre: 'Doña Rosa');
    final ventaId = (await f.vender(
      metodo: MetodoPago.credito,
      clienteId: id,
    )).valueOrNull!;

    final detalle = await f.ventas.obtenerVenta(ventaId);

    expect(detalle!.metodoPago, MetodoPago.credito);
    expect(detalle.clienteNombre, 'Doña Rosa');
  });

  test('se encolan venta_pagos y movimientos_cliente (sync)', () async {
    final id = await f.nuevoCliente();
    final ventaId = (await f.vender(
      metodo: MetodoPago.credito,
      clienteId: id,
    )).valueOrNull!;

    final cola = await f.db.select(f.db.syncQueue).get();
    final pago = cola.firstWhere((c) => c.tabla == 'venta_pagos');
    expect((jsonDecode(pago.payload) as Map)['metodo'], 'credito');
    final mov = cola.firstWhere((c) => c.tabla == 'movimientos_cliente');
    final payload = jsonDecode(mov.payload) as Map<String, dynamic>;
    expect(payload['tipo'], 'cargo');
    expect(payload['monto'], 30000);
    expect(payload['venta_id'], ventaId);
    expect(payload['cliente_id'], id);
  });
}
