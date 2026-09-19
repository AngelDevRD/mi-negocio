import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/caja_sesion.dart';

/// Fila de un movimiento de caja: ícono, título, motivo (si hay), hora local y
/// el monto CON SIGNO ("+" entradas en color de éxito, "-" salidas en color de
/// error). El signo va siempre en el texto: el color solo lo refuerza.
class MovimientoCajaTile extends StatelessWidget {
  const MovimientoCajaTile({
    super.key,
    required this.movimiento,
    this.fechaCompleta = false,
  });

  final CajaMovimiento movimiento;

  /// `true`: día y hora (detalle de un cierre pasado). `false`: solo la hora
  /// si es de hoy, o día y hora si el turno se quedó abierto de otro día.
  final bool fechaCompleta;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final entra = !movimiento.monto.isNegative;
    final color = entra ? context.appColors.exito : scheme.error;
    final monto = Money(movimiento.monto.cents.abs());
    final motivo = movimiento.motivo?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(_icono(movimiento.tipo), color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_titulo(movimiento.tipo), style: textTheme.titleSmall),
                if (motivo != null && motivo.isNotEmpty)
                  Text(
                    motivo,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  _fecha(movimiento.fecha.toLocal()),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${entra ? '+' : '-'}${monto.format()}',
                softWrap: false,
                style: textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fecha(DateTime fecha) {
    final ahora = DateTime.now();
    final esHoy =
        fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
    return (fechaCompleta || !esHoy)
        ? DateFormat('dd/MM/yyyy HH:mm').format(fecha)
        : DateFormat('HH:mm').format(fecha);
  }

  IconData _icono(TipoCajaMovimiento tipo) => switch (tipo) {
    TipoCajaMovimiento.venta => Icons.point_of_sale,
    TipoCajaMovimiento.gasto => Icons.receipt_long_outlined,
    TipoCajaMovimiento.compra => Icons.shopping_cart_outlined,
    TipoCajaMovimiento.pagoEmpleado => Icons.people_outline,
    TipoCajaMovimiento.entradaManual => Icons.add_circle_outline,
    TipoCajaMovimiento.salidaManual => Icons.remove_circle_outline,
    TipoCajaMovimiento.retiroCierre => Icons.lock_outline,
    TipoCajaMovimiento.abonoCliente => Icons.payments_outlined,
  };

  String _titulo(TipoCajaMovimiento tipo) => switch (tipo) {
    TipoCajaMovimiento.venta => 'Venta',
    TipoCajaMovimiento.gasto => 'Gasto',
    TipoCajaMovimiento.compra => 'Compra',
    TipoCajaMovimiento.pagoEmpleado => 'Pago a empleado',
    TipoCajaMovimiento.entradaManual => 'Entrada manual',
    TipoCajaMovimiento.salidaManual => 'Salida manual',
    TipoCajaMovimiento.retiroCierre => 'Retiro de cierre',
    TipoCajaMovimiento.abonoCliente => 'Abono de cliente',
  };
}

/// Lista de movimientos dentro de una tarjeta, con separadores.
class MovimientosCajaCard extends StatelessWidget {
  const MovimientosCajaCard({
    super.key,
    required this.movimientos,
    this.fechaCompleta = false,
  });

  final List<CajaMovimiento> movimientos;
  final bool fechaCompleta;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < movimientos.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            MovimientoCajaTile(
              movimiento: movimientos[i],
              fechaCompleta: fechaCompleta,
            ),
          ],
        ],
      ),
    );
  }
}
