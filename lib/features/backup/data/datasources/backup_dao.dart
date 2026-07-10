import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

/// Acceso a datos para respaldo y restauración (RF-RES). Vuelca y restaura
/// **todas** las tablas de [AppDatabase] de forma genérica, sin acoplarse al
/// esquema de cada una: el contenido se serializa tal cual lo entrega SQLite
/// (sin mapear a tipos Dart), por lo que es válido para JSON y para volver a
/// insertarlo sin pérdidas.
class BackupDao {
  BackupDao(this._db);

  final AppDatabase _db;

  /// Versión de schema de la base local (para el manifest del respaldo).
  int get schemaVersion => _db.schemaVersion;

  /// Vuelca el contenido de cada tabla como `{nombreTabla: [filas...]}`.
  Future<Map<String, List<Map<String, Object?>>>> volcarDatos() async {
    final resultado = <String, List<Map<String, Object?>>>{};
    for (final tabla in _db.allTables) {
      final filas = await _db
          .customSelect(
            'SELECT * FROM ${tabla.actualTableName}',
            readsFrom: {tabla},
          )
          .get();
      resultado[tabla.actualTableName] = [for (final fila in filas) fila.data];
    }
    return resultado;
  }

  /// Reemplaza TODOS los datos locales por los de [datos] (RN-21):
  /// borra cada tabla y reinserta las filas del respaldo en una sola
  /// transacción. Los FKs se desactivan durante el proceso porque el orden
  /// de borrado/inserción no respeta las dependencias entre tablas.
  Future<void> restaurarDatos(
    Map<String, List<Map<String, Object?>>> datos,
  ) async {
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await _db.transaction(() async {
        for (final tabla in _db.allTables) {
          await _db.customStatement('DELETE FROM ${tabla.actualTableName}');
        }
        for (final tabla in _db.allTables) {
          final filas = datos[tabla.actualTableName] ?? const [];
          for (final fila in filas) {
            final columnas = fila.keys.toList();
            final marcadores = List.filled(columnas.length, '?').join(', ');
            await _db.customStatement(
              'INSERT INTO ${tabla.actualTableName} '
              '(${columnas.join(', ')}) VALUES ($marcadores)',
              [for (final columna in columnas) fila[columna]],
            );
          }
        }
      });
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
    _db.markTablesUpdated(_db.allTables);
  }

  /// Negocio registrado (RE-05: uno por instalación), para el manifest y la
  /// confirmación destructiva (RN-21).
  Future<Negocio?> obtenerNegocio() =>
      _db.select(_db.negocios).getSingleOrNull();

  /// Rutas absolutas de fotos de factura de compras (RE-07: se incluyen en
  /// el respaldo). Incluye compras anuladas para no perder evidencia.
  Future<List<String>> rutasFotosCompras() async {
    final filas = await _db
        .customSelect(
          'SELECT foto_factura_path FROM compras '
          'WHERE foto_factura_path IS NOT NULL',
          readsFrom: {_db.compras},
        )
        .get();
    return [for (final fila in filas) fila.data['foto_factura_path'] as String];
  }

  /// Rutas absolutas de fotos de empleados (RE-07), incluidos inactivos.
  Future<List<String>> rutasFotosEmpleados() async {
    final filas = await _db
        .customSelect(
          'SELECT foto_path FROM empleados WHERE foto_path IS NOT NULL',
          readsFrom: {_db.empleados},
        )
        .get();
    return [for (final fila in filas) fila.data['foto_path'] as String];
  }

  /// Historial de respaldos realizados (RF-RES-03), más reciente primero.
  Stream<List<Respaldo>> watchHistorial() {
    return (_db.select(
      _db.respaldos,
    )..orderBy([(t) => OrderingTerm.desc(t.fecha)])).watch();
  }

  /// Registra un respaldo (generado o restaurado) en el historial.
  Future<void> registrarRespaldo({
    required TipoRespaldo tipo,
    required String archivo,
    required int tamanoBytes,
    required String resultado,
  }) {
    return _db
        .into(_db.respaldos)
        .insert(
          RespaldosCompanion.insert(
            fecha: DateTime.now().toUtc(),
            archivo: archivo,
            tamanoBytes: tamanoBytes,
            tipo: tipo,
            resultado: resultado,
          ),
        );
  }
}
