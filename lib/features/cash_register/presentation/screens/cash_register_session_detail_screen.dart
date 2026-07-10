import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/cash_register_providers.dart';

/// Detalle de una sesión de caja (abierta o cerrada): apertura, cierre,
/// montos esperado/contado/diferencia y movimientos del día.
class CashRegisterSessionDetailScreen extends ConsumerWidget {
  const CashRegisterSessionDetailScreen({super.key, required this.sesionId});

  final String sesionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesionAsync = ref.watch(sesionCajaProvider(sesionId));
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de cierre')),
      body: sesionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudo cargar la sesión.')),
        data: (sesion) {
          if (sesion == null) {
            return const Center(child: Text('Sesión no encontrada.'));
          }
          final scheme = Theme.of(context).colorScheme;
          final diferencia = sesion.diferencia;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _DetalleFila(
                etiqueta: 'Apertura',
                valor:
                    '${sesion.montoApertura.format()} · '
                    '${formatoFecha.format(sesion.fechaApertura.toLocal())} · '
                    '${sesion.usuarioAperturaNombre}',
              ),
              if (sesion.fechaCierre != null)
                _DetalleFila(
                  etiqueta: 'Cierre',
                  valor:
                      '${formatoFecha.format(sesion.fechaCierre!.toLocal())} · '
                      '${sesion.usuarioCierreNombre ?? '—'}',
                ),
              if (sesion.montoEsperado != null)
                _DetalleFila(
                  etiqueta: 'Esperado',
                  valor: sesion.montoEsperado!.format(),
                ),
              if (sesion.montoContado != null)
                _DetalleFila(
                  etiqueta: 'Contado',
                  valor: sesion.montoContado!.format(),
                ),
              if (diferencia != null)
                _DetalleFila(
                  etiqueta: 'Diferencia',
                  valor: diferencia.format(),
                  color: diferencia.isZero
                      ? null
                      : (diferencia.isNegative
                            ? scheme.error
                            : scheme.tertiary),
                ),
              if (sesion.montoDejadoSiguiente != null)
                _DetalleFila(
                  etiqueta: 'Dejado para mañana',
                  valor: sesion.montoDejadoSiguiente!.format(),
                ),
              const Divider(height: AppSpacing.lg * 2),
              Text(
                'Movimientos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (sesion.movimientos.isEmpty)
                const Text('Esta sesión no tiene movimientos.')
              else
                Card(
                  child: Column(
                    children: [
                      for (final movimiento in sesion.movimientos)
                        ListTile(
                          leading: Icon(_iconoMovimiento(movimiento.tipo)),
                          title: Text(_tituloMovimiento(movimiento.tipo)),
                          subtitle: Text(
                            formatoFecha.format(movimiento.fecha.toLocal()),
                          ),
                          trailing: Text(
                            movimiento.monto.format(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: movimiento.monto.isNegative
                                  ? scheme.error
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _iconoMovimiento(TipoCajaMovimiento tipo) => switch (tipo) {
    TipoCajaMovimiento.venta => Icons.point_of_sale,
    TipoCajaMovimiento.gasto => Icons.receipt_long_outlined,
    TipoCajaMovimiento.compra => Icons.shopping_cart_outlined,
    TipoCajaMovimiento.pagoEmpleado => Icons.people_outline,
    TipoCajaMovimiento.entradaManual => Icons.add_circle_outline,
    TipoCajaMovimiento.salidaManual => Icons.remove_circle_outline,
    TipoCajaMovimiento.retiroCierre => Icons.lock_outline,
  };

  String _tituloMovimiento(TipoCajaMovimiento tipo) => switch (tipo) {
    TipoCajaMovimiento.venta => 'Venta',
    TipoCajaMovimiento.gasto => 'Gasto',
    TipoCajaMovimiento.compra => 'Compra',
    TipoCajaMovimiento.pagoEmpleado => 'Pago a empleado',
    TipoCajaMovimiento.entradaManual => 'Entrada manual',
    TipoCajaMovimiento.salidaManual => 'Salida manual',
    TipoCajaMovimiento.retiroCierre => 'Retiro de cierre',
  };
}

class _DetalleFila extends StatelessWidget {
  const _DetalleFila({required this.etiqueta, required this.valor, this.color});

  final String etiqueta;
  final String valor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              etiqueta,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
