import 'dart:convert';

import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/dashboard/data/datasources/dashboard_dao.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'fiado_fixture.dart';

void main() {
  late FiadoFixture f;
  late String usuarioId;

  setUp(() async {
    f = await FiadoFixture.crear();
    usuarioId = f.usuarioId;
  });

  tearDown(() async {
    await f.cerrar();
  });

  Future<Result<String>> abonar(
    String clienteId,
    int centavos, {
    MetodoPago metodo = MetodoPago.efectivo,
  }) => f.clientes.registrarAbono(
    clienteId: clienteId,
    monto: Money(centavos),
    metodo: metodo,
    usuarioId: usuarioId,
    nota: 'abono de prueba',
  );

  Future<int> montoActualDeCaja() async =>
      (await DashboardDao(f.db).watchCajaActual().first)!.montoActual.cents;

  /// Deja a un cliente debiendo [total] centavos (fiado de 1 libra = 15000).
  Future<String> clienteDebiendo15000() async {
    await f.abrirCaja();
    final id = await f.nuevoCliente();
    expect(
      (await f.vender(
        cantidad: 1,
        metodo: MetodoPago.credito,
        clienteId: id,
      )).isOk,
      isTrue,
    );
    expect(await f.saldo(id), 15000);
    return id;
  }

  group('clientes', () {
    test('crear: guarda la ficha, la audita y la encola', () async {
      final r = await f.clientes.crearCliente(
        nombre: '  Doña Rosa ',
        telefono: '809-555-0101',
        limiteCredito: const Money(50000),
        usuarioId: usuarioId,
      );
      final id = r.valueOrNull!;

      final c = (await f.clientes.obtenerCliente(id))!;
      expect(c.nombre, 'Doña Rosa');
      expect(c.telefono, '809-555-0101');
      expect(c.limiteCredito, const Money(50000));
      expect(c.activo, isTrue);
      expect(c.saldo, const Money(0));

      final auditoria = await f.db.select(f.db.auditoria).get();
      expect(auditoria.single.modulo, 'clientes');
      expect(auditoria.single.accion, 'crear');
      final cola = await (f.db.select(
        f.db.syncQueue,
      )..where((t) => t.tabla.equals('clientes'))).get();
      expect(cola, hasLength(1));
      final payload = jsonDecode(cola.single.payload) as Map<String, dynamic>;
      expect(payload['nombre'], 'Doña Rosa');
      expect(payload['limite_credito'], 50000);
      expect(payload['activo'], true);
    });

    test('nombre obligatorio y límite no negativo', () async {
      final sinNombre = await f.clientes.crearCliente(
        nombre: '  ',
        usuarioId: usuarioId,
      );
      expect(sinNombre.isOk, isFalse);
      final limiteNegativo = await f.clientes.crearCliente(
        nombre: 'X',
        limiteCredito: const Money(-1),
        usuarioId: usuarioId,
      );
      expect(limiteNegativo.isOk, isFalse);
      expect(await f.cantidadEn('clientes'), 0);
    });

    test('editar actualiza la ficha', () async {
      final id = await f.nuevoCliente();

      final r = await f.clientes.actualizarCliente(
        id: id,
        nombre: 'Rosa Pérez',
        telefono: '829-000-1111',
        limiteCredito: null,
        usuarioId: usuarioId,
      );

      expect(r.isOk, isTrue);
      final c = (await f.clientes.obtenerCliente(id))!;
      expect(c.nombre, 'Rosa Pérez');
      expect(c.limiteCredito, isNull);
    });

    test('listar con búsqueda por nombre y teléfono, con saldo', () async {
      await f.abrirCaja();
      final rosa = await f.nuevoCliente(
        nombre: 'Doña Rosa',
        telefono: '809-111-2222',
      );
      await f.nuevoCliente(nombre: 'Juan Pérez', telefono: '829-333-4444');
      await f.vender(cantidad: 2, metodo: MetodoPago.credito, clienteId: rosa);

      final todos = await f.clientes.watchClientes().first;
      expect(todos.map((c) => c.nombre), ['Doña Rosa', 'Juan Pérez']);
      expect(todos.first.saldo, const Money(30000));
      expect(todos.last.saldo, const Money(0));

      final porNombre = await f.clientes.watchClientes(busqueda: 'juan').first;
      expect(porNombre.map((c) => c.nombre), ['Juan Pérez']);
      final porTelefono = await f.clientes
          .watchClientes(busqueda: '809-111')
          .first;
      expect(porTelefono.map((c) => c.nombre), ['Doña Rosa']);
    });

    test('el saldo del stream es reactivo', () async {
      await f.abrirCaja();
      final id = await f.nuevoCliente();
      final saldos = <int>[];
      final sub = f.clientes.watchClientes().listen(
        (l) => saldos.add(l.single.saldo.cents),
      );
      addTearDown(sub.cancel);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      await f.vender(cantidad: 1, metodo: MetodoPago.credito, clienteId: id);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(saldos.first, 0);
      expect(saldos.last, 15000);
    });

    test(
      'un cliente con movimientos NO se puede eliminar pero sí desactivar',
      () async {
        final id = await clienteDebiendo15000();

        final eliminar = await f.clientes.eliminarCliente(
          id,
          usuarioId: usuarioId,
        );
        expect(eliminar.isOk, isFalse);
        expect((await f.clientes.obtenerCliente(id)), isNotNull);

        final desactivar = await f.clientes.establecerActivo(
          id: id,
          activo: false,
          usuarioId: usuarioId,
        );
        expect(desactivar.isOk, isTrue);
        final c = (await f.clientes.obtenerCliente(id))!;
        expect(c.activo, isFalse);
        expect(c.saldo, const Money(15000)); // historial y saldo conservados
        expect(await f.cantidadEn('movimientos_cliente'), 1);
      },
    );

    test('un cliente SIN movimientos sí se elimina (borrado lógico)', () async {
      final id = await f.nuevoCliente();

      final r = await f.clientes.eliminarCliente(id, usuarioId: usuarioId);

      expect(r.isOk, isTrue);
      expect(await f.clientes.obtenerCliente(id), isNull);
      expect(await f.clientes.watchClientes().first, isEmpty);
      // La fila sigue en la base (soft delete) y se encoló su update.
      expect(await f.cantidadEn('clientes'), 1);
    });
  });

  group('abonos', () {
    test('saldo = cargos - abonos - anulaciones', () async {
      await f.abrirCaja();
      final id = await f.nuevoCliente();
      final v1 = (await f.vender(
        cantidad: 2,
        metodo: MetodoPago.credito,
        clienteId: id,
      )).valueOrNull!;
      await f.vender(cantidad: 1, metodo: MetodoPago.credito, clienteId: id);
      expect(await f.saldo(id), 30000 + 15000);

      expect((await abonar(id, 10000)).isOk, isTrue);
      expect(await f.saldo(id), 35000);

      await f.ventas.anularVenta(v1, usuarioId: usuarioId);
      expect(await f.saldo(id), 35000 - 30000);

      final movs = await (f.db.select(f.db.movimientosCliente)).get();
      final suma = movs.fold<int>(0, (s, m) => s + m.monto);
      expect(suma, await f.saldo(id));
    });

    test(
      'abono en efectivo SIN caja abierta falla y no escribe nada',
      () async {
        final id = await clienteDebiendo15000();
        // Se cierra la caja: sin sesión abierta.
        await (f.db.update(f.db.cajaSesiones)).write(
          CajaSesionesCompanion(estado: Value(EstadoCajaSesion.cerrada)),
        );

        final r = await abonar(id, 5000);

        r.when(
          ok: (_) => fail('debió fallar sin caja abierta'),
          fail: (fallo) {
            expect(fallo, isA<BusinessRuleFailure>());
            expect((fallo as BusinessRuleFailure).rule, 'RN-01');
          },
        );
        expect(await f.cantidadEn('movimientos_cliente'), 1); // solo el cargo
        expect(await f.saldo(id), 15000);
      },
    );

    test('abono en efectivo crea caja_movimiento abonoCliente y sube el monto '
        'de la caja', () async {
      final id = await clienteDebiendo15000();
      final antes = await montoActualDeCaja();

      final movId = (await abonar(id, 5000)).valueOrNull!;

      final abonos = await (f.db.select(
        f.db.movimientosCliente,
      )..where((t) => t.id.equals(movId))).get();
      expect(abonos.single.monto, -5000);
      expect(abonos.single.metodoPago, MetodoPago.efectivo);
      expect(abonos.single.cajaSesionId, isNotNull);

      final cajaMovs =
          await (f.db.select(f.db.cajaMovimientos)..where(
                (t) => t.tipo.equalsValue(TipoCajaMovimiento.abonoCliente),
              ))
              .get();
      expect(cajaMovs, hasLength(1));
      expect(cajaMovs.single.monto, 5000);
      expect(cajaMovs.single.referenciaId, movId);
      expect(await montoActualDeCaja(), antes + 5000);
      expect(await f.saldo(id), 10000);
    });

    test('abono con tarjeta o transferencia NO toca la caja', () async {
      final id = await clienteDebiendo15000();
      final antes = await montoActualDeCaja();

      expect((await abonar(id, 5000, metodo: MetodoPago.tarjeta)).isOk, isTrue);
      expect(
        (await abonar(id, 2000, metodo: MetodoPago.transferencia)).isOk,
        isTrue,
      );

      final cajaMovs =
          await (f.db.select(f.db.cajaMovimientos)..where(
                (t) => t.tipo.equalsValue(TipoCajaMovimiento.abonoCliente),
              ))
              .get();
      expect(cajaMovs, isEmpty);
      expect(await montoActualDeCaja(), antes);
      expect(await f.saldo(id), 15000 - 7000);
      final movs = await (f.db.select(
        f.db.movimientosCliente,
      )..where((t) => t.tipo.equalsValue(TipoMovimientoCliente.abono))).get();
      expect(movs.every((m) => m.cajaSesionId == null), isTrue);
    });

    test('abono mayor que el saldo falla con el saldo en el mensaje y no '
        'escribe nada', () async {
      final id = await clienteDebiendo15000();

      final r = await abonar(id, 15001);

      r.when(
        ok: (_) => fail('debió fallar: supera el saldo'),
        fail: (fallo) {
          expect(fallo, isA<BusinessRuleFailure>());
          expect(fallo.message, contains('supera el saldo pendiente'));
          expect(fallo.message, contains('RD\$ 150.00'));
        },
      );
      expect(await f.cantidadEn('movimientos_cliente'), 1);
      expect(await f.saldo(id), 15000);
    });

    test('abonar exactamente el saldo lo deja en cero', () async {
      final id = await clienteDebiendo15000();

      expect((await abonar(id, 15000)).isOk, isTrue);

      expect(await f.saldo(id), 0);
    });

    test('un abono NO puede ser de monto 0, negativo ni con crédito', () async {
      final id = await clienteDebiendo15000();

      for (final r in [
        await abonar(id, 0),
        await abonar(id, -100),
        await abonar(id, 5000, metodo: MetodoPago.credito),
      ]) {
        expect(r.isOk, isFalse);
      }
      expect(await f.cantidadEn('movimientos_cliente'), 1);
    });

    test('un cliente inactivo puede seguir abonando', () async {
      final id = await clienteDebiendo15000();
      await f.clientes.establecerActivo(
        id: id,
        activo: false,
        usuarioId: usuarioId,
      );

      expect((await abonar(id, 5000)).isOk, isTrue);
      expect(await f.saldo(id), 10000);
    });

    test(
      'se audita y se encolan las filas nuevas (movimiento y caja)',
      () async {
        final id = await clienteDebiendo15000();

        final movId = (await abonar(id, 5000)).valueOrNull!;

        final auditoria = await (f.db.select(
          f.db.auditoria,
        )..where((t) => t.accion.equals('abonar'))).get();
        expect(auditoria.single.modulo, 'clientes');
        expect(auditoria.single.entidadId, movId);

        final cola = await f.db.select(f.db.syncQueue).get();
        Iterable<SyncQueueData> de(String tabla) =>
            cola.where((c) => c.tabla == tabla);
        final movCola = de(
          'movimientos_cliente',
        ).firstWhere((c) => c.registroId == movId);
        final payload = jsonDecode(movCola.payload) as Map<String, dynamic>;
        expect(payload['tipo'], 'abono');
        expect(payload['monto'], -5000);
        expect(payload['metodo_pago'], 'efectivo');
        expect(payload['cliente_id'], id);
        expect(payload.containsKey('created_at'), isTrue);
        expect(de('caja_movimientos').length, greaterThanOrEqualTo(1));
      },
    );
  });
}
