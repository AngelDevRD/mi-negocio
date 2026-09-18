import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generated_migrations/schema.dart';

/// Migraciones de esquema verificadas con los esquemas exportados en
/// `drift_schemas/` (`dart run drift_dev schema dump ...`).
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('v1 -> v2 conserva los datos y crea venta_pagos vacía y usable', () async {
    final schema = await verifier.schemaAt(1);

    // Datos "reales" de una instalación v1: negocio, usuario, producto, caja
    // abierta, una venta con su ítem y su movimiento de caja.
    const t = '2026-01-15T10:00:00.000Z';
    schema.rawDatabase.execute('''
      INSERT INTO negocios (id, created_at, updated_at, nombre)
        VALUES ('n1', '$t', '$t', 'Colmado Test');
      INSERT INTO usuarios (id, created_at, updated_at, negocio_id, nombre,
          username, password_hash, salt, rol)
        VALUES ('u1', '$t', '$t', 'n1', 'Ana', 'ana', 'hash', 'salt',
          'administrador');
      INSERT INTO productos (id, created_at, updated_at, nombre, unidad,
          precio_compra, precio_venta, stock_actual, stock_minimo)
        VALUES ('p1', '$t', '$t', 'Salami', 'libra', 100, 150, 8.0, 2.0);
      INSERT INTO caja_sesiones (id, created_at, updated_at, fecha_apertura,
          monto_apertura, usuario_apertura, estado)
        VALUES ('c1', '$t', '$t', '$t', 50000, 'u1', 'abierta');
      INSERT INTO ventas (id, created_at, updated_at, tipo, total, ganancia,
          caja_sesion_id, usuario_id, estado, nota, fecha)
        VALUES ('v1', '$t', '$t', 'rapida', 300, 100, 'c1', 'u1',
          'completada', 'venta v1', '$t');
      INSERT INTO venta_items (id, created_at, updated_at, venta_id,
          producto_id, cantidad, precio_unitario, costo_unitario)
        VALUES ('vi1', '$t', '$t', 'v1', 'p1', 2.0, 150, 100);
      INSERT INTO caja_movimientos (id, created_at, updated_at, caja_sesion_id,
          tipo, monto, referencia_id, usuario_id, fecha)
        VALUES ('m1', '$t', '$t', 'c1', 'venta', 300, 'v1', 'u1', '$t');
    ''');

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    // Valida que el esquema resultante es idéntico al v2 exportado (tablas,
    // columnas, índices).
    await verifier.migrateAndValidate(db, 2);

    // Nada se perdió.
    final ventas = await db.select(db.ventas).get();
    expect(ventas, hasLength(1));
    expect(ventas.single.id, 'v1');
    expect(ventas.single.total, 300);
    expect(ventas.single.nota, 'venta v1');
    final items = await db.select(db.ventaItems).get();
    expect(items, hasLength(1));
    expect(items.single.cantidad, 2.0);
    expect(items.single.precioUnitario, 150);
    final movimientos = await db.select(db.cajaMovimientos).get();
    expect(movimientos, hasLength(1));
    expect(movimientos.single.monto, 300);
    expect(movimientos.single.tipo, TipoCajaMovimiento.venta);
    final producto = await db.select(db.productos).getSingle();
    expect(producto.stockActual, 8.0);
    expect((await db.select(db.usuarios).get()), hasLength(1));
    expect((await db.select(db.negocios).get()), hasLength(1));

    // La tabla nueva existe, está vacía y es usable.
    expect(await db.select(db.ventaPagos).get(), isEmpty);
    await db
        .into(db.ventaPagos)
        .insert(
          VentaPagosCompanion.insert(
            ventaId: 'v1',
            metodo: MetodoPago.tarjeta,
            monto: 300,
          ),
        );
    final pagos = await db.select(db.ventaPagos).get();
    expect(pagos, hasLength(1));
    expect(pagos.single.metodo, MetodoPago.tarjeta);
    expect(pagos.single.monto, 300);
  });

  test('una venta v1 (sin venta_pagos) se lee como EFECTIVO por el total', () async {
    final schema = await verifier.schemaAt(1);
    const t = '2026-01-15T10:00:00.000Z';
    schema.rawDatabase.execute('''
      INSERT INTO negocios (id, created_at, updated_at, nombre)
        VALUES ('n1', '$t', '$t', 'Colmado Test');
      INSERT INTO usuarios (id, created_at, updated_at, negocio_id, nombre,
          username, password_hash, salt, rol)
        VALUES ('u1', '$t', '$t', 'n1', 'Ana', 'ana', 'hash', 'salt',
          'administrador');
      INSERT INTO caja_sesiones (id, created_at, updated_at, fecha_apertura,
          monto_apertura, usuario_apertura, estado)
        VALUES ('c1', '$t', '$t', '$t', 0, 'u1', 'abierta');
      INSERT INTO ventas (id, created_at, updated_at, tipo, total, ganancia,
          caja_sesion_id, usuario_id, estado, fecha)
        VALUES ('v1', '$t', '$t', 'rapida', 1234, 0, 'c1', 'u1',
          'completada', '$t');
    ''');

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);

    final local = SalesLocalDatasource(db);
    expect(await local.obtenerPagos('v1', 1234), [
      (metodo: MetodoPago.efectivo, monto: 1234),
    ]);
    expect(await local.metodoDePago('v1', 1234), MetodoPago.efectivo);
  });

  test('una base nueva (onCreate) ya trae venta_pagos con su índice', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.select(db.ventaPagos).get(), isEmpty);
    final indices = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND tbl_name = 'venta_pagos'",
        )
        .get();
    expect(
      indices.map((f) => f.read<String>('name')),
      contains('idx_venta_pagos_venta'),
    );
  });
}
