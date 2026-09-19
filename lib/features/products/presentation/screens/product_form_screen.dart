import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/producto.dart';
import '../providers/products_providers.dart';

/// Unidades sugeridas: se pueden tocar, pero el campo sigue siendo libre.
const List<String> unidadesSugeridas = [
  'unidad',
  'libra',
  'kg',
  'litro',
  'paquete',
  'caja',
];

/// Alta/edición de un producto (RF-PROD). Si `productId` es `null` crea uno
/// nuevo (incluye stock inicial); si no, edita el existente (cambios de
/// precio generan historial — RN-04).
///
/// El margen en vivo (precio de venta − costo) solo lo ve el Administrador,
/// igual que en el detalle del producto.
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

  /// Hubo algún cambio del usuario sin guardar (salir pide confirmación).
  bool _modificado = false;

  /// El guardado terminó: se puede salir sin preguntar.
  bool _salidaLibre = false;

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

  /// Cualquier cambio de un campo: marca el formulario como modificado y
  /// vuelve a dibujar (el margen se calcula en vivo con lo escrito).
  void _alCambiar() => setState(() => _modificado = true);

  Future<void> _confirmarSalida() async {
    final descartar = await mostrarConfirmacion(
      context,
      titulo: '¿Descartar cambios?',
      mensaje: 'Tienes datos sin guardar. Si sales ahora, se pierden.',
      confirmarLabel: 'Descartar',
      cancelarLabel: 'Seguir editando',
      destructivo: true,
    );
    if (!descartar || !mounted) return;
    setState(() => _salidaLibre = true);
    context.pop();
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
    if (!mounted) return;
    resultado.when(
      ok: (categoria) => setState(() {
        _categoriaId = categoria.id;
        _modificado = true;
      }),
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    if (!_formKey.currentState!.validate()) return;

    final usuario = ref.read(authControllerProvider).value;
    final usuarioId = switch (usuario) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) {
      AppSnackbar.error(context, 'No hay una sesión activa.');
      return;
    }

    // Los validators ya garantizan que todo se puede leer; si por algún
    // motivo no fuera así, no se guarda nada en vez de lanzar.
    final precioCompra = Money.tryParse(_precioCompraController.text);
    final precioVenta = Money.tryParse(_precioVentaController.text);
    final stockMinimo = double.tryParse(_stockMinimoController.text);
    final stockInicial = _esEdicion
        ? 0.0
        : double.tryParse(_stockInicialController.text);
    if (precioCompra == null ||
        precioVenta == null ||
        stockMinimo == null ||
        stockInicial == null) {
      return;
    }

    setState(() => _guardando = true);
    final repo = ref.read(productsRepositoryProvider);

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
            stockInicial: stockInicial,
            stockMinimo: stockMinimo,
            usuarioId: usuarioId,
          );

    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) {
        AppSnackbar.exito(context, 'Producto guardado.');
        setState(() => _salidaLibre = true);
        context.pop();
      },
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  String? _validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final monto = Money.tryParse(valor);
    if (monto == null || monto.isNegative) return 'Precio inválido';
    return null;
  }

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor);
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return 'Valor inválido';
    }
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
          body: const LoadingView(mensaje: 'Cargando producto...'),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(title: const Text('Editar producto')),
          body: ErrorState(
            mensaje: 'No se pudo cargar el producto.',
            error: error,
            stackTrace: stackTrace,
            onReintentar: () =>
                ref.invalidate(productoProvider(widget.productId!)),
          ),
        ),
        data: (producto) {
          if (producto == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Editar producto')),
              body: const EmptyState(
                icono: Icons.inventory_2_outlined,
                titulo: 'Producto no encontrado',
                descripcion: 'Puede que ya no exista. Vuelve a la lista.',
              ),
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
    final esAdmin = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };
    final unidadActual = _unidadController.text.trim().toLowerCase();

    return PopScope(
      canPop: _salidaLibre || !_modificado,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmarSalida();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto'),
        ),
        body: Form(
          key: _formKey,
          onChanged: _alCambiar,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe el nombre del producto'
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              categoriasAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => ErrorState(
                  compacto: true,
                  mensaje: 'No se pudieron cargar las categorías.',
                  error: error,
                  stackTrace: stackTrace,
                  onReintentar: () => ref.invalidate(categoriasProvider),
                ),
                data: (categorias) => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _categoriaId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Sin categoría'),
                          ),
                          for (final categoria in categorias)
                            DropdownMenuItem(
                              value: categoria.id,
                              child: Text(
                                categoria.nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (valor) => setState(() {
                          _categoriaId = valor;
                          _modificado = true;
                        }),
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
                  labelText: 'Unidad',
                  helperText: 'Elige una o escribe otra',
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Indica cómo se vende (unidad, libra, caja...)'
                    : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final unidad in unidadesSugeridas)
                    ChoiceChip(
                      label: Text(unidad),
                      selected: unidadActual == unidad,
                      onSelected: (_) {
                        _unidadController.text = unidad;
                        _alCambiar();
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      textInputAction: TextInputAction.next,
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
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: _validarPrecio,
                    ),
                  ),
                ],
              ),
              if (esAdmin) ...[
                const SizedBox(height: AppSpacing.sm),
                _MargenEnVivo(
                  costo: Money.tryParse(_precioCompraController.text),
                  venta: Money.tryParse(_precioVentaController.text),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_esEdicion)
                    Expanded(
                      child: TextFormField(
                        controller: _stockInicialController,
                        decoration: InputDecoration(
                          labelText: 'Stock inicial',
                          suffixText: _unidadController.text.trim(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
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
                      decoration: InputDecoration(
                        labelText: 'Stock mínimo',
                        suffixText: _unidadController.text.trim(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
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
      ),
    );
  }
}

/// Margen = precio de venta − costo, con su porcentaje sobre la venta, que
/// cambia mientras se escriben los precios. Con un margen negativo avisa que
/// se vende por debajo del costo (ícono + texto, no solo color).
class _MargenEnVivo extends StatelessWidget {
  const _MargenEnVivo({required this.costo, required this.venta});

  final Money? costo;
  final Money? venta;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (costo == null || venta == null) {
      return Text(
        'Escribe el precio de compra y el de venta para ver el margen.',
        style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    final margen = venta! - costo!;
    final porcentaje = venta!.cents > 0
        ? (margen.cents * 100 / venta!.cents).round()
        : null;
    final color = margen.isNegative ? scheme.error : context.appColors.exito;

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Margen', style: textTheme.labelLarge),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: MoneyText(
                    margen,
                    style: textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (porcentaje != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '($porcentaje%)',
                    style: textTheme.titleMedium?.copyWith(color: color),
                  ),
                ],
              ],
            ),
            if (margen.isNegative) ...[
              const SizedBox(height: AppSpacing.xs),
              EtiquetaEstado(
                icono: Icons.warning_amber_rounded,
                texto: 'Vendes por debajo del costo',
                color: scheme.error,
              ),
            ],
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

  void _crear() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Nueva categoría'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre'),
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _crear(),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Escribe el nombre de la categoría'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _crear, child: const Text('Crear')),
      ],
    );
  }
}
