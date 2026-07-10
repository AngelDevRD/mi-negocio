import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/producto.dart';
import '../providers/products_providers.dart';

/// Catálogo de productos (RF-PROD): búsqueda, filtros por categoría/estado
/// y acceso a alta, edición y gestión de categorías.
class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final filtro = ref.watch(productosFiltroProvider);
    final controller = ref.read(productosFiltroProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            tooltip: 'Categorías',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => context.push(AppRoutes.productosCategorias),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.productosNuevo),
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
      ),
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
              onChanged: (texto) => controller.actualizar(
                (actual) => actual.copyWith(busqueda: texto),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: categoriasAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (categorias) => DropdownButtonFormField<String?>(
                initialValue: filtro.categoriaId,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  for (final categoria in categorias)
                    DropdownMenuItem(
                      value: categoria.id,
                      child: Text(categoria.nombre),
                    ),
                ],
                onChanged: (valor) => controller.actualizar(
                  (actual) => actual.copyWith(categoriaId: valor),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SegmentedButton<bool?>(
              segments: const [
                ButtonSegment(value: true, label: Text('Activos')),
                ButtonSegment(value: false, label: Text('Inactivos')),
                ButtonSegment(value: null, label: Text('Todos')),
              ],
              selected: {filtro.soloActivos},
              onSelectionChanged: (seleccion) => controller.actualizar(
                (actual) => actual.copyWith(soloActivos: seleccion.first),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: productosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('No se pudieron cargar los productos.'),
              ),
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
                      _ProductoTile(producto: productos[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductoTile extends StatelessWidget {
  const _ProductoTile({required this.producto});

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: () => context.push('/productos/${producto.id}'),
        leading: CircleAvatar(
          backgroundColor: producto.activo
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          child: Icon(
            Icons.inventory_2_outlined,
            color: producto.activo ? scheme.onPrimaryContainer : scheme.outline,
          ),
        ),
        title: Text(producto.nombre),
        subtitle: Text(
          '${producto.categoriaNombre ?? 'Sin categoría'} · '
          '${producto.unidad} · Venta: ${producto.precioVenta.format()}'
          '${producto.activo ? '' : ' · Inactivo'}',
        ),
        trailing: producto.stockBajo
            ? Tooltip(
                message: 'Stock bajo',
                child: Icon(Icons.warning_amber_outlined, color: scheme.error),
              )
            : Text(producto.stockActual.toStringAsFixed(2)),
      ),
    );
  }
}
