import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Snackbars consistentes para toda la app.
///
/// Siempre REEMPLAZA el snackbar actual (nunca lo encola): así, si el
/// usuario dispara varias acciones seguidas, solo ve el mensaje más
/// reciente en vez de una cola de avisos viejos. Combina ícono + texto para
/// no depender solo del color (accesibilidad).
///
/// Uso: `AppSnackbar.error(context, resultado.failure.message);`
abstract final class AppSnackbar {
  static void exito(BuildContext context, String mensaje) {
    final colors = context.appColors;
    _mostrar(
      context,
      mensaje: mensaje,
      icono: Icons.check_circle_outline,
      fondo: colors.exito,
      contenido: colors.onExito,
    );
  }

  static void error(BuildContext context, String mensaje) {
    final scheme = Theme.of(context).colorScheme;
    _mostrar(
      context,
      mensaje: mensaje,
      icono: Icons.error_outline,
      fondo: scheme.error,
      contenido: scheme.onError,
    );
  }

  static void info(BuildContext context, String mensaje) {
    final scheme = Theme.of(context).colorScheme;
    _mostrar(
      context,
      mensaje: mensaje,
      icono: Icons.info_outline,
      fondo: scheme.inverseSurface,
      contenido: scheme.onInverseSurface,
    );
  }

  static void _mostrar(
    BuildContext context, {
    required String mensaje,
    required IconData icono,
    required Color fondo,
    required Color contenido,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    // clearSnackBars() (no hideCurrentSnackBar): así ningún mensaje anterior
    // queda encolado esperando su turno, ni siquiera si se dispara varias
    // veces seguidas antes de que termine la animación de salida.
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: fondo,
        content: Row(
          children: [
            Icon(icono, color: contenido),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(mensaje, style: TextStyle(color: contenido))),
          ],
        ),
      ),
    );
  }
}
