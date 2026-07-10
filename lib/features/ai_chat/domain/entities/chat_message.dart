/// Quién envía un mensaje del chat de asistente de IA (FASE 21).
enum ChatRole { usuario, asistente }

/// Mensaje del chat de asistente de IA. Solo vive en memoria de la pantalla,
/// no se persiste (RF-IA-02).
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.texto,
    required this.timestamp,
  });

  final ChatRole role;
  final String texto;
  final DateTime timestamp;
}
