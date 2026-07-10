import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/producto.dart';
import '../providers/products_providers.dart';

/// Detalle de un producto (RF-PROD): información general e historial de
/// cambios de precio (RN-04).
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _procesando = false;

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _alternarActivo(Producto producto) async {
    final usuario = ref.read(authControllerProvider).value;
    final usuarioId = switch (usuario) {
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
      fail: (f) => _mostrarError(f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productoAsync = ref.watch(productoProvider(widget.productId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Producto'),
          actions: [
            productoAsync.maybeWhen(
              data: (producto) => producto == null
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          context.push('/productos/${producto.id}/editar'),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Detalle'),
              Tab(text: 'Historial de precios'),
            ],
          ),
        ),
        body: productoAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('No se pudo cargar el producto.')),
          data: (producto) {
            if (producto == null) {
              return const Center(child: Text('Producto no encontrado.'));
            }
            return TabBarView(
              children: [
                _DetalleTab(
                  producto: producto,
                  procesando: _procesando,
                  onAlternarActivo: () => _alternarActivo(producto),
                ),
                _HistorialTab(productoId: producto.id),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetalleTab extends StatelessWidget {
  const _DetalleTab({
    required this.producto,
    required this.procesando,
    required this.onAlternarActivo,
  });

  final Producto producto;
  final bool procesando;
  final VoidCallback onAlternarActivo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(producto.nombre, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(producto.categoriaNombre ?? 'Sin categoría'),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Fila('Unidad', producto.unidad),
                _Fila('Precio de compra', producto.precioCompra.format()),
                _Fila('Precio de venta', producto.precioVenta.format()),
                _Fila(
                  'Stock actual',
                  '${producto.stockActual.toStringAsFixed(2)} ${producto.unidad}',
                ),
                _Fila(
                  'Stock mínimo',
                  '${producto.stockMinimo.toStringAsFixed(2)} ${producto.unidad}',
                ),
                if (producto.stockBajo)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_outlined, color: scheme.error),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Stock al mínimo o por debajo',
                          style: TextStyle(color: scheme.error),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: procesando ? null : onAlternarActivo,
          icon: Icon(
            producto.activo ? Icons.visibility_off_outlined : Icons.visibility,
          ),
          label: Text(producto.activo ? 'Desactivar' : 'Activar'),
        ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            valor,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HistorialTab extends ConsumerWidget {
  const _HistorialTab({required this.productoId});

  final String productoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialPreciosProvider(productoId));
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return historialAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) =>
          const Center(child: Text('No se pudo cargar el historial.')),
      data: (historial) {
        if (historial.isEmpty) {
          return const Center(
            child: Text('Aún no hay cambios de precio registrados.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: historial.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final entrada = historial[i];
            final tipoTexto = entrada.tipo == TipoPrecio.compra
                ? 'Precio de compra'
                : 'Precio de venta';
            return Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(tipoTexto),
                subtitle: Text(
                  '${entrada.precioAnterior.format()} → ${entrada.precioNuevo.format()}\n'
                  '${formatoFecha.format(entrada.fecha.toLocal())} · ${entrada.usuarioNombre}',
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
