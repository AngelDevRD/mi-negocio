
import 'app_database.dart';

/// El usuario que intenta la operación no es Administrador (o no existe).
/// Se lanza DENTRO de la transacción, antes de escribir nada: la operación se
/// revierte completa y el repositorio la traduce a un `PermissionFailure`.
class SinPermisoException implements Exception {
  const SinPermisoException();
}

/// `true` si [usuarioId] existe, está ACTIVO y su rol guardado es
/// Administrador. Un administrador dado de baja pierde todo permiso.
///
/// Defensa en profundidad: la UI ya oculta las acciones solo-Administrador,
/// pero el dominio no debe fiarse de eso. Se lee el rol de la BASE (no el que
/// diga quien llama) y hay que invocarlo como PRIMERA lectura dentro de la
/// transacción de la operación.
Future<bool> esAdministrador(AppDatabase db, String usuarioId) async {
  final usuario = await (db.select(
    db.usuarios,
  )..where((t) => t.id.equals(usuarioId))).getSingleOrNull();
  return usuario != null &&
      usuario.activo &&
      usuario.rol == RolUsuario.administrador;
}

/// Lanza [SinPermisoException] si [usuarioId] no es Administrador.
Future<void> exigirAdministrador(AppDatabase db, String usuarioId) async {
  if (!await esAdministrador(db, usuarioId)) throw const SinPermisoException();
}
