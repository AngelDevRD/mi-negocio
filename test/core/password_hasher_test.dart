import 'package:app_gestion/core/utils/password_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordHasher', () {
    test('genera salts distintas en cada llamada', () {
      final salt1 = PasswordHasher.generarSalt();
      final salt2 = PasswordHasher.generarSalt();
      expect(salt1, isNot(equals(salt2)));
    });

    test('hash es determinista con la misma salt', () async {
      final salt = PasswordHasher.generarSalt();
      final hash1 = await PasswordHasher.hash('miPassword123', salt);
      final hash2 = await PasswordHasher.hash('miPassword123', salt);
      expect(hash1, equals(hash2));
    });

    test(
      'salts distintas producen hashes distintos para la misma password',
      () async {
        final salt1 = PasswordHasher.generarSalt();
        final salt2 = PasswordHasher.generarSalt();
        final hash1 = await PasswordHasher.hash('miPassword123', salt1);
        final hash2 = await PasswordHasher.hash('miPassword123', salt2);
        expect(hash1, isNot(equals(hash2)));
      },
    );

    test('verificar devuelve true con la contraseña correcta', () async {
      final salt = PasswordHasher.generarSalt();
      final hash = await PasswordHasher.hash('correcta123', salt);
      final ok = await PasswordHasher.verificar(
        password: 'correcta123',
        salt: salt,
        hashEsperado: hash,
      );
      expect(ok, isTrue);
    });

    test('verificar devuelve false con la contraseña incorrecta', () async {
      final salt = PasswordHasher.generarSalt();
      final hash = await PasswordHasher.hash('correcta123', salt);
      final ok = await PasswordHasher.verificar(
        password: 'incorrecta456',
        salt: salt,
        hashEsperado: hash,
      );
      expect(ok, isFalse);
    });
  });
}
