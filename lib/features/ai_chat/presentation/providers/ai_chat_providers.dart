import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../../../../core/config/supabase_config.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/datasources/ai_chat_remote_datasource.dart';
import '../../data/services/business_context_builder.dart';
import '../../domain/entities/chat_message.dart';

final aiChatRemoteDatasourceProvider = Provider<AiChatRemoteDatasource>((ref) {
  return SupabaseAiChatRemoteDatasource();
});

final businessContextBuilderProvider = Provider<BusinessContextBuilder>((ref) {
  return BusinessContextBuilder(
    profile: ref.watch(profileLocalDatasourceProvider),
    analytics: ref.watch(analyticsDaoProvider),
    dashboard: ref.watch(dashboardDaoProvider),
  );
});

/// ¿Esta versión de la app trae el servidor de IA configurado? (Sin las
/// variables de compilación no hay a dónde consultar.) Se sobreescribe en
/// pruebas.
final aiChatConfiguradoProvider = Provider<bool>(
  (ref) => SupabaseConfig.configurado,
);

/// ¿Hay conexión a internet ahora? Se sobreescribe en pruebas.
final aiChatHayConexionProvider = Provider<Future<bool> Function()>((ref) {
  return () async {
    final resultados = await Connectivity().checkConnectivity();
    return resultados.any((r) => r != ConnectivityResult.none);
  };
});

/// Por qué falló el asistente: la pantalla muestra un aviso distinto (y con
/// o sin "Reintentar") según el caso.
enum AiChatErrorTipo { sinConexion, noConfigurado, fallo }

/// Estado del chat de asistente de IA (FASE 21, RF-IA-02). Solo en memoria,
/// se reinicia al salir de la pantalla.
class AiChatState {
  const AiChatState({
    this.mensajes = const [],
    this.cargando = false,
    this.error,
    this.tipoError,
  });

  final List<ChatMessage> mensajes;
  final bool cargando;

  /// Mensaje HUMANO del error (nunca el texto crudo de una excepción ni de la
  /// respuesta del servidor), o `null`.
  final String? error;
  final AiChatErrorTipo? tipoError;

  AiChatState copyWith({
    List<ChatMessage>? mensajes,
    bool? cargando,
    String? error,
    AiChatErrorTipo? tipoError,
  }) {
    return AiChatState(
      mensajes: mensajes ?? this.mensajes,
      cargando: cargando ?? this.cargando,
      error: error,
      tipoError: tipoError,
    );
  }
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);

class AiChatController extends Notifier<AiChatState> {
  static const mensajeSinConexion =
      'Sin conexión a internet. El asistente necesita conexión: revisa tu '
      'red e inténtalo de nuevo.';
  static const mensajeNoConfigurado =
      'El asistente todavía no está configurado. Avisa al administrador del '
      'servicio.';
  static const mensajeFallo =
      'El asistente no pudo responder en este momento. Inténtalo de nuevo.';

  @override
  AiChatState build() => const AiChatState();

  /// Envía [texto] como pregunta nueva.
  Future<void> enviar(String texto) async {
    final pregunta = texto.trim();
    if (pregunta.isEmpty || state.cargando) return;

    final mensajeUsuario = ChatMessage(
      role: ChatRole.usuario,
      texto: pregunta,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      mensajes: [...state.mensajes, mensajeUsuario],
      cargando: true,
    );
    await _consultar();
  }

  /// Vuelve a pedir respuesta a la ÚLTIMA pregunta (sin duplicarla).
  Future<void> reintentar() async {
    if (state.cargando ||
        state.mensajes.isEmpty ||
        state.mensajes.last.role != ChatRole.usuario) {
      return;
    }
    state = state.copyWith(cargando: true);
    await _consultar();
  }

  void _fallar(AiChatErrorTipo tipo, String mensaje) {
    state = state.copyWith(cargando: false, error: mensaje, tipoError: tipo);
  }

  Future<void> _consultar() async {
    if (!ref.read(aiChatConfiguradoProvider)) {
      _fallar(AiChatErrorTipo.noConfigurado, mensajeNoConfigurado);
      return;
    }
    try {
      if (!await ref.read(aiChatHayConexionProvider)()) {
        _fallar(AiChatErrorTipo.sinConexion, mensajeSinConexion);
        return;
      }
      final contexto = await ref
          .read(businessContextBuilderProvider)
          .construir();
      final respuesta = await ref
          .read(aiChatRemoteDatasourceProvider)
          .chat(mensajes: state.mensajes, contexto: contexto);

      if (!respuesta.ok) {
        // El texto del servidor puede ser técnico ("Gemini respondió 429"):
        // va al log y el usuario ve un mensaje humano.
        developer.log(
          'El asistente respondió con error: ${respuesta.error}',
          name: 'mi_negocio',
        );
        final sinConfigurar =
            respuesta.error?.toLowerCase().contains('no configurada') ?? false;
        _fallar(
          sinConfigurar ? AiChatErrorTipo.noConfigurado : AiChatErrorTipo.fallo,
          sinConfigurar ? mensajeNoConfigurado : mensajeFallo,
        );
        return;
      }

      final mensajeAsistente = ChatMessage(
        role: ChatRole.asistente,
        texto: respuesta.respuesta ?? '',
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        mensajes: [...state.mensajes, mensajeAsistente],
        cargando: false,
      );
    } on Object catch (e, st) {
      developer.log(
        'Falló la consulta al asistente',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      if (e is FunctionException && e.status == 503) {
        _fallar(AiChatErrorTipo.noConfigurado, mensajeNoConfigurado);
      } else if (_esErrorDeRed(e)) {
        _fallar(AiChatErrorTipo.sinConexion, mensajeSinConexion);
      } else {
        _fallar(AiChatErrorTipo.fallo, mensajeFallo);
      }
    }
  }

  bool _esErrorDeRed(Object e) {
    if (e is TimeoutException) return true;
    // Supabase: sin respuesta (status 0) = el pedido no llegó al servidor.
    if (e is FunctionException && e.status == 0) return true;
    final tipo = e.runtimeType.toString();
    return tipo.contains('SocketException') ||
        tipo.contains('ClientException') ||
        tipo.contains('HandshakeException');
  }
}
