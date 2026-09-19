import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/cash_register/data/datasources/cash_register_local_datasource.dart';
import 'package:app_gestion/features/cash_register/data/repositories/cash_register_repository_impl.dart';
import 'package:app_gestion/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:app_gestion/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../customers/fiado_fixture.dart';

Failure? _fallo(Result<Object?> r) => r.when(ok: (_) => null, fail: (f) => f);

/// Defensa en profundidad (S4): las operaciones de dinero solo-Administrador
/// también se imponen en el dominio (con el rol guardado en la base, leído
/// DENTRO de la transacción), no solo ocultando botones en la UI.
void main() {
  late FiadoFixture f;
  late CashRegisterRepositoryImpl caja;
  late InventoryRepositoryImpl inventario;
  late String cajeroId;

  setUp(() async {
    f = await FiadoFixture.crear();
    caja = CashRegisterRepositoryImpl(CashRegisterLocalDatasource(f.db));
    inventario = InventoryRepositoryImpl(InventoryLocalDatasource(f.db));
    final negocio = await f.db.select(f.db.negocios).getSingle();
    cajeroId = generateUuidV4();
    await f.db
        .into(f.db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: Value(cajeroId),
            negocioId: negocio.id,
            nombre: 'Cajero',
            username: 'cajero',
            passwordHash: 'hash',
            salt: 'salt',
            rol: RolUsuario.cajero,
          ),
        );
  });

  tearDown(() => f.cerrar());

  Future<List<int>> escrituras() async => [
    await f.cantidadEn('ventas'),
    await f.cantidadEn('movimientos_inventario'),
    await f.cantidadEn('caja_movimientos'),
    await f.cantidadEn('auditoria'),
    await f.cantidadEn('sync_queue'),
  ];

  Future<double> stock() async => f.stock();

  group('anularVenta', () {
    test('el Cajero NO puede: PermissionFailure y nada escrito', () async {
      await f.abrirCaja();
      final ventaId = (await f.vender(cantidad: 2)).valueOrNull!;
      final antes = await escrituras();
      final stockAntes = await stock();

      final r = await f.ventas.anularVenta(ventaId, usuarioId: cajeroId);

      expect(_fallo(r), isA<PermissionFailure>());
      expect(_fallo(r)!.message, 'Solo el administrador puede anular ventas.');
      expect(await escrituras(), antes);
      expect(await stock(), stockAntes);
      final venta = await f.ventas.obtenerVenta(ventaId);
      expect(venta!.estado, EstadoVenta.completada);
    });

    test('un usuario inexistente tampoco puede', () async {
      await f.abrirCaja();
      final ventaId = (await f.vender()).valueOrNull!;

      final r = await f.ventas.anularVenta(ventaId, usuarioId: 'fantasma');

      expect(_fallo(r), isA<PermissionFailure>());
    });

    test('el Administrador SÍ puede', () async {
      await f.abrirCaja();
      final ventaId = (await f.vender(cantidad: 2)).valueOrNull!;

      final r = await f.ventas.anularVenta(ventaId, usuarioId: f.usuarioId);

      expect(r.isOk, isTrue);
      expect(await stock(), 100);
    });
  });

  group('cerrarCaja', () {
    test('el Cajero NO puede: PermissionFailure, la caja sigue abierta y '
        'nada escrito', () async {
      await f.abrirCaja(const Money(50000));
      final antes = await escrituras();

      final r = await caja.cerrarCaja(
        montoContado: const Money(50000),
        montoDejarSiguiente: const Money(10000),
        usuarioId: cajeroId,
      );

      expect(_fallo(r), isA<PermissionFailure>());
      expect(_fallo(r)!.message, 'Solo el administrador puede cerrar la caja.');
      expect(await escrituras(), antes);
      expect(await caja.watchSesionActual().first, isNotNull);
    });

    test('el Administrador SÍ puede', () async {
      await f.abrirCaja(const Money(50000));

      final r = await caja.cerrarCaja(
        montoContado: const Money(50000),
        montoDejarSiguiente: const Money(10000),
        usuarioId: f.usuarioId,
      );

      expect(r.isOk, isTrue);
      expect(await caja.watchSesionActual().first, isNull);
    });
  });

  group('ajusteManual de inventario', () {
    test('el Cajero NO puede: PermissionFailure y nada escrito', () async {
      final antes = await escrituras();

      final r = await inventario.ajusteManual(
        productoId: f.productoId,
        cantidad: -5,
        motivo: 'Merma',
        usuarioId: cajeroId,
      );

      expect(_fallo(r), isA<PermissionFailure>());
      expect(
        _fallo(r)!.message,
        'Solo el administrador puede ajustar el inventario.',
      );
      expect(await escrituras(), antes);
      expect(await stock(), 100);
    });

    test('el Administrador SÍ puede', () async {
      final r = await inventario.ajusteManual(
        productoId: f.productoId,
        cantidad: -5,
        motivo: 'Merma',
        usuarioId: f.usuarioId,
      );

      expect(r.isOk, isTrue);
      expect(await stock(), 95);
    });
  });
}
