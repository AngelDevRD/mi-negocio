import '../../../../core/database/app_database.dart' show AuditoriaData;
import '../../domain/entities/registro_auditoria.dart';
import '../../domain/repositories/audit_repository.dart';
import '../datasources/audit_local_datasource.dart';

/// Implementación de solo lectura de la auditoría (RF-AUD-02).
class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._local);

  final AuditLocalDatasource _local;

  RegistroAuditoria _aEntidad((AuditoriaData, String) fila) {
    final (registro, usuarioNombre) = fila;
    return RegistroAuditoria(
      id: registro.id,
      usuarioId: registro.usuarioId,
      usuarioNombre: usuarioNombre,
      accion: registro.accion,
      modulo: registro.modulo,
      entidadId: registro.entidadId,
      datosAntes: decodificarDatosAuditoria(registro.datosAntes),
      datosDespues: decodificarDatosAuditoria(registro.datosDespues),
      fecha: registro.fecha,
    );
  }

  @override
  Stream<List<RegistroAuditoria>> watchRegistros(AuditoriaFiltro filtro) {
    return _local
        .watchRegistros(filtro)
        .map((filas) => filas.map(_aEntidad).toList());
  }

  @override
  Future<List<String>> listarModulos() => _local.listarModulos();

  @override
  Future<List<String>> listarAcciones() => _local.listarAcciones();

  @override
  Future<List<UsuarioFiltro>> listarUsuarios() => _local.listarUsuarios();
}
