import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/money_text.dart';

/// Estado del saldo de un cliente, siempre con TEXTO además del color:
/// `Debe` (advertencia), `A favor` (éxito) o `Al día`.
class EtiquetaSaldo extends StatelessWidget {
  const EtiquetaSaldo({super.key, required this.saldo, this.grande = false});

  final Money saldo;

  /// Versión destacada (cabecera del detalle).
  final bool grande;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final colores = context.appColors;

    final (etiqueta, color) = saldo.cents > 0
        ? ('Debe', colores.advertencia)
        : saldo.cents < 0
        ? ('A favor', colores.exito)
        : ('Al día', scheme.onSurfaceVariant);
    final monto = Money(saldo.cents.abs());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          etiqueta,
          style: (grande ? textTheme.titleMedium : textTheme.labelMedium)
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
        if (saldo.cents != 0)
          MoneyText(
            monto,
            textAlign: TextAlign.right,
            style: (grande ? textTheme.headlineMedium : textTheme.titleMedium)
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
