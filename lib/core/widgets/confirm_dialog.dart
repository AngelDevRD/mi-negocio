import 'package:flutter/material.dart';

/// Cambia el espacio de "RD$ 2,960.00" por uno duro: el monto no se parte en
/// dos líneas ("RD$" arriba, la cifra abajo) al ajustar el texto del diálogo.
String _montosSinPartir(String mensaje) =>
    mensaje.replaceAllMapped(RegExp(r'RD\$ (?=-?\d)'), (_) => 'RD\$ ');

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
      // Con mensajes largos (p. ej. lo que pasa al anular) el contenido se desplaza.
      scrollable: true,
      title: Text(titulo),
      content: Text(_montosSinPartir(mensaje)),
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
