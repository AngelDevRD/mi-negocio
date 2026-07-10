import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// Venta detallada (RF-VEN): líneas editables (cantidad/precio, precio solo
/// editable por Administrador) y nota opcional. Requiere caja abierta
/// (RN-01).
class DetailedSaleScreen extends ConsumerStatefulWidget {
  const DetailedSaleScreen({super.key});

  @override
  ConsumerState<DetailedSaleScreen> createState() => _DetailedSaleScreenState();
}

class _DetailedSaleScreenState extends ConsumerState<DetailedSaleScreen> {
  final _notaController = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    ref
        .read(productosFiltroProvider.notifier)
        .actualizar((f) => f.copyWith(busqueda: ''));
    _notaController.dispose();
    super.dispose();
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _agregarItem(bool esAdmin) async {
    final item = await showDialog<ItemVentaInput>(
      context: context,
      builder: (_) => _AgregarItemDialog(esAdmin: esAdmin),
    );
    if (item == null) return;
    ref.read(ventaDetalladaCarritoProvider.notifier).agregarItem(item);
  }

  Future<void> _editarItem(
    int indice,
    ItemVentaInput item,
    bool esAdmin,
  ) async {
    final actualizado = await showDialog<ItemVentaInput>(
      context: context,
      builder: (_) => _EditarItemDialog(item: item, esAdmin: esAdmin),
    );
    if (actualizado == null) return;
    final controller = ref.read(ventaDetalladaCarritoProvider.notifier);
    controller.actualizarCantidad(indice, actualizado.cantidad);
    if (esAdmin) {
      controller.actualizarPrecio(indice, actualizado.precioUnitario);
    }
  }

  Future<void> _registrar() async {
    final estado = ref.read(ventaDetalladaCarritoProvider);
    if (estado.items.isEmpty) {
      _mostrarError('Agrega al menos un producto a la venta.');
      return;
    }

    final usuario = ref.read(authControllerProvider).value;
    final usuarioId = switch (usuario) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) {
      _mostrarError('No hay una sesión activa.');
      return;
    }

    setState(() => _guardando = true);
    final resultado = await ref
        .read(ventaDetalladaCarritoProvider.notifier)
        .registrar(tipo: TipoVenta.detallada, usuarioId: usuarioId);
    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) {
        ref.read(ventaDetalladaCarritoProvider.notifier).limpiar();
        context.pop();
      },
      fail: (f) => _mostrarError(f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cajaAsync = ref.watch(cajaActualProvider);
    final usuario = ref.watch(authControllerProvider).value;
    final esAdmin = switch (usuario) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };
    final estado = ref.watch(ventaDetalladaCarritoProvider);

    if (_notaController.text != (estado.nota ?? '')) {
      _notaController.text = estado.nota ?? '';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Venta detallada')),
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
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Productos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => _agregarItem(esAdmin),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar producto'),
                  ),
                ],
              ),
              if (estado.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text('Aún no has agregado productos.'),
                )
              else
                for (var i = 0; i < estado.items.length; i++)
                  _ItemTile(
                    item: estado.items[i],
                    onTap: () => _editarItem(i, estado.items[i], esAdmin),
                    onQuitar: () => ref
                        .read(ventaDetalladaCarritoProvider.notifier)
                        .quitarItem(i),
                  ),
              const Divider(),
              TextFormField(
                controller: _notaController,
                decoration: const InputDecoration(labelText: 'Nota (opcional)'),
                maxLines: 2,
                onChanged: (valor) => ref
                    .read(ventaDetalladaCarritoProvider.notifier)
                    .establecerNota(valor.trim().isEmpty ? null : valor),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      estado.total.format(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _guardando ? null : _registrar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrar venta'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.onTap,
    required this.onQuitar,
  });

  final ItemVentaInput item;
  final VoidCallback onTap;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(item.productoNombre),
        subtitle: Text(
          '${item.cantidad.toStringAsFixed(2)} x ${item.precioUnitario.format()}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.subtotal.format(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onQuitar,
            ),
          ],
        ),
      ),
    );
  }
}

class _AgregarItemDialog extends ConsumerStatefulWidget {
  const _AgregarItemDialog({required this.esAdmin});

  final bool esAdmin;

  @override
  ConsumerState<_AgregarItemDialog> createState() => _AgregarItemDialogState();
}

class _AgregarItemDialogState extends ConsumerState<_AgregarItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _busquedaController = TextEditingController();
  final _cantidadController = TextEditingController(text: '1');
  final _precioController = TextEditingController();

  Producto? _seleccionado;

  @override
  void dispose() {
    ref
        .read(productosFiltroProvider.notifier)
        .actualizar((f) => f.copyWith(busqueda: ''));
    _busquedaController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _seleccionar(Producto producto) {
    setState(() {
      _seleccionado = producto;
      _precioController.text = producto.precioVenta.format(symbol: false);
    });
  }

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor);
    if (parsed == null || parsed <= 0) return 'Cantidad inválida';
    return null;
  }

  String? _validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor.replaceAll(',', ''));
    if (parsed == null || parsed < 0) return 'Precio inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final productosAsync = ref.watch(productosProvider);

    return AlertDialog(
      title: const Text('Agregar producto'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_seleccionado == null) ...[
                TextField(
                  controller: _busquedaController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Buscar producto',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (texto) => ref
                      .read(productosFiltroProvider.notifier)
                      .actualizar((f) => f.copyWith(busqueda: texto)),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 240,
                  child: productosAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) =>
                        const Center(child: Text('No se pudieron cargar.')),
                    data: (productos) {
                      if (productos.isEmpty) {
                        return const Center(child: Text('Sin resultados.'));
                      }
                      return ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, i) {
                          final producto = productos[i];
                          return ListTile(
                            title: Text(producto.nombre),
                            subtitle: Text(
                              'Precio: ${producto.precioVenta.format()} · '
                              'Stock: ${producto.stockActual.toStringAsFixed(2)} ${producto.unidad}',
                            ),
                            onTap: () => _seleccionar(producto),
                          );
                        },
                      );
                    },
                  ),
                ),
              ] else ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_seleccionado!.nombre),
                  trailing: TextButton(
                    onPressed: () => setState(() => _seleccionado = null),
                    child: const Text('Cambiar'),
                  ),
                ),
                TextFormField(
                  controller: _cantidadController,
                  decoration: InputDecoration(
                    labelText: 'Cantidad (${_seleccionado!.unidad})',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: _validarCantidad,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _precioController,
                  enabled: widget.esAdmin,
                  decoration: const InputDecoration(
                    labelText: 'Precio unitario',
                    prefixText: 'RD\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: _validarPrecio,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (_seleccionado != null)
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              Navigator.of(context).pop(
                ItemVentaInput(
                  productoId: _seleccionado!.id,
                  productoNombre: _seleccionado!.nombre,
                  cantidad: double.parse(_cantidadController.text),
                  precioUnitario: Money.parse(_precioController.text),
                ),
              );
            },
            child: const Text('Agregar'),
          ),
      ],
    );
  }
}

class _EditarItemDialog extends StatefulWidget {
  const _EditarItemDialog({required this.item, required this.esAdmin});

  final ItemVentaInput item;
  final bool esAdmin;

  @override
  State<_EditarItemDialog> createState() => _EditarItemDialogState();
}

class _EditarItemDialogState extends State<_EditarItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _cantidadController = TextEditingController(
    text: widget.item.cantidad.toStringAsFixed(2),
  );
  late final _precioController = TextEditingController(
    text: widget.item.precioUnitario.format(symbol: false),
  );

  @override
  void dispose() {
    _cantidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor);
    if (parsed == null || parsed <= 0) return 'Cantidad inválida';
    return null;
  }

  String? _validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor.replaceAll(',', ''));
    if (parsed == null || parsed < 0) return 'Precio inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item.productoNombre),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _cantidadController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              validator: _validarCantidad,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _precioController,
              enabled: widget.esAdmin,
              decoration: const InputDecoration(
                labelText: 'Precio unitario',
                prefixText: 'RD\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: _validarPrecio,
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
                productoId: widget.item.productoId,
                productoNombre: widget.item.productoNombre,
                cantidad: double.parse(_cantidadController.text),
                precioUnitario: Money.parse(_precioController.text),
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
