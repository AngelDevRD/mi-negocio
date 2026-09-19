import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Etiqueta de estado o categoría con ícono Y texto (nunca solo color):
/// "Activo", "Administrador", "Delivery"... Sin [color] usa el color de texto
/// secundario del tema.
///
/// Uso: `EtiquetaEstado(icono: Icons.check_circle_outline, texto: 'Activo',
/// color: context.appColors.exito)`.
class EtiquetaEstado extends StatelessWidget {
  const EtiquetaEstado({
    super.key,
    required this.icono,
    required this.texto,
    this.color,
  });

  final IconData icono;
  final String texto;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tono = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: tono),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            texto,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tono,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// "Activo" / "Inactivo" con ícono y texto (empleados, usuarios...).
class EtiquetaActivo extends StatelessWidget {
  const EtiquetaActivo({super.key, required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return activo
        ? EtiquetaEstado(
            icono: Icons.check_circle_outline,
            texto: 'Activo',
            color: context.appColors.exito,
          )
        : const EtiquetaEstado(
            icono: Icons.pause_circle_outline,
            texto: 'Inactivo',
          );
  }
}
