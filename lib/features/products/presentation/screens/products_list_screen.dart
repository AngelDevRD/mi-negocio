import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/producto.dart';
import '../providers/products_providers.dart';
import '../widgets/etiqueta_stock.dart';

/// Catálogo de productos (RF-PROD) con precio y existencias en una sola lista:
/// búsqueda, categoría y chips Todos | Stock bajo | Inactivos.
class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosProvider);
    final categoriasAsync = ref.watch(categoriasProvider);
    final filtro = ref.watch(productosFiltroProvider);
    final controller = ref.read(productosFiltroProvider.notifier);
    final esAdmin = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };

    // Chip activo: "Todos" = activos, "Inactivos" = inactivos.
    final chip = filtro.soloSinCosto
        ? _FiltroChip.sinCosto
        : filtro.soloStockBajo
        ? _FiltroChip.stockBajo
        : filtro.soloActivos == false
        ? _FiltroChip.inactivos
        : _FiltroChip.todos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            onSelected: (opcion) {
              if (opcion == 'categorias') {
                context.push(AppRoutes.productosCategorias);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'categorias',
                child: Text('Gestionar categorías'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Sin Hero: las pestañas del shell siguen montadas y sus FAB
        // compartirían la etiqueta por defecto al abrir una ruta encima.
        heroTag: null,
        onPressed: () => context.push(AppRoutes.productosNuevo),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final (valor, etiqueta) in [
                    (_FiltroChip.todos, 'Todos'),
                    (_FiltroChip.stockBajo, 'Stock bajo'),
                    (_FiltroChip.inactivos, 'Inactivos'),
                    // El costo solo lo ve el Administrador.
                    if (esAdmin) (_FiltroChip.sinCosto, 'Sin costo'),
                  ])
                    ChoiceChip(
                      label: Text(etiqueta),
                      selected: chip == valor,
                      onSelected: (_) => controller.actualizar(
                        (actual) => actual.copyWith(
                          soloActivos: valor != _FiltroChip.inactivos,
                          soloStockBajo: valor == _FiltroChip.stockBajo,
                          soloSinCosto: valor == _FiltroChip.sinCosto,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: productosAsync.when(
              loading: () => const LoadingView(),
              error: (error, stackTrace) => ErrorState(
                mensaje: 'No se pudieron cargar los productos.',
                error: error,
                stackTrace: stackTrace,
                onReintentar: () => ref.invalidate(productosProvider),
              ),
              data: (productos) {
                if (productos.isEmpty) {
                  final sinFiltros =
                      filtro.busqueda.trim().isEmpty &&
                      filtro.categoriaId == null &&
                      chip == _FiltroChip.todos;
                  return sinFiltros
                      ? _SinProductos(esAdmin: esAdmin)
                      : const EmptyState(
                          icono: Icons.search_off_outlined,
                          titulo: 'Sin resultados para este filtro',
                          descripcion:
                              'Prueba con otra búsqueda o cambia el filtro.',
                        );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    96,
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

enum _FiltroChip { todos, stockBajo, inactivos, sinCosto }

/// Catálogo vacío: invita a agregar el primer producto (y, solo el
/// Administrador, a importarlos desde Excel).
class _SinProductos extends StatelessWidget {
  const _SinProductos({required this.esAdmin});

  final bool esAdmin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyState(
              compacto: true,
              icono: Icons.inventory_2_outlined,
              titulo: 'Aún no tienes productos',
              descripcion:
                  'Agrega tu primer producto para empezar a vender y llevar '
                  'el control de tu inventario.',
              accionLabel: 'Agregar producto',
              onAccion: () => context.push(AppRoutes.productosNuevo),
            ),
            if (esAdmin)
              TextButton(
                onPressed: () => context.push(AppRoutes.datos),
                child: const Text('Importar desde Excel'),
              ),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;
    final detalle = [
      producto.categoriaNombre ?? 'Sin categoría',
      if (!producto.activo) 'Inactivo',
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/productos/${producto.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      detalle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          formatoCantidadUnidad(
                            producto.stockActual,
                            producto.unidad,
                          ),
                          style: textTheme.bodyMedium,
                        ),
                        EtiquetaStock(producto: producto),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: MoneyText(
                  producto.precioVenta,
                  textAlign: TextAlign.right,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
