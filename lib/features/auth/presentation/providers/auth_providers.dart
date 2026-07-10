import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' hide Usuario;
import '../../../../core/errors/result.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/session_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    AuthLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage();
});

/// Estado de sesión del negocio. El router encadena este guard después del
/// de licencia (RN-15: licencia → auth → rol).
sealed class EstadoSesion {
  const EstadoSesion();
}

/// Primer arranque tras activar la licencia: falta el wizard de registro
/// del negocio y del administrador.
final class SinNegocio extends EstadoSesion {
  const SinNegocio();
}

/// Hay negocio registrado pero ningún usuario con sesión activa.
final class SinSesion extends EstadoSesion {
  const SinSesion();
}

/// Usuario autenticado.
final class SesionActiva extends EstadoSesion {
  const SesionActiva(this.usuario);
  final Usuario usuario;
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, EstadoSesion>(AuthController.new);

class AuthController extends AsyncNotifier<EstadoSesion> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);
  SessionStorage get _session => ref.read(sessionStorageProvider);

  @override
  Future<EstadoSesion> build() async {
    if (!await _repo.hayNegocioRegistrado()) return const SinNegocio();

    final id = await _session.obtenerUsuarioId();
    if (id == null) return const SinSesion();

    final usuario = await _repo.obtenerUsuario(id);
    if (usuario == null || !usuario.activo) {
      await _session.borrar();
      return const SinSesion();
    }
    return SesionActiva(usuario);
  }

  /// Wizard de primer uso: registra el negocio y crea el Administrador.
  Future<Failure?> registrarNegocioYAdmin({
    required String nombreNegocio,
    String? identificacion,
    String? direccion,
    String? telefono,
    String? email,
    required String nombreAdmin,
    required String username,
    required String password,
  }) async {
    final result = await _repo.registrarNegocioYAdmin(
      nombreNegocio: nombreNegocio,
      identificacion: identificacion,
      direccion: direccion,
      telefono: telefono,
      email: email,
      nombreAdmin: nombreAdmin,
      username: username,
      password: password,
    );
    return result.when(
      ok: (usuario) async {
        await _session.guardarUsuarioId(usuario.id);
        state = AsyncData(SesionActiva(usuario));
        return null;
      },
      fail: (failure) async => failure,
    );
  }

  Future<Failure?> login({
    required String username,
    required String password,
  }) async {
    final result = await _repo.login(username: username, password: password);
    return result.when(
      ok: (usuario) async {
        await _session.guardarUsuarioId(usuario.id);
        state = AsyncData(SesionActiva(usuario));
        return null;
      },
      fail: (failure) async => failure,
    );
  }

  Future<void> logout() async {
    await _session.borrar();
    state = const AsyncData(SinSesion());
  }
}

/// Usuarios del negocio (incluye inactivos), para la pantalla de gestión.
final usuariosProvider = FutureProvider<List<Usuario>>((ref) {
  return ref.watch(authRepositoryProvider).listarUsuarios();
});

/// Solo usuarios activos, para el selector del login.
final usuariosActivosProvider = FutureProvider<List<Usuario>>((ref) async {
  final usuarios = await ref.watch(usuariosProvider.future);
  return usuarios.where((u) => u.activo).toList();
});
