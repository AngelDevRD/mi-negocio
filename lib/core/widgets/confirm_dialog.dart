import 'package:flutter/material.dart';

/// Diálogo de confirmación genérico para acciones que necesitan un paso
/// intermedio (eliminar, anular, cerrar). Devuelve `true` solo si el
/// usuario pulsa el botón de confirmar; `false` si cancela o descarta el
/// diálogo (botón atrás, tap fuera).
///
/// Uso: `if (!await mostrarConfirmacion(context, titulo: 'Eliminar
/// producto', mensaje: 'Esta acción no se puede deshacer.', confirmarLabel:
/// 'Eliminar', destructivo: true)) return;`
Future<bool> mostrarConfirmacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String confirmarLabel,
  String cancelarLabel = 'Cancelar',
  bool destructivo = false,
}) async {
  final scheme = Theme.of(context).colorScheme;
  final resultado = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelarLabel),
        ),
        FilledButton(
          style: destructivo
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmarLabel),
        ),
      ],
    ),
  );
  return resultado ?? false;
}
