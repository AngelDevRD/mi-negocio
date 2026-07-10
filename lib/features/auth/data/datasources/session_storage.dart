import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persiste el id del usuario con sesión activa (RF-AUTH: la sesión
/// sobrevive a reinicios de la app).
class SessionStorage {
  SessionStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _claveUsuarioId = 'sesion_usuario_id';

  Future<void> guardarUsuarioId(String id) =>
      _storage.write(key: _claveUsuarioId, value: id);

  Future<String?> obtenerUsuarioId() => _storage.read(key: _claveUsuarioId);

  Future<void> borrar() => _storage.delete(key: _claveUsuarioId);
}
