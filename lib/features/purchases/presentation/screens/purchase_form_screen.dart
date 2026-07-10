import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/tables/base.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
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

  @override
  void dispose() {
    _numeroFacturaController.dispose();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva compra')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          proveedoresAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('No se pudieron cargar proveedores.'),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Productos', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _agregarItem,
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
                onQuitar: () =>
                    ref.read(nuevaCompraProvider.notifier).quitarItem(i),
              ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  estado.total.format(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
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
                : const Text('Guardar compra'),
          ),
        ],
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
                  onPressed: onQuitar,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTomarFoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Tomar foto'),
                ),
              ),
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
      child: ListTile(
        title: Text(item.productoNombre),
        subtitle: Text(
          '${item.cantidad.toStringAsFixed(2)} x ${item.costoUnitario.format()}',
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
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _telefonoController,
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
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop((
              nombre: _nombreController.text,
              telefono: _telefonoController.text.trim().isEmpty
                  ? null
                  : _telefonoController.text.trim(),
            ));
          },
          child: const Text('Crear'),
        ),
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
    ref
        .read(productosFiltroProvider.notifier)
        .actualizar((f) => f.copyWith(busqueda: ''));
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
    final parsed = double.tryParse(valor.replaceAll(',', ''));
    if (parsed == null || parsed < 0) return 'Costo inválido';
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
                              'Costo actual: ${producto.precioCompra.format()}',
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
                  controller: _costoController,
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
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              Navigator.of(context).pop(
                ItemCompraInput(
                  productoId: _seleccionado!.id,
                  productoNombre: _seleccionado!.nombre,
                  cantidad: double.parse(_cantidadController.text),
                  costoUnitario: Money.parse(_costoController.text),
                ),
              );
            },
            child: const Text('Agregar'),
          ),
      ],
    );
  }
}
