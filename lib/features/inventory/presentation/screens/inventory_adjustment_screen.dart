import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../providers/inventory_providers.dart';

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

  bool _esEntrada = true;
  bool _guardando = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
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

    final cantidad = double.parse(_cantidadController.text);

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
        context.pop();
      },
      fail: (f) => _mostrarError(f.message),
    );
  }

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor);
    if (parsed == null || parsed <= 0) return 'Cantidad inválida';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ajuste de inventario')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
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
              controller: _motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                hintText: 'Ej. conteo físico, producto dañado, donación…',
              ),
              maxLines: 2,
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
      ),
    );
  }
}
