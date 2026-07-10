import '../../../../core/errors/result.dart';
import '../entities/usuario.dart';

/// Operaciones de autenticación local (RF-AUTH). Implementación en
/// `data/repositories/auth_repository_impl.dart`.
abstract interface class AuthRepository {
  /// `false` en el primer arranque tras activar la licencia: falta el
  /// wizard de registro del negocio y el administrador.
  Future<bool> hayNegocioRegistrado();

  /// Registra el negocio y crea el usuario Administrador inicial.
  Future<Result<Usuario>> registrarNegocioYAdmin({
    required String nombreNegocio,
    String? identificacion,
    String? direccion,
    String? telefono,
    String? email,
    required String nombreAdmin,
    required String username,
    required String password,
  });

  Future<Result<Usuario>> login({
    required String username,
    required String password,
  });

  Future<Usuario?> obtenerUsuario(String id);

  /// Usuarios activos e inactivos (sin soft-delete) del negocio.
  Future<List<Usuario>> listarUsuarios();

  /// Solo el Administrador puede crear cuentas Cajero. [actorId] es el
  /// Administrador que ejecuta la acción (RF-AUD-02).
  Future<Result<Usuario>> crearCajero({
    required String nombre,
    required String username,
    required String password,
    required String actorId,
  });

  /// El Administrador resetea la contraseña de un Cajero sin conocer la
  /// anterior. [actorId] es el Administrador que ejecuta la acción
  /// (RF-AUD-02).
  Future<Result<void>> resetearPassword({
    required String usuarioId,
    required String nuevaPassword,
    required String actorId,
  });

  /// El propio usuario cambia su contraseña conociendo la actual.
  Future<Result<void>> cambiarPassword({
    required String usuarioId,
    required String actual,
    required String nueva,
  });

  /// Activa/desactiva una cuenta. No permite desactivar al único
  /// Administrador activo. [actorId] es el Administrador que ejecuta la
  /// acción (RF-AUD-02).
  Future<Result<void>> establecerActivo({
    required String usuarioId,
    required bool activo,
    required String actorId,
  });
}
