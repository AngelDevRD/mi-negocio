import 'package:freezed_annotation/freezed_annotation.dart';

part 'registro_auditoria.freezed.dart';

/// Entrada del registro de auditoría (RF-AUD-02), append-only: cada acción
/// importante de los repositorios queda aquí con quién, qué, cuándo y el
/// estado antes/después de la entidad afectada.
@freezed
abstract class RegistroAuditoria with _$RegistroAuditoria {
  const factory RegistroAuditoria({
    required String id,
    required String usuarioId,
    required String usuarioNombre,
    required String accion,
    required String modulo,
    String? entidadId,
    Map<String, Object?>? datosAntes,
    Map<String, Object?>? datosDespues,
    required DateTime fecha,
  }) = _RegistroAuditoria;
}
