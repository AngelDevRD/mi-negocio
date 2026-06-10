import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/features/license/data/datasources/license_local_datasource.dart';
import 'package:app_gestion/features/license/data/datasources/license_remote_datasource.dart';
import 'package:app_gestion/features/license/data/repositories/license_repository_impl.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Remoto simulado: respuestas programables por test.
class FakeRemote implements LicenseRemoteDatasource {
  FakeRemote({this.disponible = true});

  @override
  bool disponible;

  RemoteLicenseResponse? respuestaValidar;
  RemoteLicenseResponse? respuestaActivar;
  bool lanzarErrorDeRed = false;

  @override
  Future<RemoteLicenseResponse> validar({
    required String clave,
    required String deviceId,
  }) async {
    if (lanzarErrorDeRed) throw Exception('sin red');
    return respuestaValidar!;
  }

  @override
  Future<RemoteLicenseResponse> activar({
    required String clave,
    required String deviceId,
  }) async {
    if (lanzarErrorDeRed) throw Exception('sin red');
    return respuestaActivar!;
  }

  @override
  Future<RemoteLicenseResponse> solicitar({
    required String nombreNegocio,
    required String emailAdmin,
    String? telefono,
    required String deviceId,
    required String tipoDeseado,
  }) async {
    return const RemoteLicenseResponse(ok: true, mensaje: 'Solicitud enviada.');
  }
}

void main() {
  late AppDatabase db;
  late LicenseLocalDatasource local;
  late FakeRemote remote;
  late DateTime ahora;
  late bool online;

  LicenseRepositoryImpl crearRepo() {
    return LicenseRepositoryImpl(
      local: local,
      remote: remote,
      deviceId: () async => 'device-test-1',
      isOnline: () async => online,
      now: () => ahora,
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    local = LicenseLocalDatasource(db);
    remote = FakeRemote();
    ahora = DateTime.utc(2026, 6, 10);
    online = false;
  });

  tearDown(() async {
    await db.close();
  });

  group('Sin licencia', () {
    test('arranque sin caché devuelve SinLicencia', () async {
      final check = await crearRepo().verificarAlArranque();
      expect(check, isA<SinLicencia>());
    });
  });

  group('Demo (RN-17)', () {
    test('activar demo concede 15 días y queda activa', () async {
      final repo = crearRepo();
      final result = await repo.activarDemo();

      expect(result.isOk, isTrue);
      final licencia = result.valueOrNull!;
      expect(licencia.tipo, TipoLicencia.demo);
      expect(licencia.fechaVencimiento, ahora.add(const Duration(days: 15)));

      expect(await repo.verificarAlArranque(), isA<LicenciaActiva>());
    });

    test('demo vencida bloquea y conserva los datos', () async {
      final repo = crearRepo();
      await repo.activarDemo();

      ahora = ahora.add(const Duration(days: 16));
      final check = await crearRepo().verificarAlArranque();

      expect(check, isA<LicenciaBloqueada>());
      expect((check as LicenciaBloqueada).motivo, contains('15 días'));
    });

    test(
      'la demo no puede activarse dos veces en el mismo dispositivo',
      () async {
        final repo = crearRepo();
        await repo.activarDemo();
        ahora = ahora.add(const Duration(days: 20));

        final segunda = await crearRepo().activarDemo();

        expect(segunda.isOk, isFalse);
      },
    );
  });

  group('Período de gracia offline (RN-16)', () {
    Future<void> guardarLicenciaLocal({required DateTime ultimaValidacion}) {
      return local.guardar(
        Licencia(
          tipo: TipoLicencia.local,
          estado: EstadoLicencia.activa,
          clave: 'CLAVE-1',
          deviceId: 'device-test-1',
          fechaActivacion: DateTime.utc(2026),
          ultimaValidacion: ultimaValidacion,
        ),
      );
    }

    test('offline dentro de 7 días sin validar → activa', () async {
      await guardarLicenciaLocal(
        ultimaValidacion: ahora.subtract(const Duration(days: 3)),
      );
      online = false;

      expect(await crearRepo().verificarAlArranque(), isA<LicenciaActiva>());
    });

    test('offline con más de 7 días sin validar → bloqueada', () async {
      await guardarLicenciaLocal(
        ultimaValidacion: ahora.subtract(const Duration(days: 8)),
      );
      online = false;

      final check = await crearRepo().verificarAlArranque();
      expect(check, isA<LicenciaBloqueada>());
      expect((check as LicenciaBloqueada).motivo, contains('internet'));
    });

    test('error de red cae al período de gracia (no bloquea)', () async {
      await guardarLicenciaLocal(
        ultimaValidacion: ahora.subtract(const Duration(days: 2)),
      );
      online = true;
      remote.lanzarErrorDeRed = true;

      expect(await crearRepo().verificarAlArranque(), isA<LicenciaActiva>());
    });
  });

  group('Validación remota (RF-LIC-04/05)', () {
    test('servidor reporta suspendida → bloquea y actualiza caché', () async {
      await local.guardar(
        Licencia(
          tipo: TipoLicencia.local,
          estado: EstadoLicencia.activa,
          clave: 'CLAVE-1',
          deviceId: 'device-test-1',
          fechaActivacion: DateTime.utc(2026),
          ultimaValidacion: ahora.subtract(const Duration(days: 1)),
        ),
      );
      online = true;
      remote.respuestaValidar = const RemoteLicenseResponse(
        ok: true,
        licencia: RemoteLicenseDto(
          clave: 'CLAVE-1',
          tipo: TipoLicencia.local,
          estado: EstadoLicencia.suspendida,
          motivoSuspension: 'falta de pago',
        ),
      );

      final check = await crearRepo().verificarAlArranque();

      expect(check, isA<LicenciaBloqueada>());
      expect((check as LicenciaBloqueada).motivo, contains('falta de pago'));
      // La caché quedó suspendida: el bloqueo persiste aun offline.
      final cache = await local.obtener();
      expect(cache!.estado, EstadoLicencia.suspendida);
    });

    test('activar con clave guarda la licencia en caché', () async {
      online = true;
      remote.respuestaActivar = RemoteLicenseResponse(
        ok: true,
        licencia: RemoteLicenseDto(
          clave: 'CLAVE-9',
          tipo: TipoLicencia.nube,
          estado: EstadoLicencia.activa,
          fechaVencimiento: ahora.add(const Duration(days: 365)),
        ),
      );

      final result = await crearRepo().activarConClave('CLAVE-9');

      expect(result.isOk, isTrue);
      final cache = await local.obtener();
      expect(cache!.tipo, TipoLicencia.nube);
      expect(cache.clave, 'CLAVE-9');
    });

    test('activar sin internet falla con NetworkFailure', () async {
      online = false;

      final result = await crearRepo().activarConClave('CLAVE-9');

      expect(result.isOk, isFalse);
      expect((result as Fail).failure, isA<NetworkFailure>());
    });

    test('sin Supabase configurado la activación remota falla claro', () async {
      remote.disponible = false;
      online = true;

      final result = await crearRepo().activarConClave('CLAVE-9');

      expect(result.isOk, isFalse);
      expect((result as Fail).failure.message, contains('no está configurado'));
    });
  });
}
