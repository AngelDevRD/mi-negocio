import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../products/domain/entities/producto.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../domain/entities/venta.dart';
import '../providers/sales_providers.dart';
import '../widgets/abrir_caja_dialog.dart';

/// Venta rápida (RF-VEN): grid táctil de productos, carrito y cobro con
/// monto recibido → cambio. Requiere caja abierta (RN-01).
class QuickSaleScreen extends ConsumerStatefulWidget {
  const QuickSaleScreen({super.key});

  @override
  ConsumerState<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends ConsumerState<QuickSaleScreen> {
  final _busquedaController = TextEditingController();

  @override
  void dispose() {
    ref
        .read(productosFiltroProvider.notifier)
        .actualizar((f) => f.copyWith(busqueda: ''));
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _agregarProducto(Producto producto) async {
    final item = await showDialog<ItemVentaInput>(
      context: context,
      builder: (_) => _CantidadMontoDialog(producto: producto),
    );
    if (item == null) return;
    if (!mounted) return;

    final carrito = ref.read(ventaRapidaCarritoProvider);
    final enCarrito = carrito.items
        .where((i) => i.productoId == producto.id)
        .fold<double>(0, (suma, i) => suma + i.cantidad);

    if (producto.stockActual - (enCarrito + item.cantidad) < 0) {
      final continuar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Stock insuficiente'),
          content: Text(
            '"${producto.nombre}" tiene ${producto.stockActual.toStringAsFixed(2)} '
            '${producto.unidad} en existencia. ¿Continuar de todos modos?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      if (continuar != true) return;
    }
    if (!mounted) return;

    ref.read(ventaRapidaCarritoProvider.notifier).agregarItem(item);
  }

  void _abrirCarrito() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CarritoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cajaAsync = ref.watch(cajaActualProvider);
    final carrito = ref.watch(ventaRapidaCarritoProvider);
    final productosAsync = ref.watch(productosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Venta rápida')),
      body: cajaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudo cargar el estado de caja.')),
        data: (caja) {
          if (caja == null) {
            return CajaCerradaView(
              onAbrir: () => mostrarDialogoAbrirCaja(context),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _busquedaController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar producto',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (texto) => ref
                      .read(productosFiltroProvider.notifier)
                      .actualizar((f) => f.copyWith(busqueda: texto)),
                ),
              ),
              Expanded(
                child: productosAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Center(
                    child: Text('No se pudieron cargar los productos.'),
                  ),
                  data: (productos) {
                    if (productos.isEmpty) {
                      return const Center(child: Text('Sin productos.'));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.sm,
                            crossAxisSpacing: AppSpacing.sm,
                            childAspectRatio: 1.3,
                          ),
                      itemCount: productos.length,
                      itemBuilder: (context, i) {
                        final producto = productos[i];
                        return _ProductoTile(
                          producto: producto,
                          onTap: () => _agregarProducto(producto),
                        );
                      },
                    );
                  },
                ),
              ),
              if (carrito.items.isNotEmpty)
                _CarritoBar(
                  total: carrito.total,
                  cantidadItems: carrito.items.length,
                  onTap: _abrirCarrito,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductoTile extends StatelessWidget {
  const _ProductoTile({required this.producto, required this.onTap});

  final Producto producto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                producto.nombre,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    producto.precioVenta.format(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  if (producto.stockBajo)
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 16,
                      color: scheme.error,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarritoBar extends StatelessWidget {
  const _CarritoBar({
    required this.total,
    required this.cantidadItems,
    required this.onTap,
  });

  final Money total;
  final int cantidadItems;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        color: scheme.primaryContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: scheme.onPrimaryContainer),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$cantidadItems producto${cantidadItems == 1 ? '' : 's'}',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
            Text(
              total.format(),
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarritoSheet extends ConsumerWidget {
  const _CarritoSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carrito = ref.watch(ventaRapidaCarritoProvider);
    final controller = ref.read(ventaRapidaCarritoProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Text('Carrito', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: carrito.items.isEmpty
                    ? const Center(child: Text('El carrito está vacío.'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: carrito.items.length,
                        itemBuilder: (context, i) {
                          final item = carrito.items[i];
                          return ListTile(
                            title: Text(item.productoNombre),
                            subtitle: Text(
                              '${item.cantidad.toStringAsFixed(2)} x '
                              '${item.precioUnitario.format()}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    if (item.cantidad <= 1) {
                                      controller.quitarItem(i);
                                    } else {
                                      controller.actualizarCantidad(
                                        i,
                                        item.cantidad - 1,
                                      );
                                    }
                                  },
                                ),
                                Text(item.cantidad.toStringAsFixed(0)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => controller
                                      .actualizarCantidad(i, item.cantidad + 1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => controller.quitarItem(i),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    carrito.total.format(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: carrito.items.isEmpty
                    ? null
                    : () => _cobrar(context, ref),
                child: const Text('Cobrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cobrar(BuildContext context, WidgetRef ref) async {
    final total = ref.read(ventaRapidaCarritoProvider).total;
    final recibido = await showDialog<Money>(
      context: context,
      builder: (_) => _CobroDialog(total: total),
    );
    if (recibido == null) return;

    final usuario = ref.read(authControllerProvider).value;
    final usuarioId = switch (usuario) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) return;
    if (!context.mounted) return;

    final resultado = await ref
        .read(ventaRapidaCarritoProvider.notifier)
        .registrar(tipo: TipoVenta.rapida, usuarioId: usuarioId);
    if (!context.mounted) return;

    resultado.when(
      ok: (_) {
        ref.read(ventaRapidaCarritoProvider.notifier).limpiar();
        Navigator.of(context).pop();
        final cambio = recibido - total;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Venta registrada. Cambio: ${cambio.format()}'),
          ),
        );
      },
      fail: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(f.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

class _CobroDialog extends StatefulWidget {
  const _CobroDialog({required this.total});

  final Money total;

  @override
  State<_CobroDialog> createState() => _CobroDialogState();
}

class _CobroDialogState extends State<_CobroDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _montoController = TextEditingController(
    text: widget.total.format(symbol: false),
  );

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Money? _recibidoActual() {
    try {
      return Money.parse(
        _montoController.text.isEmpty ? '0' : _montoController.text,
      );
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recibido = _recibidoActual();
    final cambio = recibido != null ? recibido - widget.total : null;

    return AlertDialog(
      title: const Text('Cobrar'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total'),
                Text(
                  widget.total.format(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _montoController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Monto recibido',
                prefixText: 'RD\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obligatorio';
                final monto = _recibidoActual();
                if (monto == null) return 'Monto inválido';
                if (monto < widget.total) return 'Monto insuficiente';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cambio'),
                Text(
                  (cambio == null || cambio.isNegative)
                      ? '--'
                      : cambio.format(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_recibidoActual());
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

/// Dialogo para agregar un producto al carrito indicando la cantidad o el
/// monto a vender (RF-VEN): permite vender por monto (ej. RD$ 150 de
/// chuleta) y calcula la cantidad correspondiente según el precio unitario.
class _CantidadMontoDialog extends StatefulWidget {
  const _CantidadMontoDialog({required this.producto});

  final Producto producto;

  @override
  State<_CantidadMontoDialog> createState() => _CantidadMontoDialogState();
}

class _CantidadMontoDialogState extends State<_CantidadMontoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _cantidadController = TextEditingController(text: '1');
  late final _montoController = TextEditingController(
    text: widget.producto.precioVenta.format(symbol: false),
  );

  @override
  void dispose() {
    _cantidadController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  double? _parseCantidad(String texto) =>
      double.tryParse(texto.replaceAll(',', '.').trim());

  void _onCantidadChanged(String texto) {
    final cantidad = _parseCantidad(texto);
    if (cantidad == null) return;
    final monto = Money((widget.producto.precioVenta.cents * cantidad).round());
    _montoController.text = monto.format(symbol: false);
    setState(() {});
  }

  void _onMontoChanged(String texto) {
    if (widget.producto.precioVenta.cents == 0) return;
    Money monto;
    try {
      monto = Money.parse(texto.isEmpty ? '0' : texto);
    } on FormatException {
      return;
    }
    final cantidad = monto.cents / widget.producto.precioVenta.cents;
    _cantidadController.text = cantidad.toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.producto.nombre),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Precio: ${widget.producto.precioVenta.format()} '
              'por ${widget.producto.unidad}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _cantidadController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Cantidad (${widget.producto.unidad})',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: _onCantidadChanged,
              validator: (v) {
                final cantidad = v == null ? null : _parseCantidad(v);
                if (cantidad == null || cantidad <= 0) {
                  return 'Cantidad inválida';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _montoController,
              decoration: const InputDecoration(
                labelText: 'Monto a vender',
                prefixText: 'RD\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: _onMontoChanged,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              ItemVentaInput(
                productoId: widget.producto.id,
                productoNombre: widget.producto.nombre,
                cantidad: _parseCantidad(_cantidadController.text)!,
                precioUnitario: widget.producto.precioVenta,
              ),
            );
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
