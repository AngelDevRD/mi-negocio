import '../entities/registro_auditoria.dart';

/// Filtros de la pantalla de auditoría (RF-AUD-02): por módulo, acción,
/// usuario y rango de fechas. Todos los campos son opcionales.
class AuditoriaFiltro {
  const AuditoriaFiltro({
    this.modulo,
    this.accion,
    this.usuarioId,
    this.desde,
    this.hasta,
  });

  final String? modulo;
  final String? accion;
  final String? usuarioId;
  final DateTime? desde;
  final DateTime? hasta;

  AuditoriaFiltro copyWith({
    Object? modulo = _sinCambio,
    Object? accion = _sinCambio,
    Object? usuarioId = _sinCambio,
    Object? desde = _sinCambio,
    Object? hasta = _sinCambio,
  }) {
    return AuditoriaFiltro(
      modulo: modulo == _sinCambio ? this.modulo : modulo as String?,
      accion: accion == _sinCambio ? this.accion : accion as String?,
      usuarioId: usuarioId == _sinCambio
          ? this.usuarioId
          : usuarioId as String?,
      desde: desde == _sinCambio ? this.desde : desde as DateTime?,
      hasta: hasta == _sinCambio ? this.hasta : hasta as DateTime?,
    );
  }

  static const _sinCambio = Object();
}

/// Usuario del negocio, para poblar el filtro por usuario.
typedef UsuarioFiltro = ({String id, String nombre});

/// Acceso de solo lectura a la tabla `auditoria` (RF-AUD-02). Es
/// append-only: no existen operaciones de edición o borrado.
abstract interface class AuditRepository {
  /// Registros que cumplen [filtro], más reciente primero.
  Stream<List<RegistroAuditoria>> watchRegistros(AuditoriaFiltro filtro);

  /// Módulos distintos presentes en la auditoría, para el filtro.
  Future<List<String>> listarModulos();

  /// Acciones distintas presentes en la auditoría, para el filtro.
  Future<List<String>> listarAcciones();

  /// Usuarios del negocio, para el filtro.
  Future<List<UsuarioFiltro>> listarUsuarios();
}
