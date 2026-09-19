import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_gestion/features/auth/data/limitador_intentos_login.dart';
import 'package:app_gestion/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Duration ahora;
  late LimitadorIntentosLogin limitador;

  setUp(() {
    ahora = Duration.zero;
    limitador = LimitadorIntentosLogin(reloj: () => ahora);
  });

  void fallar(String usuario, int veces) {
    for (var i = 0; i < veces; i++) {
      limitador.registrarFallo(usuario);
    }
  }

  group('LimitadorIntentosLogin', () {
    test('los primeros 4 fallos no bloquean', () {
      fallar('ana', 4);
      expect(limitador.esperaRestante('ana'), isNull);
    });

    test('el 5.º fallo bloquea 30 segundos', () {
      fallar('ana', 4);
      expect(limitador.registrarFallo('ana'), const Duration(seconds: 30));
      expect(limitador.esperaRestante('ana'), const Duration(seconds: 30));
    });

    test('la espera baja con el reloj y termina a los 30 s', () {
      fallar('ana', 5);

      ahora = const Duration(seconds: 10);
      expect(limitador.esperaRestante('ana'), const Duration(seconds: 20));

      ahora = const Duration(milliseconds: 29500);
      expect(limitador.esperaRestante('ana'), const Duration(seconds: 1));

      ahora = const Duration(seconds: 30);
      expect(limitador.esperaRestante('ana'), isNull);
    });

    test('cada fallo adicional duplica la espera: 30, 60, 120, 240 y '
        'tope de 300 s', () {
      final esperas = <int>[];
      for (var i = 0; i < 9; i++) {
        final espera = limitador.registrarFallo('ana');
        if (espera != null) {
          esperas.add(espera.inSeconds);
          ahora += espera; // cumple la espera y vuelve a fallar
        }
      }
      expect(esperas, [30, 60, 120, 240, 300]);

      // Sigue en el tope, no crece más.
      expect(limitador.registrarFallo('ana'), const Duration(minutes: 5));
      expect(limitador.registrarFallo('ana'), const Duration(minutes: 5));
    });

    test('un login correcto reinicia el contador', () {
      fallar('ana', 4);
      limitador.reiniciar('ana');

      // Otros 4 fallos: sigue sin bloquear (el contador empezó de cero).
      fallar('ana', 4);
      expect(limitador.esperaRestante('ana'), isNull);
      expect(limitador.registrarFallo('ana'), const Duration(seconds: 30));
    });

    test('reiniciar levanta un bloqueo vigente', () {
      fallar('ana', 5);
      limitador.reiniciar('ana');
      expect(limitador.esperaRestante('ana'), isNull);
    });

    test('el bloqueo es por usuario: otro usuario no se ve afectado', () {
      fallar('ana', 5);
      expect(limitador.esperaRestante('ana'), isNotNull);
      expect(limitador.esperaRestante('carlos'), isNull);
      fallar('carlos', 4);
      expect(limitador.esperaRestante('carlos'), isNull);
    });

    test('el reloj por defecto es monotónico y arranca sin bloqueos', () {
      final real = LimitadorIntentosLogin();
      expect(real.esperaRestante('ana'), isNull);
      for (var i = 0; i < 5; i++) {
        real.registrarFallo('ana');
      }
      expect(real.esperaRestante('ana'), isNotNull);
    });
  });

  group('AuthRepositoryImpl.login con límite de intentos', () {
    late AppDatabase db;
    late AuthRepositoryImpl repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = AuthRepositoryImpl(AuthLocalDatasource(db), limitador: limitador);
      final registro = await repo.registrarNegocioYAdmin(
        nombreNegocio: 'Colmado Pérez',
        nombreAdmin: 'Juan Pérez',
        username: 'admin',
        password: 'admin123',
      );
      expect(registro.isOk, isTrue);
      final cajero = await repo.crearCajero(
        nombre: 'Carla',
        username: 'carla',
        password: 'carla123',
        actorId: registro.valueOrNull!.id,
      );
      expect(cajero.isOk, isTrue);
    });

    tearDown(() => db.close());

    Future<Failure?> intentar(String username, String password) async {
      final r = await repo.login(username: username, password: password);
      return r.when(ok: (_) => null, fail: (f) => f);
    }

    test('4 fallos dan el mensaje genérico; el 5.º bloquea 30 s', () async {
      for (var i = 0; i < 4; i++) {
        final f = await intentar('admin', 'mala$i');
        expect(f, isA<ValidationFailure>());
        expect(f!.message, 'Usuario o contraseña incorrectos.');
      }
      final quinto = await intentar('admin', 'mala5');
      expect(quinto, isA<DemasiadosIntentosFailure>());
      expect((quinto as DemasiadosIntentosFailure).segundos, 30);
      expect(quinto.message, 'Demasiados intentos. Espera 30 segundos.');
    });

    test('bloqueado: ni la contraseña CORRECTA entra hasta que pase la '
        'espera', () async {
      for (var i = 0; i < 5; i++) {
        await intentar('admin', 'mala');
      }

      ahora = const Duration(seconds: 12);
      final durante = await intentar('admin', 'admin123');
      expect(durante, isA<DemasiadosIntentosFailure>());
      expect((durante as DemasiadosIntentosFailure).segundos, 18);

      ahora = const Duration(seconds: 30);
      expect(await intentar('admin', 'admin123'), isNull);
    });

    test('un intento durante el bloqueo no agrava la espera', () async {
      for (var i = 0; i < 5; i++) {
        await intentar('admin', 'mala');
      }
      await intentar('admin', 'mala');
      await intentar('admin', 'mala');

      ahora = const Duration(seconds: 30);
      // Si hubiera sumado fallos, la espera ya sería mayor y seguiría bloqueado.
      expect(await intentar('admin', 'admin123'), isNull);
    });

    test('la espera crece: 30 → 60 → 120 s en los fallos siguientes', () async {
      final esperas = <int>[];
      for (var i = 0; i < 7; i++) {
        final f = await intentar('admin', 'mala');
        if (f is DemasiadosIntentosFailure) {
          esperas.add(f.segundos);
          ahora += Duration(seconds: f.segundos);
        }
      }
      expect(esperas, [30, 60, 120]);
    });

    test('un login correcto reinicia el contador', () async {
      for (var i = 0; i < 4; i++) {
        await intentar('admin', 'mala');
      }
      expect(await intentar('admin', 'admin123'), isNull);

      // Vuelve a tener 4 intentos libres.
      for (var i = 0; i < 4; i++) {
        expect(await intentar('admin', 'mala'), isA<ValidationFailure>());
      }
      expect(await intentar('admin', 'mala'), isA<DemasiadosIntentosFailure>());
    });

    test('el bloqueo es por usuario y no distingue mayúsculas ni '
        'espacios', () async {
      for (var i = 0; i < 5; i++) {
        await intentar(' ADMIN ', 'mala');
      }
      expect(
        await intentar('admin', 'admin123'),
        isA<DemasiadosIntentosFailure>(),
      );
      // Otro usuario entra sin problema.
      expect(await intentar('carla', 'carla123'), isNull);
    });

    test('un usuario inexistente también cuenta (no se puede sondear '
        'sin límite)', () async {
      for (var i = 0; i < 5; i++) {
        await intentar('fantasma', 'x');
      }
      final f = await intentar('fantasma', 'x');
      expect(f, isA<DemasiadosIntentosFailure>());
    });

    test('singular: "Espera 1 segundo."', () {
      expect(
        DemasiadosIntentosFailure(1).message,
        'Demasiados intentos. Espera 1 segundo.',
      );
    });
  });
}
