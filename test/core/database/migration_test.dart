import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../generated_migrations/schema.dart';

/// Migraciones de esquema verificadas con los esquemas exportados en
/// `drift_schemas/` (`dart run drift_dev schema dump ...`).
///
/// `AppDatabase.schemaVersion` es 3: `migrateAndValidate(db, 3)` ejecuta la
/// migración real desde la versión inicial y comprueba que el esquema
/// resultante es idéntico al v3 exportado (tablas, columnas e índices).
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  const t = '2026-01-15T10:00:00.000Z';

  /// Datos "reales" de una instalación: negocio, usuario, producto, caja
  /// abierta, una venta con su ítem y su movimiento de caja (comunes a v1 y
  /// v2: no usan tablas nuevas).
  void sembrarBase(void Function(String) ejecutar) {
    ejecutar('''
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
  }

  Future<void> verificarDatosBase(AppDatabase db) async {
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
    expect(await db.select(db.usuarios).get(), hasLength(1));
    expect(await db.select(db.negocios).get(), hasLength(1));
  }

  /// Las tablas de fiado existen, están vacías y son usables.
  Future<void> verificarFiadoUsable(AppDatabase db) async {
    expect(await db.select(db.clientes).get(), isEmpty);
    expect(await db.select(db.movimientosCliente).get(), isEmpty);
    await db
        .into(db.clientes)
        .insert(
          ClientesCompanion.insert(nombre: 'Doña Rosa', telefono: const Value('809-555-0101')),
        );
    final cliente = await db.select(db.clientes).getSingle();
    await db
        .into(db.movimientosCliente)
        .insert(
          MovimientosClienteCompanion.insert(
            clienteId: cliente.id,
            tipo: TipoMovimientoCliente.cargo,
            monto: 300,
            ventaId: const Value('v1'),
            usuarioId: 'u1',
          ),
        );
    final mov = await db.select(db.movimientosCliente).getSingle();
    expect(mov.monto, 300);
    expect(mov.tipo, TipoMovimientoCliente.cargo);
  }

  test('v1 -> v3 conserva los datos y crea las tablas nuevas vacías', () async {
    final schema = await verifier.schemaAt(1);
    sembrarBase(schema.rawDatabase.execute);

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 3);

    await verificarDatosBase(db);
    expect(await db.select(db.ventaPagos).get(), isEmpty);
    await verificarFiadoUsable(db);
  });

  test('v2 -> v3 conserva los datos (incluidas las filas de venta_pagos) y '
      'crea las tablas de fiado vacías y usables', () async {
    final schema = await verifier.schemaAt(2);
    sembrarBase(schema.rawDatabase.execute);
    schema.rawDatabase.execute('''
      INSERT INTO venta_pagos (id, created_at, updated_at, venta_id, metodo,
          monto)
        VALUES ('vp1', '$t', '$t', 'v1', 'tarjeta', 300);
    ''');

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 3);

    await verificarDatosBase(db);
    final pagos = await db.select(db.ventaPagos).get();
    expect(pagos, hasLength(1));
    expect(pagos.single.id, 'vp1');
    expect(pagos.single.metodo, MetodoPago.tarjeta);
    expect(pagos.single.monto, 300);
    await verificarFiadoUsable(db);
  });

  test('una venta v1 (sin venta_pagos) se lee como EFECTIVO por el total', () async {
    final schema = await verifier.schemaAt(1);
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
    await verifier.migrateAndValidate(db, 3);

    final local = SalesLocalDatasource(db);
    expect(await local.obtenerPagos('v1', 1234), [
      (metodo: MetodoPago.efectivo, monto: 1234),
    ]);
    expect(await local.metodoDePago('v1', 1234), MetodoPago.efectivo);
  });

  test('una base nueva (onCreate) trae venta_pagos y las tablas de fiado con '
      'sus índices', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.select(db.ventaPagos).get(), isEmpty);
    expect(await db.select(db.clientes).get(), isEmpty);
    expect(await db.select(db.movimientosCliente).get(), isEmpty);
    final indices = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    expect(
      indices.map((f) => f.read<String>('name')),
      containsAll([
        'idx_venta_pagos_venta',
        'idx_clientes_nombre',
        'idx_movimientos_cliente_cliente',
        'idx_movimientos_cliente_fecha',
      ]),
    );
  });
}
