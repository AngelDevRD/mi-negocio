import '../../../../core/database/app_database.dart' as db;
import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementación de autenticación local con PBKDF2 (RF-AUTH).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDatasource _local;

  static const int _passwordMinimo = 6;
  static const int _usernameMinimo = 3;

  Usuario _aEntidad(db.Usuario row) => Usuario(
    id: row.id,
    negocioId: row.negocioId,
    nombre: row.nombre,
    username: row.username,
    rol: row.rol,
    activo: row.activo,
  );

  @override
  Future<bool> hayNegocioRegistrado() => _local.hayNegocio();

  @override
  Future<Result<Usuario>> registrarNegocioYAdmin({
    required String nombreNegocio,
    String? identificacion,
    String? direccion,
    String? telefono,
    String? email,
    required String nombreAdmin,
    required String username,
    required String password,
  }) async {
    if (nombreNegocio.trim().isEmpty) {
      return const Result.fail(
        ValidationFailure('El nombre del negocio es obligatorio.'),
      );
    }
    if (nombreAdmin.trim().isEmpty) {
      return const Result.fail(
        ValidationFailure('El nombre del administrador es obligatorio.'),
      );
    }
    if (username.trim().length < _usernameMinimo) {
      return const Result.fail(
        ValidationFailure(
          'El usuario debe tener al menos $_usernameMinimo caracteres.',
        ),
      );
    }
    if (password.length < _passwordMinimo) {
      return const Result.fail(
        ValidationFailure(
          'La contraseña debe tener al menos $_passwordMinimo caracteres.',
        ),
      );
    }
    if (await hayNegocioRegistrado()) {
      return const Result.fail(
        BusinessRuleFailure(
          'Ya existe un negocio registrado en este dispositivo.',
        ),
      );
    }

    final negocioId = await _local.crearNegocio(
      nombre: nombreNegocio.trim(),
      identificacion: identificacion?.trim(),
      direccion: direccion?.trim(),
      telefono: telefono?.trim(),
      email: email?.trim(),
    );
    final salt = PasswordHasher.generarSalt();
    final hash = await PasswordHasher.hash(password, salt);
    final fila = await _local.crearUsuario(
      negocioId: negocioId,
      nombre: nombreAdmin.trim(),
      username: username.trim().toLowerCase(),
      passwordHash: hash,
      salt: salt,
      rol: RolUsuario.administrador,
    );
    return Result.ok(_aEntidad(fila));
  }

  @override
  Future<Result<Usuario>> login({
    required String username,
    required String password,
  }) async {
    final fila = await _local.obtenerPorUsername(username.trim().toLowerCase());
    if (fila == null || !fila.activo) {
      return const Result.fail(
        ValidationFailure('Usuario o contraseña incorrectos.'),
      );
    }
    final valido = await PasswordHasher.verificar(
      password: password,
      salt: fila.salt,
      hashEsperado: fila.passwordHash,
    );
    if (!valido) {
      return const Result.fail(
        ValidationFailure('Usuario o contraseña incorrectos.'),
      );
    }
    return Result.ok(_aEntidad(fila));
  }

  @override
  Future<Usuario?> obtenerUsuario(String id) async {
    final fila = await _local.obtenerPorId(id);
    return fila == null ? null : _aEntidad(fila);
  }

  @override
  Future<List<Usuario>> listarUsuarios() async {
    final filas = await _local.listar();
    return filas.map(_aEntidad).toList();
  }

  @override
  Future<Result<Usuario>> crearCajero({
    required String nombre,
    required String username,
    required String password,
    required String actorId,
  }) async {
    if (nombre.trim().isEmpty) {
      return const Result.fail(ValidationFailure('El nombre es obligatorio.'));
    }
    if (username.trim().length < _usernameMinimo) {
      return const Result.fail(
        ValidationFailure(
          'El usuario debe tener al menos $_usernameMinimo caracteres.',
        ),
      );
    }
    if (password.length < _passwordMinimo) {
      return const Result.fail(
        ValidationFailure(
          'La contraseña debe tener al menos $_passwordMinimo caracteres.',
        ),
      );
    }
    final usernameNormalizado = username.trim().toLowerCase();
    if (await _local.existeUsername(usernameNormalizado)) {
      return const Result.fail(
        ValidationFailure('Ya existe un usuario con ese nombre.'),
      );
    }
    final negocioId = await _local.obtenerNegocioId();
    final salt = PasswordHasher.generarSalt();
    final hash = await PasswordHasher.hash(password, salt);
    final fila = await _local.crearCajeroConAuditoria(
      negocioId: negocioId,
      nombre: nombre.trim(),
      username: usernameNormalizado,
      passwordHash: hash,
      salt: salt,
      actorId: actorId,
    );
    return Result.ok(_aEntidad(fila));
  }

  @override
  Future<Result<void>> resetearPassword({
    required String usuarioId,
    required String nuevaPassword,
    required String actorId,
  }) async {
    if (nuevaPassword.length < _passwordMinimo) {
      return const Result.fail(
        ValidationFailure(
          'La contraseña debe tener al menos $_passwordMinimo caracteres.',
        ),
      );
    }
    final salt = PasswordHasher.generarSalt();
    final hash = await PasswordHasher.hash(nuevaPassword, salt);
    await _local.actualizarPassword(
      usuarioId,
      hash,
      salt,
      actorId: actorId,
      accion: 'resetear_password',
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> cambiarPassword({
    required String usuarioId,
    required String actual,
    required String nueva,
  }) async {
    final fila = await _local.obtenerPorId(usuarioId);
    if (fila == null) {
      return const Result.fail(ValidationFailure('Usuario no encontrado.'));
    }
    final valido = await PasswordHasher.verificar(
      password: actual,
      salt: fila.salt,
      hashEsperado: fila.passwordHash,
    );
    if (!valido) {
      return const Result.fail(
        ValidationFailure('La contraseña actual no es correcta.'),
      );
    }
    if (nueva.length < _passwordMinimo) {
      return const Result.fail(
        ValidationFailure(
          'La nueva contraseña debe tener al menos $_passwordMinimo caracteres.',
        ),
      );
    }
    final salt = PasswordHasher.generarSalt();
    final hash = await PasswordHasher.hash(nueva, salt);
    await _local.actualizarPassword(
      usuarioId,
      hash,
      salt,
      actorId: usuarioId,
      accion: 'cambiar_password',
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> establecerActivo({
    required String usuarioId,
    required bool activo,
    required String actorId,
  }) async {
    if (!activo) {
      final fila = await _local.obtenerPorId(usuarioId);
      if (fila?.rol == RolUsuario.administrador) {
        final activos = await _local.contarAdministradoresActivos();
        if (activos <= 1) {
          return const Result.fail(
            BusinessRuleFailure(
              'No se puede desactivar al único administrador.',
            ),
          );
        }
      }
    }
    await _local.establecerActivo(usuarioId, activo, actorId: actorId);
    return const Result.ok(null);
  }
}
