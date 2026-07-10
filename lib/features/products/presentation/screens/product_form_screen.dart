import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/producto.dart';
import '../providers/products_providers.dart';

/// Alta/edición de un producto (RF-PROD). Si `productId` es `null` crea uno
/// nuevo (incluye stock inicial); si no, edita el existente (cambios de
/// precio generan historial — RN-04).
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _unidadController = TextEditingController(text: 'unidad');
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockInicialController = TextEditingController(text: '0');
  final _stockMinimoController = TextEditingController(text: '0');

  String? _categoriaId;
  bool _guardando = false;
  bool _inicializado = false;

  bool get _esEdicion => widget.productId != null;

  @override
  void dispose() {
    _nombreController.dispose();
    _unidadController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockInicialController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  void _cargarDatos(Producto producto) {
    if (_inicializado) return;
    _inicializado = true;
    _nombreController.text = producto.nombre;
    _unidadController.text = producto.unidad;
    _precioCompraController.text = producto.precioCompra.format(symbol: false);
    _precioVentaController.text = producto.precioVenta.format(symbol: false);
    _stockMinimoController.text = producto.stockMinimo.toString();
    _categoriaId = producto.categoriaId;
  }

  Future<void> _crearCategoria() async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => const _NuevaCategoriaDialog(),
    );
    if (nombre == null || !mounted) return;
    final resultado = await ref
        .read(productsRepositoryProvider)
        .crearCategoria(nombre);
    resultado.when(
      ok: (categoria) => setState(() => _categoriaId = categoria.id),
      fail: (f) => _mostrarError(f.message),
    );
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

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
    final repo = ref.read(productsRepositoryProvider);
    final precioCompra = Money.parse(_precioCompraController.text);
    final precioVenta = Money.parse(_precioVentaController.text);
    final stockMinimo = double.parse(_stockMinimoController.text);

    final resultado = _esEdicion
        ? await repo.actualizarProducto(
            id: widget.productId!,
            nombre: _nombreController.text,
            categoriaId: _categoriaId,
            unidad: _unidadController.text,
            precioCompra: precioCompra,
            precioVenta: precioVenta,
            stockMinimo: stockMinimo,
            usuarioId: usuarioId,
          )
        : await repo.crearProducto(
            nombre: _nombreController.text,
            categoriaId: _categoriaId,
            unidad: _unidadController.text,
            precioCompra: precioCompra,
            precioVenta: precioVenta,
            stockInicial: double.parse(_stockInicialController.text),
            stockMinimo: stockMinimo,
            usuarioId: usuarioId,
          );

    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) => context.pop(),
      fail: (f) => _mostrarError(f.message),
    );
  }

  String? _validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor.replaceAll(',', ''));
    if (parsed == null || parsed < 0) return 'Precio inválido';
    return null;
  }

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor);
    if (parsed == null || parsed < 0) return 'Valor inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final productoAsync = _esEdicion
        ? ref.watch(productoProvider(widget.productId!))
        : null;

    if (productoAsync != null) {
      return productoAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Editar producto')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Scaffold(
          appBar: AppBar(title: const Text('Editar producto')),
          body: const Center(child: Text('No se pudo cargar el producto.')),
        ),
        data: (producto) {
          if (producto == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Editar producto')),
              body: const Center(child: Text('Producto no encontrado.')),
            );
          }
          _cargarDatos(producto);
          return _buildForm(context, categoriasAsync);
        },
      );
    }
    return _buildForm(context, categoriasAsync);
  }

  Widget _buildForm(
    BuildContext context,
    AsyncValue<List<Categoria>> categoriasAsync,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            categoriasAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('No se pudieron cargar categorías.'),
              data: (categorias) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _categoriaId,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Sin categoría'),
                        ),
                        for (final categoria in categorias)
                          DropdownMenuItem(
                            value: categoria.id,
                            child: Text(categoria.nombre),
                          ),
                      ],
                      onChanged: (valor) =>
                          setState(() => _categoriaId = valor),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Nueva categoría',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _crearCategoria,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _unidadController,
              decoration: const InputDecoration(
                labelText: 'Unidad (unidad, libra, caja…)',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioCompraController,
                    decoration: const InputDecoration(
                      labelText: 'Precio de compra',
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
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _precioVentaController,
                    decoration: const InputDecoration(
                      labelText: 'Precio de venta',
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
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (!_esEdicion)
                  Expanded(
                    child: TextFormField(
                      controller: _stockInicialController,
                      decoration: const InputDecoration(
                        labelText: 'Stock inicial',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      validator: _validarCantidad,
                    ),
                  ),
                if (!_esEdicion) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _stockMinimoController,
                    decoration: const InputDecoration(
                      labelText: 'Stock mínimo',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: _validarCantidad,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NuevaCategoriaDialog extends StatefulWidget {
  const _NuevaCategoriaDialog();

  @override
  State<_NuevaCategoriaDialog> createState() => _NuevaCategoriaDialogState();
}

class _NuevaCategoriaDialogState extends State<_NuevaCategoriaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva categoría'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
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
            Navigator.of(context).pop(_controller.text);
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
