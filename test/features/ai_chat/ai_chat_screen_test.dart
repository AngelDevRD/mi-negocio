import 'dart:async';
import 'dart:io';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/ai_chat/data/datasources/ai_chat_remote_datasource.dart';
import 'package:app_gestion/features/ai_chat/data/services/business_context_builder.dart';
import 'package:app_gestion/features/ai_chat/domain/entities/chat_message.dart';
import 'package:app_gestion/features/ai_chat/presentation/providers/ai_chat_providers.dart';
import 'package:app_gestion/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:app_gestion/features/license/presentation/providers/license_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

class _LicenciaFija extends LicenseController {
  _LicenciaFija(this.tipo);

  final TipoLicencia tipo;

  @override
  Future<LicenseCheck> build() async => LicenciaActiva(
    Licencia(
      tipo: tipo,
      estado: EstadoLicencia.activa,
      deviceId: 'd',
      fechaActivacion: DateTime(2026),
      ultimaValidacion: DateTime(2026),
    ),
  );
}

class _ContextoFalso implements BusinessContextBuilder {
  @override
  Future<Map<String, dynamic>> construir() async => {'negocio': 'Colmado'};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Servidor de IA de mentira: responde, falla o lanza según se configure.
class _IaFalsa implements AiChatRemoteDatasource {
  Completer<void>? bloqueo;
  Object? lanzar;
  AiChatResponse respuesta = const AiChatResponse(
    ok: true,
    respuesta: 'Vendiste RD\$ 6,444.00 este mes.',
  );

  final preguntas = <String>[];

  @override
  Future<AiChatResponse> chat({
    required List<ChatMessage> mensajes,
    required Map<String, dynamic> contexto,
  }) async {
    preguntas.add(mensajes.last.texto);
    await bloqueo?.future;
    if (lanzar != null) throw lanzar!;
    return respuesta;
  }
}

class _Entorno {
  final ia = _IaFalsa();
  bool configurado = true;
  bool conexion = true;
}

Future<_Entorno> _montar(
  WidgetTester tester, {
  _Entorno? entorno,
  TipoLicencia licencia = TipoLicencia.nube,
}) async {
  final e = entorno ?? _Entorno();
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        licenseControllerProvider.overrideWith(() => _LicenciaFija(licencia)),
        aiChatRemoteDatasourceProvider.overrideWithValue(e.ia),
        businessContextBuilderProvider.overrideWithValue(_ContextoFalso()),
        aiChatConfiguradoProvider.overrideWith((ref) => e.configurado),
        aiChatHayConexionProvider.overrideWith(
          (ref) =>
              () async => e.conexion,
        ),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const AiChatScreen()),
    ),
  );
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(licenseControllerProvider.future);
  await tester.pumpAndSettle();
  return e;
}

Future<void> _preguntar(WidgetTester tester, String texto) async {
  await tester.enterText(find.byType(TextField), texto);
  await tester.tap(find.byTooltip('Enviar pregunta'));
}

void main() {
  testWidgets('plan que no es Nube: estado bloqueado con explicación', (
    tester,
  ) async {
    await _montar(tester, licencia: TipoLicencia.local);

    expect(
      find.text('El asistente de IA solo está en el plan Nube'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('sin mensajes: invita a preguntar con ejemplos que se envían', (
    tester,
  ) async {
    final e = await _montar(tester);

    expect(
      find.textContaining('Pregúntale al asistente sobre tus ventas'),
      findsOneWidget,
    );
    for (final p in preguntasSugeridas) {
      expect(find.text(p), findsOneWidget);
    }

    await tester.tap(find.text(preguntasSugeridas.first));
    await tester.pumpAndSettle();

    expect(e.ia.preguntas, [preguntasSugeridas.first]);
    expect(find.text('Vendiste RD\$ 6,444.00 este mes.'), findsOneWidget);
  });

  testWidgets('mientras responde: burbuja "escribiendo", la pantalla sigue '
      'usable y el botón queda deshabilitado (una pregunta a la vez)', (
    tester,
  ) async {
    final e = await _montar(tester);
    e.ia.bloqueo = Completer<void>();

    await _preguntar(tester, '¿Cuánto vendí?');
    await tester.pump();

    expect(find.text('El asistente está escribiendo…'), findsOneWidget);
    expect(find.text('¿Cuánto vendí?'), findsOneWidget);
    // Se puede seguir escribiendo mientras espera...
    await tester.enterText(find.byType(TextField), 'otra pregunta');
    // ...pero no se envía otra hasta que responda.
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send))
          .onPressed,
      isNull,
    );
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(e.ia.preguntas.length, 1);

    e.ia.bloqueo!.complete();
    await tester.pumpAndSettle();
    expect(find.text('El asistente está escribiendo…'), findsNothing);
    expect(find.text('Vendiste RD\$ 6,444.00 este mes.'), findsOneWidget);
  });

  group('errores (siempre mensajes humanos)', () {
    testWidgets('sin conexión: aviso claro y reintentar SIN duplicar la '
        'pregunta', (tester) async {
      final e = await _montar(tester);
      e.conexion = false;

      await _preguntar(tester, '¿Cuánto vendí?');
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin conexión a internet'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
      expect(e.ia.preguntas, isEmpty); // ni siquiera se intentó

      e.conexion = true;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(e.ia.preguntas, ['¿Cuánto vendí?']);
      expect(find.textContaining('Sin conexión'), findsNothing);
      expect(find.text('Vendiste RD\$ 6,444.00 este mes.'), findsOneWidget);
      // La pregunta sigue una sola vez en el historial.
      expect(find.text('¿Cuánto vendí?'), findsOneWidget);
    });

    testWidgets('sin servidor de IA configurado en la app: mensaje humano, '
        'sin reintentar', (tester) async {
      final e = await _montar(tester);
      e.configurado = false;

      await _preguntar(tester, 'hola');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('todavía no está configurado'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsNothing);
      expect(e.ia.preguntas, isEmpty);
    });

    testWidgets('el servidor dice "IA no configurada todavía" (sin clave): '
        'mensaje humano, sin el texto crudo', (tester) async {
      final e = await _montar(tester);
      e.ia.respuesta = const AiChatResponse(
        ok: false,
        error: 'IA no configurada todavía.',
      );

      await _preguntar(tester, 'hola');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('todavía no está configurado'),
        findsOneWidget,
      );
      expect(find.text('IA no configurada todavía.'), findsNothing);
      expect(find.text('Reintentar'), findsNothing);
    });

    testWidgets('HTTP 503 de la función: también "no configurado"', (
      tester,
    ) async {
      final e = await _montar(tester);
      e.ia.lanzar = const FunctionException(status: 503);

      await _preguntar(tester, 'hola');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('todavía no está configurado'),
        findsOneWidget,
      );
    });

    testWidgets('error crudo del proveedor (p. ej. "Gemini respondió 429"): '
        'no se muestra', (tester) async {
      final e = await _montar(tester);
      e.ia.respuesta = const AiChatResponse(
        ok: false,
        error: 'Gemini respondió 429 api_key=AIzaSyFAKE',
      );

      await _preguntar(tester, 'hola');
      await tester.pumpAndSettle();

      expect(
        find.text(
          'El asistente no pudo responder en este momento. Inténtalo de '
          'nuevo.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Gemini'), findsNothing);
      expect(find.textContaining('AIzaSy'), findsNothing);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('excepción de red: se ve como "sin conexión", sin el '
        'detalle', (tester) async {
      final e = await _montar(tester);
      e.ia.lanzar = const SocketException('Failed host lookup: x.supabase.co');

      await _preguntar(tester, 'hola');
      await tester.pumpAndSettle();

      expect(find.textContaining('Sin conexión a internet'), findsOneWidget);
      expect(find.textContaining('supabase.co'), findsNothing);
      expect(find.textContaining('SocketException'), findsNothing);
    });

    testWidgets('excepción inesperada: mensaje genérico, sin detalles', (
      tester,
    ) async {
      final e = await _montar(tester);
      e.ia.lanzar = StateError('token=eyJhbGciSECRETO');

      await _preguntar(tester, 'hola');
      await tester.pumpAndSettle();

      expect(find.textContaining('no pudo responder'), findsOneWidget);
      expect(find.textContaining('SECRETO'), findsNothing);
      expect(find.textContaining('StateError'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('teléfono angosto con texto grande: sin desbordes', (
    tester,
  ) async {
    final e = await _montar(tester);
    e.conexion = false;
    tester.view.physicalSize = const Size(320, 640);

    await _preguntar(tester, '¿Cuánto vendí este mes en todo el negocio?');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
