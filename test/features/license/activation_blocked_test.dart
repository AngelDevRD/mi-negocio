import 'dart:async';

import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/router/app_router.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:app_gestion/features/license/presentation/providers/license_providers.dart';
import 'package:app_gestion/features/license/presentation/screens/activation_screen.dart';
import 'package:app_gestion/features/license/presentation/screens/blocked_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Licencia en memoria: cuenta llamadas y puede fallar, lanzar o esperar.
class _LicenciaFalsa extends LicenseController {
  _LicenciaFalsa({this.inicial});

  final LicenseCheck? inicial;

  Completer<void>? bloqueo;
  Failure? fallo;
  Object? lanzar;
  int demos = 0;
  int claves = 0;
  int solicitudes = 0;
  int revalidaciones = 0;
  String? ultimaClave;
  LicenseCheck? trasRevalidar;

  @override
  Future<LicenseCheck> build() async => inicial ?? const SinLicencia();

  @override
  Future<Failure?> activarDemo() async {
    demos++;
    await bloqueo?.future;
    if (lanzar != null) throw lanzar!;
    return fallo;
  }

  @override
  Future<Failure?> activarConClave(String clave) async {
    claves++;
    ultimaClave = clave;
    await bloqueo?.future;
    if (lanzar != null) throw lanzar!;
    return fallo;
  }

  @override
  Future<(String?, Failure?)> solicitar({
    required String nombreNegocio,
    String? telefono,
    required String tipoDeseado,
  }) async {
    solicitudes++;
    await bloqueo?.future;
    if (lanzar != null) throw lanzar!;
    return fallo == null ? ('Solicitud enviada.', null) : (null, fallo);
  }

  @override
  Future<void> revalidar() async {
    revalidaciones++;
    if (lanzar != null) throw lanzar!;
    state = const AsyncLoading();
    await bloqueo?.future;
    state = AsyncData(trasRevalidar ?? const LicenciaBloqueada('Vencida.'));
  }
}

Future<_LicenciaFalsa> _montar(
  WidgetTester tester,
  Widget pantalla, {
  LicenseCheck? inicial,
  Size tamano = const Size(420, 1000),
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final licencia = _LicenciaFalsa(inicial: inicial);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => pantalla),
      GoRoute(
        path: AppRoutes.licenseActivation,
        builder: (_, _) => const Scaffold(body: Text('pantalla activación')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        licenseControllerProvider.overrideWith(() => licencia),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(licenseControllerProvider.future);
  await tester.pumpAndSettle();
  return licencia;
}

void main() {
  group('activación', () {
    testWidgets('muestra el nombre único "MiTienda 360" y las dos opciones', (
      tester,
    ) async {
      await _montar(tester, const ActivationScreen());

      expect(find.text('MiTienda 360'), findsOneWidget);
      expect(find.text('App Gestión Negocios'), findsNothing);
      expect(find.text('Activar licencia'), findsOneWidget);
      expect(find.text('Comenzar prueba gratis'), findsOneWidget);
    });

    testWidgets('demo: doble toque = UNA activación, con progreso y botones '
        'deshabilitados', (tester) async {
      final e = await _montar(tester, const ActivationScreen());
      e.bloqueo = Completer<void>();

      final demo = find.widgetWithText(
        OutlinedButton,
        'Comenzar prueba gratis',
      );
      await tester.tap(demo);
      await tester.tap(demo, warnIfMissed: false);
      await tester.pump();

      expect(e.demos, 1);
      expect(find.text('Preparando tu prueba gratis...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.widget<OutlinedButton>(demo).onPressed, isNull);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Activar licencia'),
            )
            .onPressed,
        isNull,
      );

      e.bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(e.demos, 1);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('clave: Enter envía y el fallo sale en un snackbar de error', (
      tester,
    ) async {
      final e = await _montar(tester, const ActivationScreen());
      e.fallo = const LicenseFailure('La clave no es válida.');

      await tester.enterText(find.byType(TextField), 'abc-123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(e.claves, 1);
      expect(e.ultimaClave, 'abc-123');
      expect(find.text('La clave no es válida.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('una excepción inesperada: mensaje genérico, sin detalles '
        'técnicos', (tester) async {
      final e = await _montar(tester, const ActivationScreen());
      e.lanzar = StateError('SocketException: host lookup 10.0.0.1');

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Comenzar prueba gratis'),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No se pudo completar la operación. Inténtalo de nuevo.'),
        findsOneWidget,
      );
      expect(find.textContaining('SocketException'), findsNothing);
      expect(find.textContaining('10.0.0.1'), findsNothing);
      // La pantalla queda usable.
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Comenzar prueba gratis'),
            )
            .onPressed,
        isNotNull,
      );
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('solicitar licencia: valida el nombre, un solo envío y avisa', (
      tester,
    ) async {
      final e = await _montar(tester, const ActivationScreen());

      await tester.tap(find.text('¿No tienes licencia? Solicítala aquí'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Enviar solicitud'));
      await tester.pump();
      expect(find.text('Escribe el nombre de tu negocio'), findsOneWidget);
      expect(e.solicitudes, 0);

      e.bloqueo = Completer<void>();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre del negocio'),
        'Colmado Carmen',
      );
      final enviar = find.widgetWithText(FilledButton, 'Enviar solicitud');
      await tester.tap(enviar);
      await tester.tap(enviar, warnIfMissed: false);
      await tester.pump();
      expect(e.solicitudes, 1);

      e.bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Solicitud enviada.'), findsOneWidget);
      expect(find.text('Solicitar licencia'), findsNothing); // se cerró
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('solicitar con fallo: el formulario sigue abierto', (
      tester,
    ) async {
      final e = await _montar(tester, const ActivationScreen());
      e.fallo = const NetworkFailure(
        'Se necesita conexión a internet para enviar la solicitud.',
      );

      await tester.tap(find.text('¿No tienes licencia? Solicítala aquí'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre del negocio'),
        'Colmado Carmen',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Enviar solicitud'));
      await tester.pumpAndSettle();

      expect(
        find.text('Se necesita conexión a internet para enviar la solicitud.'),
        findsOneWidget,
      );
      expect(find.text('Solicitar licencia'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('pantalla bloqueada', () {
    const bloqueada = LicenciaBloqueada('Tu licencia está suspendida.');

    testWidgets('dice por qué, tranquiliza sobre los datos y ofrece las '
        'salidas', (tester) async {
      await _montar(tester, const BlockedScreen(), inicial: bloqueada);

      expect(find.text('Acceso bloqueado'), findsOneWidget);
      expect(find.text('Tu licencia está suspendida.'), findsOneWidget);
      expect(find.textContaining('Tus datos están guardados'), findsOneWidget);
      expect(find.text('Reintentar validación'), findsOneWidget);
      expect(find.text('Activar otra licencia'), findsOneWidget);
    });

    testWidgets('reintentar: doble toque = UNA validación, con estado '
        '"Validando..."', (tester) async {
      final e = await _montar(
        tester,
        const BlockedScreen(),
        inicial: bloqueada,
      );
      e.bloqueo = Completer<void>();

      await tester.tap(find.text('Reintentar validación'));
      await tester.pump();
      expect(find.text('Validando...'), findsOneWidget);
      await tester.tap(find.text('Validando...'), warnIfMissed: false);
      await tester.pump();
      expect(e.revalidaciones, 1);

      e.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(e.revalidaciones, 1);
      // Sigue bloqueada: se avisa en vez de quedarse callado.
      expect(
        find.textContaining('La licencia sigue sin estar activa'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('si la validación lanza: mensaje humano y la pantalla no '
        'queda trabada', (tester) async {
      final e = await _montar(
        tester,
        const BlockedScreen(),
        inicial: bloqueada,
      );
      e.lanzar = StateError('Connection refused 10.0.0.1:443');

      await tester.tap(find.text('Reintentar validación'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('No se pudo validar la licencia'),
        findsOneWidget,
      );
      expect(find.textContaining('10.0.0.1'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('"Activar otra licencia" lleva a la activación', (
      tester,
    ) async {
      await _montar(tester, const BlockedScreen(), inicial: bloqueada);

      await tester.tap(find.text('Activar otra licencia'));
      await tester.pumpAndSettle();

      expect(find.text('pantalla activación'), findsOneWidget);
    });

    testWidgets('teléfono angosto con texto grande: sin desbordes', (
      tester,
    ) async {
      await _montar(
        tester,
        const BlockedScreen(),
        inicial: bloqueada,
        tamano: const Size(320, 480),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Reintentar validación'), findsOneWidget);
    });
  });
}
