import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'enums.dart';
import 'tables/base.dart';
import 'tables/negocio_tables.dart';
import 'tables/operacion_tables.dart';
import 'tables/producto_tables.dart';
import 'tables/sistema_tables.dart';

export 'enums.dart';

part 'app_database.g.dart';

/// Base de datos local (SQLite vía Drift). Fuente principal de datos del
/// sistema (offline-first, RNF-01).
///
/// `schemaVersion` se incrementa con cada migración; nunca se edita una
/// migración ya publicada. ERD y decisiones en docs/MODELO_DATOS.md.
@DriftDatabase(
  tables: [
    // Negocio y acceso
    Negocios,
    Usuarios,
    LicenciasCache,
    Configuraciones,
    // Catálogo e inventario
    Categorias,
    Productos,
    HistorialPrecios,
    Proveedores,
    MovimientosInventario,
    // Operación diaria
    CajaSesiones,
    CajaMovimientos,
    Compras,
    CompraItems,
    Ventas,
    VentaItems,
    VentaPagos,
    Gastos,
    Empleados,
    PagosEmpleados,
    // Sistema
    Auditoria,
    Respaldos,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor para tests con base en memoria.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        // v1 -> v2: método de pago de las ventas (tabla nueva; las ventas
        // anteriores no tienen filas y se leen como efectivo).
        if (from < 2) {
          await m.createTable(ventaPagos);
          await m.createIndex(idxVentaPagosVenta);
        }
      },
      beforeOpen: (details) async {
        // Integridad referencial real en SQLite (apagada por defecto).
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'app_gestion');
  }
}

/// Provider único de la base de datos (DI vía Riverpod).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
