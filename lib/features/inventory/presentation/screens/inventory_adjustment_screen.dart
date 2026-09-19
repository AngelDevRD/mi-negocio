import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/domain/entities/producto.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../providers/inventory_providers.dart';

/// Motivos frecuentes de un ajuste. "Otro" deja el campo vacío para escribir.
const List<String> motivosDeAjuste = [
  'Merma',
  'Vencido',
  'Conteo físico',
  'Regalo',
  'Otro',
];

/// Ajuste manual de inventario (RF-INV-03/RN-19): entrada o salida con
/// motivo obligatorio, solo Administrador.
class InventoryAdjustmentScreen extends ConsumerStatefulWidget {
  const InventoryAdjustmentScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<InventoryAdjustmentScreen> createState() =>
      _InventoryAdjustmentScreenState();
}

class _InventoryAdjustmentScreenState
    extends ConsumerState<InventoryAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController();
  final _motivoFocus = FocusNode();

  bool _esEntrada = true;
  bool _guardando = false;

  /// Se tocó el chip "Otro" y el motivo se escribe a mano.
  bool _otro = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    _motivoFocus.dispose();
    super.dispose();
  }

  void _elegirMotivo(String motivo) {
    setState(() {
      _otro = motivo == 'Otro';
      _motivoController.text = _otro ? '' : motivo;
    });
    if (_otro) _motivoFocus.requestFocus();
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

    final cantidad = double.tryParse(_cantidadController.text);
    if (cantidad == null) return;

    setState(() => _guardando = true);
    final resultado = await ref
        .read(inventoryRepositoryProvider)
        .ajusteManual(
          productoId: widget.productId,
          cantidad: _esEntrada ? cantidad : -cantidad,
          motivo: _motivoController.text,
          usuarioId: usuarioId,
        );
    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) {
        ref.invalidate(productoProvider(widget.productId));
        AppSnackbar.exito(context, 'Ajuste registrado.');
        context.pop();
      },
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor);
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      return 'Cantidad inválida';
    }
    return null;
  }

  String? _validarMotivo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El motivo es obligatorio';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final productoAsync = ref.watch(productoProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Ajuste de inventario')),
      body: productoAsync.when(
        loading: () => const LoadingView(mensaje: 'Cargando producto...'),
        error: (error, stackTrace) => ErrorState(
          mensaje: 'No se pudo cargar el producto.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: () =>
              ref.invalidate(productoProvider(widget.productId)),
        ),
        data: (producto) {
          if (producto == null) {
            return const EmptyState(
              icono: Icons.inventory_2_outlined,
              titulo: 'Producto no encontrado',
              descripcion: 'Puede que ya no exista. Vuelve a la lista.',
            );
          }
          return _formulario(context, producto);
        },
      ),
    );
  }

  Widget _formulario(BuildContext context, Producto producto) {
    final textTheme = Theme.of(context).textTheme;
    final unidad = producto.unidad;

    return Form(
      key: _formKey,
      // Reconstruye al escribir: "quedará Y" se calcula con lo escrito.
      onChanged: () => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            producto.nombre,
            style: textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Entrada'),
                icon: Icon(Icons.add_circle_outline),
              ),
              ButtonSegment(
                value: false,
                label: Text('Salida'),
                icon: Icon(Icons.remove_circle_outline),
              ),
            ],
            selected: {_esEntrada},
            onSelectionChanged: (seleccion) =>
                setState(() => _esEntrada = seleccion.first),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _cantidadController,
            decoration: InputDecoration(
              labelText: 'Cantidad',
              suffixText: unidad,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            validator: _validarCantidad,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StockResultante(
            stockActual: producto.stockActual,
            unidad: unidad,
            cantidad: double.tryParse(_cantidadController.text),
            esEntrada: _esEntrada,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Motivo', style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final motivo in motivosDeAjuste)
                ChoiceChip(
                  label: Text(motivo),
                  selected: motivo == 'Otro'
                      ? _otro &&
                            !motivosDeAjuste.contains(_motivoController.text)
                      : _motivoController.text == motivo,
                  onSelected: (_) => _elegirMotivo(motivo),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _motivoController,
            focusNode: _motivoFocus,
            decoration: const InputDecoration(
              labelText: 'Motivo del ajuste',
              hintText: 'Elige uno arriba o escribe el motivo',
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            validator: _validarMotivo,
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
                : const Text('Guardar ajuste'),
          ),
        ],
      ),
    );
  }
}

/// "Stock actual X · quedará Y" (con la unidad). Si el ajuste deja el stock
/// en negativo lo avisa con ícono y texto; el ajuste igual se puede guardar
/// (una corrección de inventario puede necesitarlo).
class _StockResultante extends StatelessWidget {
  const _StockResultante({
    required this.stockActual,
    required this.unidad,
    required this.cantidad,
    required this.esEntrada,
  });

  final double stockActual;
  final String unidad;
  final double? cantidad;
  final bool esEntrada;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final actual = 'Stock actual ${formatoCantidadUnidad(stockActual, unidad)}';
    final valida = cantidad != null && cantidad!.isFinite && cantidad! > 0;
    if (!valida) {
      return Text(
        actual,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      );
    }
    final quedara = stockActual + (esEntrada ? cantidad! : -cantidad!);
    final negativo = quedara < 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$actual · quedará ${formatoCantidadUnidad(quedara, unidad)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: negativo ? scheme.error : null,
          ),
        ),
        if (negativo) ...[
          const SizedBox(height: AppSpacing.xs),
          EtiquetaEstado(
            icono: Icons.warning_amber_rounded,
            texto: 'El stock quedará en negativo',
            color: scheme.error,
          ),
        ],
      ],
    );
  }
}
