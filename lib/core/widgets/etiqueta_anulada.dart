import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Etiqueta "Anulada" con ícono y texto (no solo color) para ventas y compras
/// anuladas.
class EtiquetaAnulada extends StatelessWidget {
  const EtiquetaAnulada({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.block_outlined, size: 14, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Anulada',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
