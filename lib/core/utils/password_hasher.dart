import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Hash de contraseñas con PBKDF2-HMAC-SHA256 (AG-CORE-004: nunca texto
/// plano). Cada usuario guarda su propia `salt` aleatoria.
abstract final class PasswordHasher {
  static const int _iteraciones = 120000;
  static const int _bits = 256;

  /// Genera una salt aleatoria codificada en base64url.
  static String generarSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Deriva el hash PBKDF2 de [password] con la [salt] dada.
  static Future<String> hash(String password, String salt) async {
    final algoritmo = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iteraciones,
      bits: _bits,
    );
    final clave = await algoritmo.deriveKeyFromPassword(
      password: password,
      nonce: base64Url.decode(salt),
    );
    final bytes = await clave.extractBytes();
    return base64Url.encode(bytes);
  }

  /// Verifica [password] contra [hashEsperado] usando la [salt] guardada.
  static Future<bool> verificar({
    required String password,
    required String salt,
    required String hashEsperado,
  }) async {
    final calculado = await hash(password, salt);
    return _comparacionSegura(calculado, hashEsperado);
  }

  /// Comparación en tiempo constante para evitar ataques de temporización.
  static bool _comparacionSegura(String a, String b) {
    if (a.length != b.length) return false;
    var diferencia = 0;
    for (var i = 0; i < a.length; i++) {
      diferencia |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diferencia == 0;
  }
}
