import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:app_gestion/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late InventoryRepositoryImpl repo;
  late String usuarioId;
  late String productoId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InventoryRepositoryImpl(InventoryLocalDatasource(db));

    final negocioId = generateUuidV4();
    await db
        .into(db.negocios)
        .insert(
          NegociosCompanion.insert(
            id: Value(negocioId),
            nombre: 'Negocio Test',
          ),
        );

    usuarioId = generateUuidV4();
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: Value(usuarioId),
            negocioId: negocioId,
            nombre: 'Admin',
            username: 'admin',
            passwordHash: 'hash',
            salt: 'salt',
            rol: RolUsuario.administrador,
          ),
        );

    productoId = generateUuidV4();
    await db
        .into(db.productos)
        .insert(
          ProductosCompanion.insert(
            id: Value(productoId),
            nombre: 'Salami',
            unidad: const Value('libra'),
            precioCompra: const Value(100),
            precioVenta: const Value(150),
            stockActual: const Value(10),
            stockMinimo: const Value(2),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('applyMovement', () {
    test('actualiza stock, registra movimiento y auditoría', () async {
      final result = await repo.applyMovement(
        productoId: productoId,
        tipo: TipoMovimientoInventario.compra,
        cantidad: 5,
        referenciaId: 'compra-1',
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final producto = await (db.select(
        db.productos,
      )..where((t) => t.id.equals(productoId))).getSingle();
      expect(producto.stockActual, 15);

      final movimientos = await db.select(db.movimientosInventario).get();
      expect(movimientos, hasLength(1));
      expect(movimientos.single.tipo, TipoMovimientoInventario.compra);
      expect(movimientos.single.cantidad, 5);
      expect(movimientos.single.stockResultante, 15);
      expect(movimientos.single.referenciaId, 'compra-1');

      final auditoria = await db.select(db.auditoria).get();
      expect(auditoria, hasLength(1));
      expect(auditoria.single.modulo, 'inventario');
      expect(auditoria.single.accion, 'compra');
    });

    test('secuencia de movimientos deja el stock final correcto', () async {
      await repo.applyMovement(
        productoId: productoId,
        tipo: TipoMovimientoInventario.compra,
        cantidad: 10,
        usuarioId: usuarioId,
      );
      await repo.applyMovement(
        productoId: productoId,
        tipo: TipoMovimientoInventario.venta,
        cantidad: -4,
        usuarioId: usuarioId,
      );
      await repo.applyMovement(
        productoId: productoId,
        tipo: TipoMovimientoInventario.ajusteSalida,
        cantidad: -1,
        motivo: 'Merma',
        usuarioId: usuarioId,
      );

      // Stock inicial 10 + 10 - 4 - 1 = 15.
      final producto = await (db.select(
        db.productos,
      )..where((t) => t.id.equals(productoId))).getSingle();
      expect(producto.stockActual, 15);

      final movimientos = await db.select(db.movimientosInventario).get();
      expect(movimientos, hasLength(3));
    });

    test('falla si la cantidad es cero', () async {
      final result = await repo.applyMovement(
        productoId: productoId,
        tipo: TipoMovimientoInventario.ajusteEntrada,
        cantidad: 0,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });

    test('falla si el producto no existe', () async {
      final result = await repo.applyMovement(
        productoId: generateUuidV4(),
        tipo: TipoMovimientoInventario.ajusteEntrada,
        cantidad: 1,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });
  });

  group('ajusteManual', () {
    test('entrada con motivo registra ajusteEntrada y auditoría', () async {
      final result = await repo.ajusteManual(
        productoId: productoId,
        cantidad: 3,
        motivo: 'Conteo físico',
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final movimientos = await db.select(db.movimientosInventario).get();
      expect(movimientos.single.tipo, TipoMovimientoInventario.ajusteEntrada);
      expect(movimientos.single.cantidad, 3);
      expect(movimientos.single.motivo, 'Conteo físico');
      expect(movimientos.single.stockResultante, 13);

      final auditoria = await db.select(db.auditoria).get();
      expect(auditoria.single.accion, 'ajusteEntrada');
    });

    test('salida con motivo registra ajusteSalida', () async {
      final result = await repo.ajusteManual(
        productoId: productoId,
        cantidad: -2,
        motivo: 'Producto dañado',
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final movimientos = await db.select(db.movimientosInventario).get();
      expect(movimientos.single.tipo, TipoMovimientoInventario.ajusteSalida);
      expect(movimientos.single.stockResultante, 8);
    });

    test('falla sin motivo', () async {
      final result = await repo.ajusteManual(
        productoId: productoId,
        cantidad: 2,
        motivo: '   ',
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );

      final movimientos = await db.select(db.movimientosInventario).get();
      expect(movimientos, isEmpty);
    });

    test('falla si la cantidad es cero', () async {
      final result = await repo.ajusteManual(
        productoId: productoId,
        cantidad: 0,
        motivo: 'Conteo físico',
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });
  });

  group('watchExistencias', () {
    test('lista solo productos activos y filtra por nombre', () async {
      await db
          .into(db.productos)
          .insert(
            ProductosCompanion.insert(
              nombre: 'Jamón',
              precioCompra: const Value(50),
              precioVenta: const Value(80),
              stockActual: const Value(0),
              activo: const Value(false),
            ),
          );

      final todas = await repo.watchExistencias().first;
      expect(todas.map((p) => p.nombre), ['Salami']);

      final filtradas = await repo.watchExistencias(busqueda: 'sal').first;
      expect(filtradas, hasLength(1));

      final sinResultados = await repo
          .watchExistencias(busqueda: 'queso')
          .first;
      expect(sinResultados, isEmpty);
    });
  });

  group('watchKardex', () {
    test('lista los movimientos del producto con su usuario', () async {
      await repo.applyMovement(
        productoId: productoId,
        tipo: TipoMovimientoInventario.compra,
        cantidad: 5,
        usuarioId: usuarioId,
      );
      await repo.applyMovement(
        productoId: productoId,
        tipo: TipoMovimientoInventario.venta,
        cantidad: -2,
        usuarioId: usuarioId,
      );

      final kardex = await repo.watchKardex(productoId).first;
      expect(kardex, hasLength(2));
      expect(kardex.every((m) => m.usuarioNombre == 'Admin'), isTrue);
      expect(kardex.map((m) => m.tipo).toSet(), {
        TipoMovimientoInventario.compra,
        TipoMovimientoInventario.venta,
      });
    });
  });
}
