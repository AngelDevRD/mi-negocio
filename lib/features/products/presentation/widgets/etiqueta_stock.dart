import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/producto.dart';

/// Estado del stock con TEXTO e ícono (no solo color): "Sin stock" (<= 0) o
/// "Stock bajo" (<= mínimo). Con stock en orden no muestra nada.
class EtiquetaStock extends StatelessWidget {
  const EtiquetaStock({super.key, required this.producto});

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sinStock = producto.stockActual <= 0;
    if (!sinStock && !producto.stockBajo) return const SizedBox.shrink();

    final color = sinStock ? scheme.error : context.appColors.advertencia;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          sinStock ? Icons.block_outlined : Icons.warning_amber_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          sinStock ? 'Sin stock' : 'Stock bajo',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
