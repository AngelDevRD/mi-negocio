import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../license/domain/entities/licencia.dart';
import '../../../license/presentation/providers/license_providers.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/ai_chat_providers.dart';

/// Preguntas de ejemplo del estado vacío (se tocan y se envían).
const preguntasSugeridas = [
  '¿Cuánto vendí este mes?',
  '¿Qué productos se están acabando?',
  '¿En qué gasté más este mes?',
];

/// Asistente de IA del negocio (FASE 21, RF-IA). Solo disponible con
/// licencia Nube, requiere conexión a internet.
class AiChatScreen extends ConsumerWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licencia = ref.watch(licenseControllerProvider).value;
    final esNube = switch (licencia) {
      LicenciaActiva(:final licencia) => licencia.tipo == TipoLicencia.nube,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Asistente IA')),
      body: esNube
          ? const _ChatBody()
          : const EmptyState(
              icono: Icons.lock_outline,
              titulo: 'El asistente de IA solo está en el plan Nube',
              descripcion:
                  'Activa una licencia Nube para hacer preguntas sobre tu '
                  'negocio.',
            ),
    );
  }
}

class _ChatBody extends ConsumerStatefulWidget {
  const _ChatBody();

  @override
  ConsumerState<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends ConsumerState<_ChatBody> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _controller.text;
    if (texto.trim().isEmpty) return;
    if (ref.read(aiChatControllerProvider).cargando) return;
    _controller.clear();
    ref.read(aiChatControllerProvider.notifier).enviar(texto);
  }

  void _scrollAlFinal() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiChatControllerProvider);
    _scrollAlFinal();

    return Column(
      children: [
        Expanded(
          child: state.mensajes.isEmpty
              ? _EstadoVacio(
                  onPregunta: (p) =>
                      ref.read(aiChatControllerProvider.notifier).enviar(p),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  // +1: la burbuja "escribiendo" mientras se espera.
                  itemCount: state.mensajes.length + (state.cargando ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.mensajes.length) {
                      return const _Escribiendo();
                    }
                    return _BurbujaMensaje(mensaje: state.mensajes[index]);
                  },
                ),
        ),
        if (state.error != null)
          _AvisoDeError(
            mensaje: state.error!,
            tipo: state.tipoError ?? AiChatErrorTipo.fallo,
            onReintentar: () =>
                ref.read(aiChatControllerProvider.notifier).reintentar(),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Pregunta sobre tu negocio…',
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _enviar(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  tooltip: 'Enviar pregunta',
                  onPressed: state.cargando ? null : _enviar,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Aviso de error del asistente: ícono + mensaje humano y, salvo que el
/// servicio no esté configurado, "Reintentar".
class _AvisoDeError extends StatelessWidget {
  const _AvisoDeError({
    required this.mensaje,
    required this.tipo,
    required this.onReintentar,
  });

  final String mensaje;
  final AiChatErrorTipo tipo;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icono = switch (tipo) {
      AiChatErrorTipo.sinConexion => Icons.wifi_off_outlined,
      AiChatErrorTipo.noConfigurado => Icons.settings_suggest_outlined,
      AiChatErrorTipo.fallo => Icons.error_outline,
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icono, color: scheme.onErrorContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                mensaje,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
            if (tipo != AiChatErrorTipo.noConfigurado)
              TextButton(
                onPressed: onReintentar,
                child: const Text('Reintentar'),
              ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({required this.onPregunta});

  final ValueChanged<String> onPregunta;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_outlined, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Pregúntale al asistente sobre tus ventas, gastos o inventario.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                for (final p in preguntasSugeridas)
                  ActionChip(label: Text(p), onPressed: () => onPregunta(p)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "El asistente está escribiendo…": la respuesta viene de la red y puede
/// tardar; la pantalla sigue usable.
class _Escribiendo extends StatelessWidget {
  const _Escribiendo();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'El asistente está escribiendo…',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BurbujaMensaje extends StatelessWidget {
  const _BurbujaMensaje({required this.mensaje});

  final ChatMessage mensaje;

  @override
  Widget build(BuildContext context) {
    final esUsuario = mensaje.role == ChatRole.usuario;
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: esUsuario
              ? scheme.primaryContainer
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(mensaje.texto),
      ),
    );
  }
}
