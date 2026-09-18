import 'package:flutter/material.dart';

import '../utils/money.dart';

/// Muestra un [Money] sin recortarlo NUNCA con elipsis: si no cabe en el
/// ancho disponible, se reduce con [FittedBox] (un monto cortado, ej.
/// "RD\$ 1,250,0...", es información perdida, no un detalle estético). Usa
/// cifras tabulares para que las columnas de montos se alineen entre sí.
/// Monto negativo en [ColorScheme.error]. Sin [textAlign] se alinea al
/// INICIO (no al centro): la mayoría de los montos de la app van alineados
/// a la izquierda, dentro de filas/columnas de listas y resúmenes.
///
/// Uso: `MoneyText(venta.total)` o `MoneyText(saldo, style:
/// Theme.of(context).textTheme.titleLarge)`.
class MoneyText extends StatelessWidget {
  const MoneyText(this.monto, {super.key, this.style, this.textAlign});

  final Money monto;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = (style ?? DefaultTextStyle.of(context).style).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      color: monto.isNegative ? scheme.error : style?.color,
    );
    final alineacion = switch (textAlign) {
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      TextAlign.center => Alignment.center,
      _ => Alignment.centerLeft,
    };
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alineacion,
      child: Text(monto.format(), style: base, textAlign: textAlign),
    );
  }
}
