import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/widgets/app_states.dart';
import '../../domain/entities/movimiento_inventario.dart';
import '../providers/inventory_providers.dart';

/// Movimientos de stock de un producto (kárdex, RF-INV-02): fecha, tipo,
/// cantidad, stock resultante, usuario y motivo. Se muestra dentro del
/// detalle del producto.
class MovimientosStockLista extends ConsumerWidget {
  const MovimientosStockLista({super.key, required this.productoId});

  final String productoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kardex = ref.watch(kardexProvider(productoId));
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return kardex.when(
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorState(
        mensaje: 'No se pudieron cargar los movimientos.',
        error: error,
        stackTrace: stackTrace,
        onReintentar: () => ref.invalidate(kardexProvider(productoId)),
      ),
      data: (movimientos) {
        if (movimientos.isEmpty) {
          return const EmptyState(
            icono: Icons.swap_vert,
            titulo: 'Aún no hay movimientos registrados',
            descripcion: 'Aquí verás las compras, ventas y ajustes de stock.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          itemCount: movimientos.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => _MovimientoTile(
            movimiento: movimientos[i],
            formatoFecha: formatoFecha,
          ),
        );
      },
    );
  }
}

class _MovimientoTile extends StatelessWidget {
  const _MovimientoTile({required this.movimiento, required this.formatoFecha});

  final MovimientoInventario movimiento;
  final DateFormat formatoFecha;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final esEntrada = movimiento.cantidad > 0;
    final signo = esEntrada ? '+' : '';
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          esEntrada ? Icons.add_circle_outline : Icons.remove_circle_outline,
          color: esEntrada ? scheme.primary : scheme.error,
        ),
        title: Text(_tituloMovimiento(movimiento.tipo)),
        subtitle: Text(
          '${formatoFecha.format(movimiento.fecha.toLocal())} · '
          '${movimiento.usuarioNombre}'
          '${movimiento.motivo != null ? '\n${movimiento.motivo}' : ''}',
        ),
        isThreeLine: movimiento.motivo != null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$signo${formatoCantidad(movimiento.cantidad)}',
              // titleSmall (14): en el trailing de un ListTile el texto sin estilo
              // salía a 11 px y el signo del movimiento apenas se leía.
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: esEntrada ? scheme.primary : scheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Stock: ${formatoCantidad(movimiento.stockResultante)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _tituloMovimiento(TipoMovimientoInventario tipo) => switch (tipo) {
    TipoMovimientoInventario.stockInicial => 'Stock inicial',
    TipoMovimientoInventario.compra => 'Compra',
    TipoMovimientoInventario.venta => 'Venta',
    TipoMovimientoInventario.ajusteEntrada => 'Ajuste de entrada',
    TipoMovimientoInventario.ajusteSalida => 'Ajuste de salida',
    TipoMovimientoInventario.anulacionVenta => 'Anulación de venta',
    TipoMovimientoInventario.anulacionCompra => 'Anulación de compra',
  };
}
