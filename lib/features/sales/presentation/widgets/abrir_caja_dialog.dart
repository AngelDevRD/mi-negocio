import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cash_register/presentation/providers/cash_register_providers.dart';
import '../providers/sales_providers.dart';

/// Diálogo para abrir una sesión de caja (RN-01) cuando no hay una abierta.
/// Devuelve `true` si la caja quedó abierta.
Future<bool?> mostrarDialogoAbrirCaja(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => const _AbrirCajaDialog(),
  );
}

/// Vista de bloqueo cuando no hay caja abierta (RN-01): explica el requisito
/// y ofrece abrirla.
class CajaCerradaView extends StatelessWidget {
  const CajaCerradaView({super.key, required this.onAbrir});

  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No hay una caja abierta. Debes abrirla antes de vender.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onAbrir, child: const Text('Abrir caja')),
          ],
        ),
      ),
    );
  }
}

class _AbrirCajaDialog extends ConsumerStatefulWidget {
  const _AbrirCajaDialog();

  @override
  ConsumerState<_AbrirCajaDialog> createState() => _AbrirCajaDialogState();
}

class _AbrirCajaDialogState extends ConsumerState<_AbrirCajaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController(text: '0');
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // RN-09: precarga el monto dejado en el último cierre como sugerencia.
    Future.microtask(() async {
      final sugerido = await ref.read(montoSugeridoAperturaProvider.future);
      if (!mounted || sugerido.isZero || _montoController.text != '0') return;
      setState(() => _montoController.text = sugerido.format(symbol: false));
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _abrir() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = ref.read(authControllerProvider).value;
    final usuarioId = switch (usuario) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) {
      setState(() => _error = 'No hay una sesión activa.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });
    final resultado = await ref
        .read(salesRepositoryProvider)
        .abrirCaja(
          montoApertura: Money.parse(_montoController.text),
          usuarioId: usuarioId,
        );
    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) => Navigator.of(context).pop(true),
      fail: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Abrir caja'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Debes abrir una caja antes de registrar una venta.'),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _montoController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Monto de apertura',
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
                final parsed = double.tryParse(v.replaceAll(',', ''));
                if (parsed == null || parsed < 0) return 'Monto inválido';
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _abrir,
          child: _guardando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Abrir'),
        ),
      ],
    );
  }
}
