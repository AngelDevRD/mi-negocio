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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
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
