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

  /// `true` si TODAS las columnas de TODAS las filas de [datos] existen en su
  /// tabla. Los nombres de columna salen del JSON del respaldo y se
  /// concatenan en el `INSERT` de [restaurarDatos]: un respaldo manipulado
  /// podría colar SQL en ellos. Se comprueba ANTES de tocar la base. (Una fila
  /// con MENOS columnas que la tabla es válida: las que faltan toman su
  /// valor por defecto.)
  bool datosCompatibles(Map<String, List<Map<String, Object?>>> datos) {
    for (final tabla in _db.allTables) {
      final columnas = {for (final c in tabla.$columns) c.name};
      for (final fila in datos[tabla.actualTableName] ?? const []) {
        if (!fila.keys.every(columnas.contains)) return false;
      }
    }
    return true;
  }

  /// Reemplaza TODOS los datos locales por los de [datos] (RN-21):
  /// borra cada tabla y reinserta las filas del respaldo en una sola
  /// transacción. Los FKs se desactivan durante el proceso porque el orden
  /// de borrado/inserción no respeta las dependencias entre tablas.
  ///
  /// Una tabla AUSENTE en [datos] (p. ej. `venta_pagos`, `clientes` o
  /// `movimientos_cliente` en un respaldo hecho antes de la v2/v3) queda
  /// VACÍA: primero se borran todas las tablas y solo se reinsertan las que
  /// vienen, así la restauración es una foto fiel del respaldo.
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
