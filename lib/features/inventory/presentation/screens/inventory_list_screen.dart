import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../products/domain/entities/producto.dart';
import '../providers/inventory_providers.dart';

/// Existencias (RF-INV-01): stock actual, valor a costo y alerta de stock
/// bajo de los productos activos.
class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final existenciasAsync = ref.watch(existenciasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar producto',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (texto) => ref
                  .read(existenciasBusquedaProvider.notifier)
                  .actualizar(texto),
            ),
          ),
          Expanded(
            child: existenciasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('No se pudo cargar el inventario.')),
              data: (productos) {
                if (productos.isEmpty) {
                  return const Center(
                    child: Text('No hay productos que coincidan.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  itemCount: productos.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      _ExistenciaTile(producto: productos[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExistenciaTile extends StatelessWidget {
  const _ExistenciaTile({required this.producto});

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valorACosto = Money(
      (producto.precioCompra.cents * producto.stockActual).round(),
    );
    return Card(
      child: ListTile(
        onTap: () => context.push('/inventario/${producto.id}'),
        leading: CircleAvatar(
          backgroundColor: producto.stockBajo
              ? scheme.errorContainer
              : scheme.primaryContainer,
          child: Icon(
            Icons.inventory_2_outlined,
            color: producto.stockBajo
                ? scheme.onErrorContainer
                : scheme.onPrimaryContainer,
          ),
        ),
        title: Text(producto.nombre),
        subtitle: Text(
          'Stock: ${producto.stockActual.toStringAsFixed(2)} ${producto.unidad}'
          ' · Valor a costo: ${valorACosto.format()}',
        ),
        trailing: producto.stockBajo
            ? Tooltip(
                message: 'Stock al mínimo o por debajo',
                child: Icon(Icons.warning_amber_outlined, color: scheme.error),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
