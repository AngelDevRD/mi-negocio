import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/chat_message.dart';

/// Respuesta de la edge function `ai`, acción `chat`.
class AiChatResponse {
  const AiChatResponse({required this.ok, this.error, this.respuesta});

  final bool ok;
  final String? error;
  final String? respuesta;
}

/// Cliente de la edge function `ai` para el asistente de IA del negocio
/// (FASE 21, RF-IA-02). Abstracto para poder simularlo en tests.
abstract class AiChatRemoteDatasource {
  Future<AiChatResponse> chat({
    required List<ChatMessage> mensajes,
    required Map<String, dynamic> contexto,
  });
}

class SupabaseAiChatRemoteDatasource implements AiChatRemoteDatasource {
  @override
  Future<AiChatResponse> chat({
    required List<ChatMessage> mensajes,
    required Map<String, dynamic> contexto,
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'ai',
      body: {
        'action': 'chat',
        'messages': [
          for (final mensaje in mensajes)
            {'role': mensaje.role.name, 'texto': mensaje.texto},
        ],
        'context': contexto,
      },
    );
    final data = (response.data as Map).cast<String, dynamic>();
    if (data['ok'] != true) {
      return AiChatResponse(
        ok: false,
        error: data['error'] as String? ?? 'No se pudo obtener respuesta.',
      );
    }
    return AiChatResponse(ok: true, respuesta: data['respuesta'] as String?);
  }
}
