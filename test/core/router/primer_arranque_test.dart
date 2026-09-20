import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/router/app_router.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/auth/data/datasources/session_storage.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:app_gestion/features/license/presentation/providers/license_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Arranque en frío: SIN licencia y SIN base de datos previa (base vacía en
/// memoria). Recorre el camino real del router y de los controladores:
/// activación → configuración inicial → Inicio → cerrar sesión → login → Inicio.
class _LicenciaEnFrio extends LicenseController {
  @override
  Future<LicenseCheck> build() async => const SinLicencia();

  @override
  Future<Failure?> activarDemo() async {
    state = AsyncData(
      LicenciaActiva(
        Licencia(
          tipo: TipoLicencia.demo,
          estado: EstadoLicencia.activa,
          deviceId: 'dispositivo-de-prueba',
          fechaActivacion: DateTime.now(),
          ultimaValidacion: DateTime.now(),
          fechaVencimiento: DateTime.now().add(const Duration(days: 15)),
        ),
      ),
    );
    return null;
  }
}

/// Sesión guardada en memoria (el real usa el almacén seguro del sistema).
class _SesionEnMemoria implements SessionStorage {
  String? id;

  @override
  Future<void> guardarUsuarioId(String id) async => this.id = id;

  @override
  Future<String?> obtenerUsuarioId() async => id;

  @override
  Future<void> borrar() async => id = null;
}

/// Deja correr el trabajo real (base de datos, PBKDF2) y los cuadros hasta que
/// [condicion] se cumpla.
Future<void> _esperar(
  WidgetTester tester,
  bool Function() condicion, {
  String motivo = 'la condición',
}) async {
  for (var i = 0; i < 400 && !condicion(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(condicion(), isTrue, reason: 'No se cumplió: $motivo');
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('desde cero: activación → configuración inicial → Inicio → '
      'cerrar sesión → login → Inicio', (tester) async {
    tester.view.physicalSize = const Size(420, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      // Cierra fuera del reloj falso; los flujos de Drift siguen activos.
      await tester.runAsync(db.close);
    });
    final sesion = _SesionEnMemoria();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(db),
          sessionStorageProvider.overrideWithValue(sesion),
          licenseControllerProvider.overrideWith(_LicenciaEnFrio.new),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: ref.watch(appRouterProvider),
          ),
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );

    // 1. Sin licencia: pantalla de activación.
    await _esperar(
      tester,
      () => find.text('Comenzar prueba gratis').evaluate().isNotEmpty,
      motivo: 'pantalla de activación',
    );
    expect(find.text('MiTienda 360'), findsOneWidget);

    // 2. Demo → sin negocio registrado: configuración inicial.
    await tester.tap(find.text('Comenzar prueba gratis'));
    await _esperar(
      tester,
      () => find.text('Configuración inicial').evaluate().isNotEmpty,
      motivo: 'configuración inicial',
    );
    expect(await tester.runAsync(() => db.select(db.usuarios).get()), isEmpty);

    // 3. Registrar negocio y administrador → Inicio.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre del negocio'),
      'Colmado Doña Carmen',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tu nombre'),
      'Carmen Rodríguez',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'clave-segura',
    );
    final crear = find.widgetWithText(FilledButton, 'Crear negocio y comenzar');
    await tester.ensureVisible(crear);
    await tester.tap(crear);
    await _esperar(
      tester,
      () => find.textContaining('Hola, Carmen').evaluate().isNotEmpty,
      motivo: 'Inicio tras crear el negocio',
    );
    expect(find.text('Inicio'), findsWidgets);
    expect(
      container.read(authControllerProvider).value,
      isA<SesionActiva>(),
      reason: 'el negocio recién creado deja la sesión abierta',
    );
    final usuarios = await tester.runAsync(() => db.select(db.usuarios).get());
    expect(usuarios, hasLength(1));
    expect(usuarios!.single.rol, RolUsuario.administrador);
    // Nunca se guarda la contraseña en claro.
    expect(usuarios.single.passwordHash, isNot('clave-segura'));

    // 4. Cerrar sesión → login.
    await container.read(authControllerProvider.notifier).logout();
    await _esperar(
      tester,
      () => find.text('Inicia sesión para continuar').evaluate().isNotEmpty,
      motivo: 'pantalla de login',
    );
    // Deja terminar la transición: mientras dura, conviven dos rutas.
    await tester.pump(const Duration(seconds: 1));

    // 5. Contraseña mala: mensaje genérico y sigue en el login.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'incorrecta',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await _esperar(
      tester,
      () =>
          find.text('Usuario o contraseña incorrectos.').evaluate().isNotEmpty,
      motivo: 'mensaje de credenciales inválidas',
    );
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);

    // 6. Contraseña correcta → Inicio otra vez.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'clave-segura',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await _esperar(
      tester,
      () => find.textContaining('Hola, Carmen').evaluate().isNotEmpty,
      motivo: 'Inicio tras el login',
    );
    await tester.pump(const Duration(seconds: 1)); // fin de la transición
    expect(find.text('Inicia sesión para continuar'), findsNothing);

    // Desmonta la app y deja que Drift cierre sus flujos (temporizadores de 0 s).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
