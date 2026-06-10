import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/licencia.dart';

/// Caché local de la licencia en SQLite (tabla `licencias_cache`).
/// Permite operar offline con período de gracia (RN-16).
class LicenseLocalDatasource {
  LicenseLocalDatasource(this._db);

  final AppDatabase _db;

  Future<Licencia?> obtener() async {
    final row =
        await (_db.select(_db.licenciasCache)
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return Licencia(
      tipo: row.tipo,
      estado: row.estado,
      clave: row.claveLicencia,
      deviceId: row.deviceId,
      fechaActivacion: row.fechaActivacion,
      fechaVencimiento: row.fechaVencimiento,
      ultimaValidacion: row.ultimaValidacion,
    );
  }

  /// Reemplaza la caché completa (una sola licencia por instalación).
  Future<void> guardar(Licencia licencia) async {
    await _db.transaction(() async {
      await _db.delete(_db.licenciasCache).go();
      await _db
          .into(_db.licenciasCache)
          .insert(
            LicenciasCacheCompanion.insert(
              tipo: licencia.tipo,
              estado: licencia.estado,
              claveLicencia: Value(licencia.clave),
              deviceId: licencia.deviceId,
              fechaActivacion: licencia.fechaActivacion,
              fechaVencimiento: Value(licencia.fechaVencimiento),
              ultimaValidacion: licencia.ultimaValidacion,
            ),
          );
    });
  }

  Future<void> eliminar() => _db.delete(_db.licenciasCache).go();
}
