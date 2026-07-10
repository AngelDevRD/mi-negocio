import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

/// Acceso al perfil del negocio (RE-05: un solo registro por instalación).
class ProfileLocalDatasource {
  ProfileLocalDatasource(this._db);

  final AppDatabase _db;

  /// Negocio registrado en esta instalación.
  Stream<Negocio?> watchNegocio() =>
      (_db.select(_db.negocios)..limit(1)).watchSingleOrNull();

  /// Actualiza los datos editables del perfil y registra la auditoría
  /// (modulo `perfil`).
  Future<void> actualizarPerfil({
    required Negocio actual,
    required String nombre,
    String? identificacion,
    String? direccion,
    String? telefono,
    String? email,
    String? logoPath,
    required String actorId,
  }) {
    return _db.transaction(() async {
      await (_db.update(
        _db.negocios,
      )..where((t) => t.id.equals(actual.id))).write(
        NegociosCompanion(
          nombre: Value(nombre),
          identificacion: Value(identificacion),
          direccion: Value(direccion),
          telefono: Value(telefono),
          email: Value(email),
          logoPath: Value(logoPath),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: actorId,
              accion: 'actualizar',
              modulo: 'perfil',
              entidadId: Value(actual.id),
              datosAntes: Value(
                jsonEncode({
                  'nombre': actual.nombre,
                  'identificacion': actual.identificacion,
                  'direccion': actual.direccion,
                  'telefono': actual.telefono,
                  'email': actual.email,
                  'logoPath': actual.logoPath,
                }),
              ),
              datosDespues: Value(
                jsonEncode({
                  'nombre': nombre,
                  'identificacion': identificacion,
                  'direccion': direccion,
                  'telefono': telefono,
                  'email': email,
                  'logoPath': logoPath,
                }),
              ),
            ),
          );
    });
  }
}
