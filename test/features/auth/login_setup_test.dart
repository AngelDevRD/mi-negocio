import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/auth/presentation/screens/login_screen.dart';
import 'package:app_gestion/features/auth/presentation/screens/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

const _ana = Usuario(
  id: 'u1',
  negocioId: 'n1',
  nombre: 'Ana Admin',
  username: 'ana',
  rol: RolUsuario.administrador,
  activo: true,
);
const _carlos = Usuario(
  id: 'u2',
  negocioId: 'n1',
  nombre: 'Carlos Cajero',
  username: 'carlos',
  rol: RolUsuario.cajero,
  activo: true,
);

/// Sesión en memoria: registra los intentos (con su contraseña, SOLO en la
/// prueba) y responde como el repositorio real ante credenciales inválidas.
class _AuthFalso extends AuthController {
  Completer<void>? bloqueo;
  Object? lanzar;

  final intentos = <({String username, String password})>[];

  /// Segundos de bloqueo que el "repositorio" impone por usuario al fallar.
  final bloqueos = <String, int>{};
  final registros = <Map<String, Object?>>[];
  Failure? falloRegistro;

  @override
  Future<EstadoSesion> build() async => const SinSesion();

  @override
  Future<Failure?> login({
    required String username,
    required String password,
  }) async {
    intentos.add((username: username, password: password));
    await bloqueo?.future;
    if (lanzar != null) throw lanzar!;
    if (password == 'correcta') return null;
    final segundos = bloqueos[username];
    if (segundos != null) return DemasiadosIntentosFailure(segundos);
    // Mismo mensaje del repositorio real, exista o no el usuario.
    return const ValidationFailure('Usuario o contraseña incorrectos.');
  }

  @override
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
    registros.add({
      'negocio': nombreNegocio,
      'identificacion': identificacion,
      'email': email,
      'admin': nombreAdmin,
      'username': username,
      'password': password,
    });
    await bloqueo?.future;
    if (lanzar != null) throw lanzar!;
    return falloRegistro;
  }
}

Future<_AuthFalso> _montar(
  WidgetTester tester,
  Widget pantalla, {
  Future<List<Usuario>> Function()? usuarios,
  Size tamano = const Size(420, 1000),
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = _AuthFalso();
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        authControllerProvider.overrideWith(() => auth),
        if (usuarios != null)
          usuariosActivosProvider.overrideWith((ref) => usuarios()),
        if (usuarios == null)
          usuariosActivosProvider.overrideWith((ref) async => [_ana, _carlos]),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: pantalla),
    ),
  );
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  await tester.pumpAndSettle();
  return auth;
}

Finder get _campoPassword => find.widgetWithText(TextFormField, 'Contraseña');

bool _oculta(WidgetTester tester, Finder campo) => tester
    .widget<EditableText>(
      find.descendant(of: campo, matching: find.byType(EditableText)),
    )
    .obscureText;

void main() {
  group('login', () {
    testWidgets('marca "MiTienda 360", usuario elegido y foco en la '
        'contraseña', (tester) async {
      await _montar(tester, const LoginScreen());

      expect(find.text('MiTienda 360'), findsOneWidget);
      expect(find.text('Ana Admin'), findsOneWidget);
      final editable = tester.widget<EditableText>(
        find.descendant(
          of: _campoPassword,
          matching: find.byType(EditableText),
        ),
      );
      expect(editable.focusNode.hasFocus, isTrue);
    });

    testWidgets('Enter envía; con la contraseña correcta no hay error', (
      tester,
    ) async {
      final auth = await _montar(tester, const LoginScreen());

      await tester.enterText(_campoPassword, 'correcta');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(auth.intentos, [(username: 'ana', password: 'correcta')]);
      expect(find.text('Usuario o contraseña incorrectos.'), findsNothing);
    });

    testWidgets('credenciales inválidas: mensaje GENÉRICO (no revela cuál '
        'falló), campo limpio y foco de vuelta', (tester) async {
      final auth = await _montar(tester, const LoginScreen());

      // Contraseña mala de un usuario que existe...
      await tester.enterText(_campoPassword, 'mala');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining('no existe'), findsNothing);
      expect(find.textContaining('contraseña es incorrecta'), findsNothing);
      final campo = tester.widget<EditableText>(
        find.descendant(
          of: _campoPassword,
          matching: find.byType(EditableText),
        ),
      );
      expect(campo.controller.text, isEmpty);
      expect(campo.focusNode.hasFocus, isTrue);

      // ...y de otro: el MISMO mensaje.
      await tester.tap(find.byType(DropdownButtonFormField<Usuario>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carlos Cajero').last);
      await tester.pumpAndSettle();
      await tester.enterText(_campoPassword, 'mala');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
      expect(auth.intentos.map((i) => i.username), ['ana', 'carlos']);
    });

    testWidgets('doble toque = UN intento, botón con progreso', (tester) async {
      final auth = await _montar(tester, const LoginScreen());
      auth.bloqueo = Completer<void>();

      await tester.enterText(_campoPassword, 'correcta');
      final entrar = find.widgetWithText(FilledButton, 'Entrar');
      await tester.tap(entrar);
      await tester.tap(entrar, warnIfMissed: false);
      await tester.pump();

      expect(auth.intentos.length, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      auth.bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(auth.intentos.length, 1);
    });

    testWidgets('la contraseña se oculta; el botón (con tooltip) la muestra y '
        'nunca aparece como texto suelto', (tester) async {
      await _montar(tester, const LoginScreen());

      expect(_oculta(tester, _campoPassword), isTrue);
      await tester.enterText(_campoPassword, 'secreto123');
      await tester.tap(find.byTooltip('Mostrar contraseña'));
      await tester.pump();
      expect(_oculta(tester, _campoPassword), isFalse);
      expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
      await tester.tap(find.byTooltip('Ocultar contraseña'));
      await tester.pump();
      expect(_oculta(tester, _campoPassword), isTrue);
    });

    testWidgets('una excepción: mensaje genérico, sin la contraseña ni '
        'detalles', (tester) async {
      final auth = await _montar(tester, const LoginScreen());
      auth.lanzar = StateError('database is locked (secreto123)');

      await tester.enterText(_campoPassword, 'secreto123');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('No se pudo iniciar sesión. Inténtalo de nuevo.'),
        findsOneWidget,
      );
      expect(find.textContaining('locked'), findsNothing);
      expect(find.textContaining('secreto123'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    group('límite de intentos', () {
      Finder entrar() => find.widgetWithText(FilledButton, 'Entrar');
      Future<void> fallar(WidgetTester tester) async {
        await tester.enterText(_campoPassword, 'mala');
        await tester.tap(entrar());
        await tester.pump();
        await tester.pump();
      }

      testWidgets('bloqueado: mensaje con cuenta regresiva y "Entrar" '
          'deshabilitado', (tester) async {
        final auth = await _montar(tester, const LoginScreen());
        auth.bloqueos['ana'] = 30;

        await fallar(tester);

        expect(
          find.text('Demasiados intentos. Espera 30 segundos.'),
          findsOneWidget,
        );
        expect(tester.widget<FilledButton>(entrar()).onPressed, isNull);

        await tester.pump(const Duration(seconds: 1));
        expect(
          find.text('Demasiados intentos. Espera 29 segundos.'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 10));
        expect(
          find.text('Demasiados intentos. Espera 19 segundos.'),
          findsOneWidget,
        );
        expect(tester.widget<FilledButton>(entrar()).onPressed, isNull);
      });

      testWidgets('con el botón deshabilitado Enter tampoco envía', (
        tester,
      ) async {
        final auth = await _montar(tester, const LoginScreen());
        auth.bloqueos['ana'] = 30;
        await fallar(tester);
        expect(auth.intentos.length, 1);

        await tester.enterText(_campoPassword, 'correcta');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(auth.intentos.length, 1);
      });

      testWidgets('al terminar la espera se habilita, desaparece el mensaje y '
          'vuelve el foco a la contraseña', (tester) async {
        final auth = await _montar(tester, const LoginScreen());
        auth.bloqueos['ana'] = 3;
        await fallar(tester);

        await tester.pump(const Duration(seconds: 3));
        await tester.pump();

        expect(find.textContaining('Demasiados intentos'), findsNothing);
        expect(find.byIcon(Icons.error_outline), findsNothing);
        expect(tester.widget<FilledButton>(entrar()).onPressed, isNotNull);
        final campo = tester.widget<EditableText>(
          find.descendant(
            of: _campoPassword,
            matching: find.byType(EditableText),
          ),
        );
        expect(campo.focusNode.hasFocus, isTrue);

        // Y se puede entrar con la contraseña correcta.
        auth.bloqueos.clear();
        await tester.enterText(_campoPassword, 'correcta');
        await tester.tap(entrar());
        await tester.pump();
        expect(auth.intentos.length, 2);
      });

      testWidgets('singular: "Espera 1 segundo."', (tester) async {
        final auth = await _montar(tester, const LoginScreen());
        auth.bloqueos['ana'] = 1;
        await fallar(tester);

        expect(
          find.text('Demasiados intentos. Espera 1 segundo.'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
      });

      testWidgets('el bloqueo es de ese usuario: al elegir a otro se puede '
          'entrar, y al volver sigue bloqueado', (tester) async {
        final auth = await _montar(tester, const LoginScreen());
        auth.bloqueos['ana'] = 30;
        await fallar(tester);
        expect(tester.widget<FilledButton>(entrar()).onPressed, isNull);

        await tester.tap(find.byType(DropdownButtonFormField<Usuario>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Carlos Cajero').last);
        await tester.pumpAndSettle();
        expect(find.textContaining('Demasiados intentos'), findsNothing);
        expect(tester.widget<FilledButton>(entrar()).onPressed, isNotNull);

        await tester.tap(find.byType(DropdownButtonFormField<Usuario>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ana Admin').last);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Demasiados intentos. Espera'),
          findsOneWidget,
        );
        expect(tester.widget<FilledButton>(entrar()).onPressed, isNull);

        await tester.pump(const Duration(seconds: 31));
      });

      testWidgets('salir de la pantalla cancela la cuenta regresiva (sin '
          'temporizadores colgados)', (tester) async {
        final auth = await _montar(tester, const LoginScreen());
        auth.bloqueos['ana'] = 30;
        await fallar(tester);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 40));

        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('cargando usuarios: indicador con mensaje', (tester) async {
      final espera = Completer<List<Usuario>>();
      tester.view.physicalSize = const Size(420, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            authControllerProvider.overrideWith(_AuthFalso.new),
            usuariosActivosProvider.overrideWith((ref) => espera.future),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Cargando usuarios...'), findsOneWidget);
    });

    testWidgets('error al cargar usuarios: mensaje y "Reintentar"', (
      tester,
    ) async {
      await _montar(
        tester,
        const LoginScreen(),
        usuarios: () async => throw StateError('boom'),
      );

      expect(find.text('No se pudieron cargar los usuarios.'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('sin usuarios activos: estado vacío con qué hacer', (
      tester,
    ) async {
      await _montar(tester, const LoginScreen(), usuarios: () async => []);

      expect(find.text('No hay usuarios activos'), findsOneWidget);
      expect(find.textContaining('Pide al administrador'), findsOneWidget);
    });
  });

  group('configuración inicial', () {
    Future<void> escribir(WidgetTester tester, String etiqueta, String v) =>
        tester.enterText(find.widgetWithText(TextFormField, etiqueta), v);

    testWidgets('dos pasos claros; lo opcional está plegado y el usuario '
        'sugerido es "admin"', (tester) async {
      await _montar(tester, const SetupScreen());

      expect(find.text('1. Tu negocio'), findsOneWidget);
      expect(find.text('2. Tu cuenta de administrador'), findsOneWidget);
      expect(find.text('Más datos del negocio (opcional)'), findsOneWidget);
      // Plegado: RNC/dirección/teléfono/email no estorban.
      expect(find.widgetWithText(TextFormField, 'Email'), findsNothing);
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.widgetWithText(TextFormField, 'Usuario'),
                matching: find.byType(EditableText),
              ),
            )
            .controller
            .text,
        usuarioAdminSugerido,
      );
      // Ya no hay campo de confirmar contraseña (el botón mostrar/ocultar la
      // reemplaza).
      expect(find.text('Confirmar contraseña'), findsNothing);
    });

    testWidgets('inválido: mensajes claros y NO envía', (tester) async {
      final auth = await _montar(tester, const SetupScreen());

      await escribir(tester, 'Usuario', 'ab');
      await escribir(tester, 'Contraseña', '123');
      await tester.tap(
        find.widgetWithText(FilledButton, 'Crear negocio y comenzar'),
      );
      await tester.pump();

      expect(find.text('Escribe el nombre de tu negocio'), findsOneWidget);
      expect(find.text('Escribe tu nombre'), findsOneWidget);
      expect(find.text('Mínimo 3 caracteres'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsWidgets);
      expect(auth.registros, isEmpty);
    });

    testWidgets('válido con lo mínimo: envía, opcionales como null y la '
        'contraseña no se muestra en ningún mensaje', (tester) async {
      final auth = await _montar(tester, const SetupScreen());

      await escribir(tester, 'Nombre del negocio', 'Colmado Doña Carmen');
      await escribir(tester, 'Tu nombre', 'Carmen Rodríguez');
      await escribir(tester, 'Contraseña', 'clave-segura-1');
      await tester.tap(
        find.widgetWithText(FilledButton, 'Crear negocio y comenzar'),
      );
      await tester.pumpAndSettle();

      expect(auth.registros.length, 1);
      final r = auth.registros.single;
      expect(r['negocio'], 'Colmado Doña Carmen');
      expect(r['admin'], 'Carmen Rodríguez');
      expect(r['username'], usuarioAdminSugerido);
      expect(r['identificacion'], isNull);
      expect(r['email'], isNull);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining('clave-segura-1'),
        ),
        findsNothing,
      );
    });

    testWidgets('los datos opcionales se envían al desplegarlos; un email '
        'inválido se rechaza', (tester) async {
      final auth = await _montar(tester, const SetupScreen());

      await tester.tap(find.text('Más datos del negocio (opcional)'));
      await tester.pumpAndSettle();
      await escribir(tester, 'Nombre del negocio', 'Colmado');
      await escribir(tester, 'RNC o cédula', '131-45678-9');
      await escribir(tester, 'Email', 'sin-arroba');
      await escribir(tester, 'Tu nombre', 'Carmen');
      await escribir(tester, 'Contraseña', 'clave-segura-1');
      final crear = find.widgetWithText(
        FilledButton,
        'Crear negocio y comenzar',
      );
      await tester.ensureVisible(crear);
      await tester.tap(crear);
      await tester.pump();
      expect(find.text('Escribe un email válido'), findsOneWidget);
      expect(auth.registros, isEmpty);

      await escribir(tester, 'Email', 'carmen@colmado.do');
      await tester.ensureVisible(crear);
      await tester.tap(crear);
      await tester.pumpAndSettle();
      expect(auth.registros.single['identificacion'], '131-45678-9');
      expect(auth.registros.single['email'], 'carmen@colmado.do');
    });

    testWidgets('doble toque = UN solo registro', (tester) async {
      final auth = await _montar(tester, const SetupScreen());
      auth.bloqueo = Completer<void>();

      await escribir(tester, 'Nombre del negocio', 'Colmado');
      await escribir(tester, 'Tu nombre', 'Carmen');
      await escribir(tester, 'Contraseña', 'clave-segura-1');
      final crear = find.widgetWithText(
        FilledButton,
        'Crear negocio y comenzar',
      );
      await tester.ensureVisible(crear);
      await tester.tap(crear);
      await tester.tap(crear, warnIfMissed: false);
      await tester.pump();

      expect(auth.registros.length, 1);
      auth.bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(auth.registros.length, 1);
    });

    testWidgets('el repositorio rechaza: snackbar con su mensaje', (
      tester,
    ) async {
      final auth = await _montar(tester, const SetupScreen());
      auth.falloRegistro = const ValidationFailure(
        'Ya existe un negocio registrado.',
      );

      await escribir(tester, 'Nombre del negocio', 'Colmado');
      await escribir(tester, 'Tu nombre', 'Carmen');
      await escribir(tester, 'Contraseña', 'clave-segura-1');
      await tester.tap(
        find.widgetWithText(FilledButton, 'Crear negocio y comenzar'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ya existe un negocio registrado.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('una excepción: mensaje genérico, sin la contraseña', (
      tester,
    ) async {
      final auth = await _montar(tester, const SetupScreen());
      auth.lanzar = StateError('disk I/O error clave-segura-1');

      await escribir(tester, 'Nombre del negocio', 'Colmado');
      await escribir(tester, 'Tu nombre', 'Carmen');
      await escribir(tester, 'Contraseña', 'clave-segura-1');
      await tester.tap(
        find.widgetWithText(FilledButton, 'Crear negocio y comenzar'),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No se pudo crear el negocio. Inténtalo de nuevo.'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining('clave-segura-1'),
        ),
        findsNothing,
      );
      expect(find.textContaining('disk I/O'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('contraseña con mostrar/ocultar y tooltip', (tester) async {
      await _montar(tester, const SetupScreen());

      expect(_oculta(tester, _campoPassword), isTrue);
      await tester.tap(find.byTooltip('Mostrar contraseña'));
      await tester.pump();
      expect(_oculta(tester, _campoPassword), isFalse);
    });

    testWidgets('teléfono angosto: sin desbordes', (tester) async {
      await _montar(tester, const SetupScreen(), tamano: const Size(320, 640));
      expect(tester.takeException(), isNull);
    });
  });
}
