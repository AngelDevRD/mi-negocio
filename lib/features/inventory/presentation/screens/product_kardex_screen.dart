import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../domain/entities/movimiento_inventario.dart';
import '../providers/inventory_providers.dart';

/// Kárdex de un producto (RF-INV-02): historial de movimientos de
/// inventario con fecha, tipo, cantidad, stock resultante, usuario y motivo.
class ProductKardexScreen extends ConsumerWidget {
  const ProductKardexScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productoAsync = ref.watch(productoProvider(productId));
    final kardexAsync = ref.watch(kardexProvider(productId));
    final usuario = ref.watch(authControllerProvider).value;
    final esAdmin = switch (usuario) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: productoAsync.maybeWhen(
          data: (producto) => Text(producto?.nombre ?? 'Kárdex'),
          orElse: () => const Text('Kárdex'),
        ),
      ),
      floatingActionButton: esAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/inventario/$productId/ajuste'),
              icon: const Icon(Icons.tune),
              label: const Text('Ajustar'),
            )
          : null,
      body: Column(
        children: [
          productoAsync.maybeWhen(
            data: (producto) => producto == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stock actual',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '${producto.stockActual.toStringAsFixed(2)} ${producto.unidad}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: kardexAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('No se pudo cargar el kárdex.')),
              data: (movimientos) {
                if (movimientos.isEmpty) {
                  return const Center(
                    child: Text('Aún no hay movimientos registrados.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  itemCount: movimientos.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _MovimientoTile(
                    movimiento: movimientos[i],
                    formatoFecha: formatoFecha,
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
      child: ListTile(
        leading: Icon(
          esEntrada ? Icons.add_circle_outline : Icons.remove_circle_outline,
          color: esEntrada ? scheme.primary : scheme.error,
        ),
        title: Text(_tituloMovimiento(movimiento.tipo)),
        subtitle: Text(
          '${formatoFecha.format(movimiento.fecha.toLocal())} · ${movimiento.usuarioNombre}'
          '${movimiento.motivo != null ? '\n${movimiento.motivo}' : ''}',
        ),
        isThreeLine: movimiento.motivo != null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$signo${movimiento.cantidad.toStringAsFixed(2)}',
              style: TextStyle(
                color: esEntrada ? scheme.primary : scheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Stock: ${movimiento.stockResultante.toStringAsFixed(2)}',
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
