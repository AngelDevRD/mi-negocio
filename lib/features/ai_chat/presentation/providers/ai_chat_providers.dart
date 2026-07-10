import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Estado del chat de asistente de IA (FASE 21, RF-IA-02). Solo en memoria,
/// se reinicia al salir de la pantalla.
class AiChatState {
  const AiChatState({
    this.mensajes = const [],
    this.cargando = false,
    this.error,
  });

  final List<ChatMessage> mensajes;
  final bool cargando;
  final String? error;

  AiChatState copyWith({
    List<ChatMessage>? mensajes,
    bool? cargando,
    String? error,
  }) {
    return AiChatState(
      mensajes: mensajes ?? this.mensajes,
      cargando: cargando ?? this.cargando,
      error: error,
    );
  }
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);

class AiChatController extends Notifier<AiChatState> {
  @override
  AiChatState build() => const AiChatState();

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
      error: null,
    );

    try {
      final contexto = await ref
          .read(businessContextBuilderProvider)
          .construir();
      final respuesta = await ref
          .read(aiChatRemoteDatasourceProvider)
          .chat(mensajes: state.mensajes, contexto: contexto);

      if (!respuesta.ok) {
        state = state.copyWith(
          cargando: false,
          error: respuesta.error ?? 'No se pudo obtener respuesta.',
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
    } catch (e) {
      state = state.copyWith(
        cargando: false,
        error:
            'No se pudo conectar con el asistente. Verifica tu conexión ($e).',
      );
    }
  }
}
