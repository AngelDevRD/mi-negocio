import '../../database/app_database.dart';

/// Mapeo compartido para encolar filas de `auditoria` -- usado desde varios
/// datasources (products, employees, auth) que registran auditoría.
Map<String, dynamic> auditoriaPayload(AuditoriaData a) => {
  'usuario_id': a.usuarioId,
  'accion': a.accion,
  'modulo': a.modulo,
  'entidad_id': a.entidadId,
  'datos_antes': a.datosAntes,
  'datos_despues': a.datosDespues,
  'fecha': a.fecha.toIso8601String(),
  'created_at': a.createdAt.toIso8601String(),
  'updated_at': a.updatedAt.toIso8601String(),
};
