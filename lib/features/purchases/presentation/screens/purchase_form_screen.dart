import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/tables/base.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/domain/entities/producto.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../domain/entities/compra.dart';
import '../providers/purchases_providers.dart';

/// Registro de una nueva compra (RF-COM): proveedor, número de factura, foto
/// de factura y productos con cantidades y costos.
class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _numeroFacturaController = TextEditingController();
  bool _guardando = false;

  /// `true` una vez guardada la compra: la salida ya no pide confirmación.
  bool _salidaLibre = false;

  @override
  void dispose() {
    _numeroFacturaController.dispose();
    super.dispose();
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    AppSnackbar.error(context, mensaje);
  }

  /// Hay datos escritos que se perderían al salir (el borrador vive en
  /// `nuevaCompraProvider`, así que cualquier campo distinto del inicial cuenta).
  bool _hayCambios(NuevaCompraState estado) =>
      estado.items.isNotEmpty ||
      estado.proveedorId != null ||
      estado.numeroFactura != null ||
      estado.fotoFacturaPath != null ||
      estado.pagadaDeCaja;

  Future<void> _confirmarSalida() async {
    final descartar = await mostrarConfirmacion(
      context,
      titulo: '¿Descartar compra?',
      mensaje: 'Tienes datos sin guardar. Si sales ahora, se pierden.',
      confirmarLabel: 'Descartar',
      cancelarLabel: 'Seguir editando',
      destructivo: true,
    );
    if (!descartar || !mounted) return;
    ref.read(nuevaCompraProvider.notifier).limpiar();
    setState(() => _salidaLibre = true);
    context.pop();
  }

  Future<String> _guardarFoto(XFile archivo) async {
    final docs = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${docs.path}/facturas');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    final extension = archivo.path.contains('.')
        ? archivo.path.substring(archivo.path.lastIndexOf('.'))
        : '.jpg';
    final destino = '${carpeta.path}/${generateUuidV4()}$extension';
    await File(archivo.path).copy(destino);
    return destino;
  }

  Future<void> _elegirFoto(ImageSource origen) async {
    final archivo = await ImagePicker().pickImage(
      source: origen,
      imageQuality: 80,
    );
    if (archivo == null) return;
    final ruta = await _guardarFoto(archivo);
    if (!mounted) return;
    ref.read(nuevaCompraProvider.notifier).establecerFotoFactura(ruta);
  }

  Future<void> _agregarProveedor() async {
    final resultado = await showDialog<({String nombre, String? telefono})>(
      context: context,
      builder: (_) => const _NuevoProveedorDialog(),
    );
    if (resultado == null || !mounted) return;
    final res = await ref
        .read(purchasesRepositoryProvider)
        .crearProveedor(nombre: resultado.nombre, telefono: resultado.telefono);
    res.when(
      ok: (proveedor) => ref
          .read(nuevaCompraProvider.notifier)
          .seleccionarProveedor(proveedor.id),
      fail: (f) => _mostrarError(f.message),
    );
  }

  Future<void> _agregarItem() async {
    final item = await showDialog<ItemCompraInput>(
      context: context,
      builder: (_) => const _AgregarItemDialog(),
    );
    if (item == null) return;
    ref.read(nuevaCompraProvider.notifier).agregarItem(item);
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final estado = ref.read(nuevaCompraProvider);
    if (estado.items.isEmpty) {
      _mostrarError('Agrega al menos un producto a la compra.');
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
        .read(nuevaCompraProvider.notifier)
        .registrar(usuarioId: usuarioId);
    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) {
        ref.read(nuevaCompraProvider.notifier).limpiar();
        setState(() => _salidaLibre = true);
        context.pop();
      },
      fail: (f) => _mostrarError(f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(nuevaCompraProvider);
    final proveedoresAsync = ref.watch(proveedoresProvider);
    if (_numeroFacturaController.text != (estado.numeroFactura ?? '')) {
      _numeroFacturaController.text = estado.numeroFactura ?? '';
    }

    return PopScope(
      canPop: _salidaLibre || !_hayCambios(estado),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmarSalida();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nueva compra')),
        // Total y acción siempre a la vista, aunque la lista de productos crezca.
        bottomNavigationBar: SafeArea(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: MoneyText(
                          estado.total,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: _guardando ? null : _guardar,
                    child: _guardando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar compra'),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            proveedoresAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => ErrorState(
                compacto: true,
                mensaje: 'No se pudieron cargar los proveedores.',
                error: error,
                stackTrace: stackTrace,
                onReintentar: () => ref.invalidate(proveedoresProvider),
              ),
              data: (proveedores) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: estado.proveedorId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Proveedor (opcional)',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Sin proveedor'),
                        ),
                        for (final proveedor in proveedores)
                          DropdownMenuItem(
                            value: proveedor.id,
                            child: Text(proveedor.nombre),
                          ),
                      ],
                      onChanged: (valor) => ref
                          .read(nuevaCompraProvider.notifier)
                          .seleccionarProveedor(valor),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Nuevo proveedor',
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _agregarProveedor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _numeroFacturaController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Número de factura (opcional)',
              ),
              onChanged: (valor) => ref
                  .read(nuevaCompraProvider.notifier)
                  .establecerNumeroFactura(valor.trim().isEmpty ? null : valor),
            ),
            const SizedBox(height: AppSpacing.md),
            _FotoFacturaPicker(
              rutaFoto: estado.fotoFacturaPath,
              onTomarFoto: () => _elegirFoto(ImageSource.camera),
              onElegirGaleria: () => _elegirFoto(ImageSource.gallery),
              onQuitar: () => ref
                  .read(nuevaCompraProvider.notifier)
                  .establecerFotoFactura(null),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pagada de caja'),
              subtitle: const Text(
                'Registra una salida en la caja abierta por el total de la compra.',
              ),
              value: estado.pagadaDeCaja,
              onChanged: (valor) => ref
                  .read(nuevaCompraProvider.notifier)
                  .establecerPagadaDeCaja(valor),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Productos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _agregarItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar producto'),
                ),
              ],
            ),
            if (estado.items.isEmpty)
              const EmptyState(
                compacto: true,
                icono: Icons.shopping_cart_outlined,
                titulo: 'Aún no has agregado productos',
                descripcion: 'Agrega lo que compraste para poder guardar.',
              )
            else
              for (var i = 0; i < estado.items.length; i++)
                _ItemTile(
                  item: estado.items[i],
                  onQuitar: () =>
                      ref.read(nuevaCompraProvider.notifier).quitarItem(i),
                ),
          ],
        ),
      ),
    );
  }
}

class _FotoFacturaPicker extends StatelessWidget {
  const _FotoFacturaPicker({
    required this.rutaFoto,
    required this.onTomarFoto,
    required this.onElegirGaleria,
    required this.onQuitar,
  });

  final String? rutaFoto;
  final VoidCallback onTomarFoto;
  final VoidCallback onElegirGaleria;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto de factura', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (rutaFoto != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(rutaFoto!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filledTonal(
                  tooltip: 'Quitar foto',
                  onPressed: onQuitar,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              if (Platform.isAndroid || Platform.isIOS)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTomarFoto,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Tomar foto'),
                  ),
                ),
              if (Platform.isAndroid || Platform.isIOS)
                const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onElegirGaleria,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.onQuitar});

  final ItemCompraInput item;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(item.productoNombre),
        subtitle: Row(
          children: [
            Text('${formatoCantidad(item.cantidad)} × '),
            Flexible(child: MoneyText(item.costoUnitario)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: MoneyText(
                item.subtotal,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'Quitar producto',
              icon: const Icon(Icons.delete_outline),
              onPressed: onQuitar,
            ),
          ],
        ),
      ),
    );
  }
}

class _NuevoProveedorDialog extends StatefulWidget {
  const _NuevoProveedorDialog();

  @override
  State<_NuevoProveedorDialog> createState() => _NuevoProveedorDialogState();
}

class _NuevoProveedorDialogState extends State<_NuevoProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _crear() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      nombre: _nombreController.text,
      telefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo proveedor'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombreController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _telefonoController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _crear(),
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
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

class _AgregarItemDialog extends ConsumerStatefulWidget {
  const _AgregarItemDialog();

  @override
  ConsumerState<_AgregarItemDialog> createState() => _AgregarItemDialogState();
}

class _AgregarItemDialogState extends ConsumerState<_AgregarItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _busquedaController = TextEditingController();
  final _cantidadController = TextEditingController(text: '1');
  final _costoController = TextEditingController();

  Producto? _seleccionado;

  @override
  void dispose() {
    _busquedaController.dispose();
    _cantidadController.dispose();
    _costoController.dispose();
    super.dispose();
  }

  void _seleccionar(Producto producto) {
    setState(() {
      _seleccionado = producto;
      _costoController.text = producto.precioCompra.format(symbol: false);
    });
  }

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor);
    if (parsed == null || parsed <= 0) return 'Cantidad inválida';
    return null;
  }

  String? _validarCosto(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final costo = Money.tryParse(valor);
    if (costo == null || costo.isNegative) return 'Costo inválido';
    return null;
  }

  void _agregar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ItemCompraInput(
        productoId: _seleccionado!.id,
        productoNombre: _seleccionado!.nombre,
        cantidad: double.parse(_cantidadController.text),
        costoUnitario: Money.parse(_costoController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productosAsync = ref.watch(productosParaSeleccionProvider);

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
                      .read(busquedaSeleccionProductoProvider.notifier)
                      .actualizar(texto),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 240,
                  child: productosAsync.when(
                    loading: () => const LoadingView(),
                    error: (error, stackTrace) => ErrorState(
                      compacto: true,
                      mensaje: 'No se pudieron cargar los productos.',
                      error: error,
                      stackTrace: stackTrace,
                      onReintentar: () =>
                          ref.invalidate(productosParaSeleccionProvider),
                    ),
                    data: (productos) {
                      if (productos.isEmpty) {
                        return const EmptyState(
                          compacto: true,
                          icono: Icons.search_off_outlined,
                          titulo: 'Sin resultados',
                        );
                      }
                      return ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, i) {
                          final producto = productos[i];
                          return ListTile(
                            title: Text(producto.nombre),
                            subtitle: Row(
                              children: [
                                const Text('Costo actual: '),
                                MoneyText(producto.precioCompra),
                              ],
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
                  textInputAction: TextInputAction.next,
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
                  controller: _costoController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _agregar(),
                  decoration: const InputDecoration(
                    labelText: 'Costo unitario',
                    prefixText: 'RD\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: _validarCosto,
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
          FilledButton(onPressed: _agregar, child: const Text('Agregar')),
      ],
    );
  }
}
