import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/router/app_router.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:app_gestion/features/license/presentation/providers/license_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _LicenciaFija extends LicenseController {
  _LicenciaFija(this._check);

  final LicenseCheck _check;

  @override
  Future<LicenseCheck> build() async => _check;
}

class _SesionFija extends AuthController {
  _SesionFija(this._estado);

  final EstadoSesion _estado;

  @override
  Future<EstadoSesion> build() async => _estado;
}

Usuario _usuario(RolUsuario rol) => Usuario(
  id: 'u1',
  negocioId: 'n1',
  nombre: 'Usuario',
  username: 'usuario',
  rol: rol,
  activo: true,
);

final _licenciaActiva = LicenciaActiva(
  Licencia(
    tipo: TipoLicencia.demo,
    estado: EstadoLicencia.activa,
    deviceId: 'dispositivo',
    fechaActivacion: DateTime(2026),
    ultimaValidacion: DateTime(2026),
  ),
);

/// Resuelve [destino] a través del redirect real del router (licencia →
/// negocio → sesión → rol) y devuelve la ruta final, sin construir ninguna
/// pantalla.
Future<String> _resolver(
  WidgetTester tester,
  String destino, {
  required EstadoSesion sesion,
}) async {
  final container = ProviderContainer(
    overrides: [
      licenseControllerProvider.overrideWith(
        () => _LicenciaFija(_licenciaActiva),
      ),
      authControllerProvider.overrideWith(() => _SesionFija(sesion)),
    ],
  );
  addTearDown(container.dispose);

  // El redirect lee ambos controladores: hay que esperar a que resuelvan,
  // o el guard de licencia manda a /splash mientras cargan.
  await container.read(licenseControllerProvider.future);
  await container.read(authControllerProvider.future);
  final router = container.read(appRouterProvider);

  late BuildContext contexto;
  await tester.pumpWidget(
    Builder(
      builder: (context) {
        contexto = context;
        return const SizedBox.shrink();
      },
    ),
  );

  final coincidencia = await router.routeInformationParser
      .parseRouteInformationWithDependencies(
        RouteInformation(uri: Uri.parse(destino)),
        contexto,
      );
  return coincidencia.uri.path;
}

void main() {
  group('cajero', () {
    final sesion = SesionActiva(_usuario(RolUsuario.cajero));

    for (final ruta in ['/empleados', '/analisis', '/usuarios', '/auditoria']) {
      testWidgets('$ruta termina en /', (tester) async {
        expect(await _resolver(tester, ruta, sesion: sesion), '/');
      });
    }

    for (final ruta in ['/', '/ventas', '/caja', '/productos', '/mas']) {
      testWidgets('$ruta es accesible (las 5 raíces del shell)', (
        tester,
      ) async {
        expect(await _resolver(tester, ruta, sesion: sesion), ruta);
      });
    }
  });

  group('administrador', () {
    final sesion = SesionActiva(_usuario(RolUsuario.administrador));

    for (final ruta in ['/empleados', '/analisis', '/mas']) {
      testWidgets('$ruta es accesible', (tester) async {
        expect(await _resolver(tester, ruta, sesion: sesion), ruta);
      });
    }

    testWidgets('/login con sesión activa redirige a /', (tester) async {
      expect(await _resolver(tester, '/login', sesion: sesion), '/');
    });
  });

  group('sin sesión', () {
    for (final ruta in [
      '/',
      '/ventas',
      '/caja',
      '/productos',
      '/mas',
      '/empleados',
      '/analisis',
    ]) {
      testWidgets('$ruta termina en /login', (tester) async {
        expect(
          await _resolver(tester, ruta, sesion: const SinSesion()),
          '/login',
        );
      });
    }
  });
}
