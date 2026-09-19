import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/money.dart';
import 'money_text.dart';

/// Encabezado de un grupo diario de una lista ("Hoy", "Ayer", "12/09/2026")
/// con el total del día a la derecha.
class EncabezadoDia extends StatelessWidget {
  const EncabezadoDia({
    super.key,
    required this.titulo,
    required this.total,
    this.etiquetaTotal = 'Total del día',
  });

  final String titulo;
  final Money total;
  final String etiquetaTotal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(titulo, style: textTheme.titleSmall)),
          Text(
            '$etiquetaTotal ',
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: MoneyText(
              total,
              textAlign: TextAlign.right,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
