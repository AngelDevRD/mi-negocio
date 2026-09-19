import 'package:flutter/material.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../metodo_pago_texto.dart';

/// Elige el método de pago (cobro y abonos).
///
/// Chips que pasan a otra línea si no caben, en vez de un `SegmentedButton`
/// reducido: en un diálogo de teléfono con "Transferencia" las etiquetas
/// quedaban diminutas. La opción elegida lleva marca ✓ (no solo color).
class SelectorMetodoPago extends StatelessWidget {
  const SelectorMetodoPago({
    super.key,
    required this.metodos,
    required this.seleccionado,
    required this.onCambio,
  });

  final List<MetodoPago> metodos;
  final MetodoPago seleccionado;
  final ValueChanged<MetodoPago> onCambio;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final metodo in metodos)
          FilterChip(
            label: Text(metodo.etiqueta),
            selected: metodo == seleccionado,
            onSelected: (_) => onCambio(metodo),
          ),
      ],
    );
  }
}
