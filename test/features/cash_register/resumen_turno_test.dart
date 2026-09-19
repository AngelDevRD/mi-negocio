import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/cash_register/data/datasources/cash_register_local_datasource.dart';
import 'package:app_gestion/features/cash_register/data/repositories/cash_register_repository_impl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../customers/fiado_fixture.dart';

void main() {
  late FiadoFixture f;
  late CashRegisterRepositoryImpl repo;

  setUp(() async {
    f = await FiadoFixture.crear();
    repo = CashRegisterRepositoryImpl(CashRegisterLocalDatasource(f.db));
  });

  tearDown(() => f.cerrar());

  Future<String> sesionAbiertaId() async =>
      (await repo.watchSesionActual().first)!.id;

  /// Movimiento de caja que en la app crean gastos, compras y pagos a
  /// empleados (sus módulos ya lo hacen; aquí solo se simula su huella).
  Future<void> movimientoDeCaja(
    String sesionId,
    TipoCajaMovimiento tipo,
    int cents,
  ) => f.db
      .into(f.db.cajaMovimientos)
      .insert(
        CajaMovimientosCompanion.insert(
          cajaSesionId: sesionId,
          tipo: tipo,
          monto: cents,
          usuarioId: f.usuarioId,
        ),
      );

  group('obtenerResumenTurno', () {
    test('una sesión con todos los métodos devuelve cada total correcto '
        'y el efectivo esperado cuadra', () async {
      await f.abrirCaja(const Money(100000));
      final sesionId = await sesionAbiertaId();
      final cliente = await f.nuevoCliente();

      // Ventas: RD$ 150 la libra.
      await f.vender(cantidad: 2); // efectivo 30000
      await f.vender(cantidad: 1, metodo: MetodoPago.tarjeta); // 15000
      await f.vender(cantidad: 3, metodo: MetodoPago.transferencia); // 45000
      await f.vender(
        cantidad: 4,
        metodo: MetodoPago.credito,
        clienteId: cliente,
      ); // fiado 60000
      // Una venta anulada NO cuenta (su efectivo se compensa en la caja).
      final anulada = (await f.vender(cantidad: 1)).valueOrNull!;
      await f.ventas.anularVenta(anulada, usuarioId: f.usuarioId);

      // Abonos: uno en efectivo y otro por transferencia.
      await f.clientes.registrarAbono(
        clienteId: cliente,
        monto: const Money(10000),
        metodo: MetodoPago.efectivo,
        usuarioId: f.usuarioId,
      );
      await f.clientes.registrarAbono(
        clienteId: cliente,
        monto: const Money(20000),
        metodo: MetodoPago.transferencia,
        usuarioId: f.usuarioId,
      );

      // Entrada y salida manuales.
      await repo.registrarMovimientoManual(
        entrada: true,
        monto: const Money(5000),
        motivo: 'Cambio',
        usuarioId: f.usuarioId,
      );
      await repo.registrarMovimientoManual(
        entrada: false,
        monto: const Money(2000),
        motivo: 'Delivery',
        usuarioId: f.usuarioId,
      );

      // Gasto, compra y pago a empleado pagados desde la caja.
      await movimientoDeCaja(sesionId, TipoCajaMovimiento.gasto, -1200);
      await movimientoDeCaja(sesionId, TipoCajaMovimiento.compra, -800);
      await movimientoDeCaja(sesionId, TipoCajaMovimiento.pagoEmpleado, -500);

      final r = (await repo.obtenerResumenTurno(sesionId))!;

      expect(r.montoApertura, const Money(100000));
      expect(r.ventasEfectivo, const Money(30000));
      expect(r.ventasTarjeta, const Money(15000));
      expect(r.ventasTransferencia, const Money(45000));
      expect(r.ventasFiado, const Money(60000));
      expect(r.totalVentas, const Money(150000));
      expect(r.abonosEfectivo, const Money(10000));
      expect(r.abonosTarjeta, Money.zero);
      expect(r.abonosTransferencia, const Money(20000));
      expect(r.totalAbonos, const Money(30000));
      expect(r.entradasManuales, const Money(5000));
      expect(r.salidasManuales, const Money(2000));
      expect(r.gastos, const Money(1200));
      expect(r.compras, const Money(800));
      expect(r.pagosEmpleados, const Money(500));
      expect(r.totalPagosDeCaja, const Money(2500));

      // apertura + efectivo que entró − efectivo que salió.
      expect(r.efectivoEsperado, const Money(140500));
      expect(
        r.efectivoEsperado,
        r.montoApertura +
            r.ventasEfectivo +
            r.abonosEfectivo +
            r.entradasManuales -
            r.salidasManuales -
            r.totalPagosDeCaja,
      );
      // Y coincide con lo que la pantalla de caja ya mostraba.
      expect(
        (await repo.watchSesionActual().first)!.montoActual,
        const Money(140500),
      );
    });

    test('una venta histórica SIN venta_pagos cuenta como efectivo', () async {
      await f.abrirCaja(const Money(50000));
      final sesionId = await sesionAbiertaId();
      // Ventas anteriores a la v2: sin filas en venta_pagos.
      await f.db
          .into(f.db.ventas)
          .insert(
            VentasCompanion.insert(
              tipo: TipoVenta.rapida,
              total: 7000,
              ganancia: 2000,
              cajaSesionId: sesionId,
              usuarioId: f.usuarioId,
              estado: EstadoVenta.completada,
              fecha: DateTime.now().toUtc(),
            ),
          );
      expect(await f.cantidadEn('venta_pagos'), 0);

      final r = (await repo.obtenerResumenTurno(sesionId))!;

      expect(r.ventasEfectivo, const Money(7000));
      expect(r.ventasTarjeta, Money.zero);
      expect(r.ventasTransferencia, Money.zero);
      expect(r.ventasFiado, Money.zero);
    });

    test('solo cuenta las ventas y abonos de ESA sesión', () async {
      await f.abrirCaja(const Money(100000));
      final primera = await sesionAbiertaId();
      final cliente = await f.nuevoCliente();
      await f.vender(cantidad: 2);
      await f.vender(
        cantidad: 2,
        metodo: MetodoPago.credito,
        clienteId: cliente,
      );
      await repo.cerrarCaja(
        montoContado: const Money(130000),
        montoDejarSiguiente: const Money(20000),
        usuarioId: f.usuarioId,
      );

      await f.abrirCaja(const Money(20000));
      final segunda = await sesionAbiertaId();
      await f.vender(cantidad: 1, metodo: MetodoPago.tarjeta);

      final r1 = (await repo.obtenerResumenTurno(primera))!;
      final r2 = (await repo.obtenerResumenTurno(segunda))!;

      expect(r1.ventasEfectivo, const Money(30000));
      expect(r1.ventasFiado, const Money(30000));
      expect(r1.ventasTarjeta, Money.zero);
      expect(r2.ventasEfectivo, Money.zero);
      expect(r2.ventasTarjeta, const Money(15000));
      expect(r2.ventasFiado, Money.zero);
    });

    test('en una sesión CERRADA el efectivo esperado no descuenta el retiro '
        'del cierre y coincide con el esperado guardado', () async {
      await f.abrirCaja(const Money(100000));
      final sesionId = await sesionAbiertaId();
      await f.vender(cantidad: 2); // +30000 → esperado 130000
      await repo.cerrarCaja(
        montoContado: const Money(130000),
        montoDejarSiguiente: const Money(20000), // retiro de 110000
        usuarioId: f.usuarioId,
      );

      final r = (await repo.obtenerResumenTurno(sesionId))!;
      final cerrada = (await repo.obtenerSesion(sesionId))!;

      expect(r.efectivoEsperado, const Money(130000));
      expect(r.efectivoEsperado, cerrada.montoEsperado);
    });

    test(
      'un abono por transferencia FUERA de la sesión no se cuenta',
      () async {
        await f.abrirCaja(const Money(100000));
        final sesionId = await sesionAbiertaId();
        final cliente = await f.nuevoCliente();
        // Abono por transferencia de hace años (otra sesión, ya cerrada).
        await f.db
            .into(f.db.movimientosCliente)
            .insert(
              MovimientosClienteCompanion.insert(
                clienteId: cliente,
                tipo: TipoMovimientoCliente.abono,
                monto: -9900,
                metodoPago: const Value(MetodoPago.transferencia),
                usuarioId: f.usuarioId,
                fecha: Value(DateTime.utc(2020, 1, 1)),
              ),
            );

        final r = (await repo.obtenerResumenTurno(sesionId))!;

        expect(r.abonosTransferencia, Money.zero);
      },
    );

    test('una sesión inexistente devuelve null', () async {
      expect(await repo.obtenerResumenTurno('no-existe'), isNull);
    });

    test('es de solo lectura: no escribe nada', () async {
      await f.abrirCaja(const Money(100000));
      final sesionId = await sesionAbiertaId();
      await f.vender(cantidad: 1);
      final antes = [
        await f.cantidadEn('caja_movimientos'),
        await f.cantidadEn('auditoria'),
        await f.cantidadEn('sync_queue'),
      ];

      await repo.obtenerResumenTurno(sesionId);

      expect([
        await f.cantidadEn('caja_movimientos'),
        await f.cantidadEn('auditoria'),
        await f.cantidadEn('sync_queue'),
      ], antes);
    });
  });
}
