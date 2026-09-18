import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../providers/sales_providers.dart';
import '../widgets/abrir_caja_dialog.dart';
import '../widgets/pos_widgets.dart';

/// Ancho desde el que el carrito es un panel lateral fijo y la búsqueda toma
/// el foco al abrir (escritorio/tablet ancha).
const double _anchoEscritorio = 900;

/// Ancho del panel lateral del carrito.
const double _anchoPanelCarrito = 360;

/// Ancho máximo de una columna de la cuadrícula de productos.
const double _anchoColumnaProducto = 180;

/// Punto de venta único (RF-VEN): búsqueda, cuadrícula de productos y
/// carrito. En teléfono el carrito es una barra fija inferior que abre una
/// hoja; en pantallas anchas es un panel lateral. Requiere caja abierta
/// (RN-01).
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cajaAsync = ref.watch(cajaActualProvider);
    final hayItems = ref.watch(
      carritoVentaProvider.select((c) => c.items.isNotEmpty),
    );
    final escritorio = MediaQuery.sizeOf(context).width >= _anchoEscritorio;
    final cajaAbierta = cajaAsync.value != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva venta')),
      body: cajaAsync.when(
        loading: () => const LoadingView(),
        error: (error, stackTrace) => ErrorState(
          mensaje: 'No se pudo cargar el estado de caja.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: () => ref.invalidate(cajaActualProvider),
        ),
        data: (caja) {
          if (caja == null) {
            return CajaCerradaView(
              onAbrir: () => mostrarDialogoAbrirCaja(context),
            );
          }
          final catalogo = _Catalogo(
            controller: _busquedaController,
            autofocus: escritorio,
          );
          if (!escritorio) return catalogo;
          return Row(
            children: [
              Expanded(child: catalogo),
              const VerticalDivider(width: 1),
              const SizedBox(width: _anchoPanelCarrito, child: CarritoPanel()),
            ],
          );
        },
      ),
      // Fuera del body para que los snackbars queden por encima de la barra.
      bottomNavigationBar: !escritorio && cajaAbierta && hayItems
          ? const BarraCarrito()
          : null,
    );
  }
}

/// Búsqueda + cuadrícula de productos.
class _Catalogo extends ConsumerWidget {
  const _Catalogo({required this.controller, required this.autofocus});

  final TextEditingController controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosParaSeleccionProvider);
    final busqueda = ref.watch(busquedaSeleccionProductoProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Buscar producto',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: busqueda.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Borrar búsqueda',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        ref
                            .read(busquedaSeleccionProductoProvider.notifier)
                            .actualizar('');
                      },
                    ),
            ),
            onChanged: (texto) => ref
                .read(busquedaSeleccionProductoProvider.notifier)
                .actualizar(texto),
          ),
        ),
        Expanded(
          child: productosAsync.when(
            loading: () => const LoadingView(),
            error: (error, stackTrace) => ErrorState(
              mensaje: 'No se pudieron cargar los productos.',
              error: error,
              stackTrace: stackTrace,
              onReintentar: () =>
                  ref.invalidate(productosParaSeleccionProvider),
            ),
            data: (productos) {
              if (productos.isEmpty) {
                return busqueda.trim().isEmpty
                    ? const EmptyState(
                        icono: Icons.inventory_2_outlined,
                        titulo: 'Sin productos para vender',
                        descripcion:
                            'Agrega productos activos desde la pestaña '
                            'Productos.',
                      )
                    : EmptyState(
                        icono: Icons.search_off_outlined,
                        titulo: 'Sin resultados',
                        descripcion:
                            'No hay productos que coincidan con '
                            '"${busqueda.trim()}".',
                      );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: _anchoColumnaProducto,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisExtent: alturaTarjetaProducto(context),
                ),
                itemCount: productos.length,
                itemBuilder: (context, i) {
                  final producto = productos[i];
                  return ProductoPosTile(
                    producto: producto,
                    onTap: () =>
                        agregarProductoAlCarrito(context, ref, producto),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
