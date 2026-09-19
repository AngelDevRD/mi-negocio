import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../inventory/presentation/widgets/movimientos_stock_lista.dart';
import '../../domain/entities/producto.dart';
import '../providers/products_providers.dart';
import '../widgets/etiqueta_stock.dart';

/// Detalle ÚNICO de un producto (RF-PROD + RF-INV): precio, costo y margen
/// (costo y margen solo Administrador), stock con su estado, y debajo dos
/// pestañas: "Movimientos de stock" (kárdex) e "Historial de precios" (RN-04).
///
/// Pestañas en vez de una sola página larga: ambas listas pueden ser largas y
/// así ninguna queda enterrada bajo la otra; la cabecera se desplaza junto
/// con la lista (NestedScrollView) para que en teléfono no robe alto a las listas.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _procesando = false;

  Future<void> _alternarActivo(Producto producto) async {
    if (_procesando) return;
    final usuarioId = switch (ref.read(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) return;

    setState(() => _procesando = true);
    final resultado = await ref
        .read(productsRepositoryProvider)
        .establecerActivo(
          id: producto.id,
          activo: !producto.activo,
          usuarioId: usuarioId,
        );
    if (!mounted) return;
    setState(() => _procesando = false);
    resultado.when(
      ok: (_) => ref.invalidate(productoProvider(producto.id)),
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productoAsync = ref.watch(productoProvider(widget.productId));
    final esAdmin = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };

    return productoAsync.when(
      loading: () => Scaffold(appBar: AppBar(), body: const LoadingView()),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          mensaje: 'No se pudo cargar el producto.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: () =>
              ref.invalidate(productoProvider(widget.productId)),
        ),
      ),
      data: (producto) {
        if (producto == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icono: Icons.inventory_2_outlined,
              titulo: 'Producto no encontrado',
            ),
          );
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(producto.nombre),
              actions: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () =>
                      context.push('/productos/${producto.id}/editar'),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Más opciones',
                  onSelected: (opcion) {
                    if (opcion == 'activo') _alternarActivo(producto);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'activo',
                      enabled: !_procesando,
                      child: Text(producto.activo ? 'Desactivar' : 'Activar'),
                    ),
                  ],
                ),
              ],
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: _Cabecera(producto: producto, esAdmin: esAdmin),
                ),
                const SliverPersistentHeader(
                  pinned: true,
                  delegate: _PestanasDelegate(),
                ),
              ],
              body: TabBarView(
                children: [
                  MovimientosStockLista(productoId: producto.id),
                  _HistorialPrecios(productoId: producto.id),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Barra de pestañas fija bajo la cabecera.
class _PestanasDelegate extends SliverPersistentHeaderDelegate {
  const _PestanasDelegate();

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: const TabBar(
        tabs: [
          Tab(text: 'Movimientos de stock'),
          Tab(text: 'Historial de precios'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PestanasDelegate oldDelegate) => false;
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.producto, required this.esAdmin});

  final Producto producto;
  final bool esAdmin;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final margen = Money(
      producto.precioVenta.cents - producto.precioCompra.cents,
    );
    final porcentaje = producto.precioVenta.cents > 0
        ? (margen.cents * 100 / producto.precioVenta.cents).round()
        : null;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Card(
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  producto.categoriaNombre ?? 'Sin categoría',
                  if (!producto.activo) 'Inactivo',
                ].join(' · '),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Precio de venta', style: textTheme.labelLarge),
              MoneyText(
                producto.precioVenta,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (esAdmin) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Dato(
                        etiqueta: 'Costo',
                        valor: MoneyText(
                          producto.precioCompra,
                          style: textTheme.titleMedium,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _Dato(
                        etiqueta: porcentaje == null
                            ? 'Margen'
                            : 'Margen ($porcentaje%)',
                        valor: MoneyText(
                          margen,
                          style: textTheme.titleMedium?.copyWith(
                            color: margen.isNegative
                                ? scheme.error
                                : context.appColors.exito,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const Divider(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Dato(
                      etiqueta: 'Stock actual',
                      valor: Text(
                        formatoCantidadUnidad(
                          producto.stockActual,
                          producto.unidad,
                        ),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _Dato(
                      etiqueta: 'Stock mínimo',
                      valor: Text(
                        formatoCantidadUnidad(
                          producto.stockMinimo,
                          producto.unidad,
                        ),
                        style: textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              EtiquetaStock(producto: producto),
              if (esAdmin) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: () =>
                        context.push('/inventario/${producto.id}/ajuste'),
                    icon: const Icon(Icons.tune),
                    label: const Text('Ajustar stock'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final Widget valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        valor,
      ],
    );
  }
}

class _HistorialPrecios extends ConsumerWidget {
  const _HistorialPrecios({required this.productoId});

  final String productoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialPreciosProvider(productoId));
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return historialAsync.when(
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorState(
        mensaje: 'No se pudo cargar el historial.',
        error: error,
        stackTrace: stackTrace,
        onReintentar: () =>
            ref.invalidate(historialPreciosProvider(productoId)),
      ),
      data: (historial) {
        if (historial.isEmpty) {
          return const EmptyState(
            icono: Icons.history,
            titulo: 'Aún no hay cambios de precio registrados',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          itemCount: historial.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final entrada = historial[i];
            final tipoTexto = entrada.tipo == TipoPrecio.compra
                ? 'Precio de compra'
                : 'Precio de venta';
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(tipoTexto),
                subtitle: Text(
                  '${entrada.precioAnterior.format()} → '
                  '${entrada.precioNuevo.format()}\n'
                  '${formatoFecha.format(entrada.fecha.toLocal())} · '
                  '${entrada.usuarioNombre}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
