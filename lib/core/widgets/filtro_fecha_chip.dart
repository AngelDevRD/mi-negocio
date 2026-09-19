import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/rango_fecha.dart';

/// Chip de filtro por fecha CON TEXTO ("Todas las fechas", "Hoy", "Esta
/// semana", "Este mes" o el rango elegido) que abre un menú con las opciones.
/// Sustituye al ícono de calendario suelto: el usuario ve qué período está
/// filtrando sin abrir nada.
///
/// [textoPersonalizado] es lo que se muestra cuando [rango] es
/// [RangoFecha.personalizado] (p. ej. "12/09 - 15/09").
class FiltroFechaChip extends StatelessWidget {
  const FiltroFechaChip({
    super.key,
    required this.rango,
    required this.onElegir,
    this.textoPersonalizado,
  });

  final RangoFecha rango;
  final String? textoPersonalizado;
  final ValueChanged<RangoFecha> onElegir;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activo = rango != RangoFecha.todo;
    final texto =
        rango == RangoFecha.personalizado && textoPersonalizado != null
        ? textoPersonalizado!
        : rango.etiqueta;
    final color = activo ? scheme.onSecondaryContainer : scheme.onSurface;

    return PopupMenuButton<RangoFecha>(
      tooltip: 'Filtrar por fecha',
      onSelected: onElegir,
      itemBuilder: (_) => [
        for (final opcion in RangoFecha.values)
          CheckedPopupMenuItem(
            value: opcion,
            checked: opcion == rango,
            child: Text(opcion.etiqueta),
          ),
      ],
      child: Chip(
        backgroundColor: activo ? scheme.secondaryContainer : null,
        avatar: Icon(Icons.date_range_outlined, size: 18, color: color),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texto, style: TextStyle(color: color)),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.arrow_drop_down, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

/// Selector de rango de fechas del sistema (para "Personalizado..."). Devuelve
/// `null` si se cancela. Las fechas del rango son días del calendario local.
Future<DateTimeRange?> elegirRangoDeFechas(
  BuildContext context, {
  DateTime? desde,
  DateTime? hasta,
}) {
  final ahora = DateTime.now();
  return showDateRangePicker(
    context: context,
    firstDate: DateTime(ahora.year - 5),
    lastDate: ahora,
    initialDateRange: desde != null && hasta != null
        ? DateTimeRange(start: desde.toLocal(), end: hasta.toLocal())
        : null,
  );
}
