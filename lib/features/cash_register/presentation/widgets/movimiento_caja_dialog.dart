import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/cash_register_providers.dart';

/// Motivos rápidos: lo que un colmado saca o mete a la caja casi todos los días.
const _motivosSalida = ['Delivery', 'Servicio', 'Compra menor'];
const _motivosEntrada = ['Cambio', 'Otro'];

/// Largo máximo del motivo (el repositorio lo valida igual).
const _motivoMaximo = 120;

/// Abre el diálogo de entrada o salida manual de efectivo. Devuelve `true` si
/// se registró el movimiento, `null`/`false` si se canceló.
///
/// [efectivoEnCaja]: lo que hay ahora en la caja; en una salida se muestra para
/// que el usuario sepa el tope antes de teclear.
Future<bool?> mostrarDialogoMovimientoCaja(
  BuildContext context, {
  required bool entrada,
  required Money efectivoEnCaja,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) =>
        MovimientoCajaDialog(entrada: entrada, efectivoEnCaja: efectivoEnCaja),
  );
}

/// Diálogo "Entrada" / "Salida" de efectivo: monto, motivo obligatorio (con
/// sugerencias en chips) y guard contra doble envío. Los errores del
/// repositorio (p. ej. una salida mayor que el efectivo) salen en un
/// [AppSnackbar] y el diálogo sigue abierto para corregir.
class MovimientoCajaDialog extends ConsumerStatefulWidget {
  const MovimientoCajaDialog({
    super.key,
    required this.entrada,
    required this.efectivoEnCaja,
  });

  final bool entrada;
  final Money efectivoEnCaja;

  @override
  ConsumerState<MovimientoCajaDialog> createState() =>
      _MovimientoCajaDialogState();
}

class _MovimientoCajaDialogState extends ConsumerState<MovimientoCajaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _motivoController = TextEditingController();
  final _motivoFocus = FocusNode();
  bool _enviando = false;

  @override
  void dispose() {
    _montoController.dispose();
    _motivoController.dispose();
    _motivoFocus.dispose();
    super.dispose();
  }

  void _elegirMotivo(String motivo) {
    setState(() {
      // "Otro" no es un motivo en sí: vacía el campo y lo enfoca para escribir.
      if (motivo == 'Otro') {
        _motivoController.clear();
        _motivoFocus.requestFocus();
      } else {
        _motivoController.text = motivo;
      }
    });
  }

  Future<void> _registrar() async {
    if (_enviando) return;
    if (!_formKey.currentState!.validate()) return;
    final usuarioId = switch (ref.read(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) {
      AppSnackbar.error(context, 'No hay una sesión activa.');
      return;
    }

    setState(() => _enviando = true);
    final resultado = await ref
        .read(cashRegisterRepositoryProvider)
        .registrarMovimientoManual(
          entrada: widget.entrada,
          monto: Money.tryParse(_montoController.text)!,
          motivo: _motivoController.text,
          usuarioId: usuarioId,
        );
    if (!mounted) return;
    setState(() => _enviando = false);
    resultado.when(
      ok: (_) => Navigator.of(context).pop(true),
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final motivos = widget.entrada ? _motivosEntrada : _motivosSalida;

    return AlertDialog(
      title: Text(
        widget.entrada ? 'Entrada de efectivo' : 'Salida de efectivo',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.entrada) ...[
                Text(
                  'Hay ${widget.efectivoEnCaja.format()} en la caja.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              TextFormField(
                controller: _montoController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: 'RD\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (v) {
                  final monto = Money.tryParse(v ?? '');
                  if (monto == null || monto.cents <= 0) {
                    return 'El monto debe ser mayor que cero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _motivoController,
                focusNode: _motivoFocus,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                maxLength: _motivoMaximo,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Indica el motivo.';
                  return null;
                },
                onFieldSubmitted: (_) => _registrar(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final motivo in motivos)
                    ActionChip(
                      label: Text(motivo),
                      onPressed: _enviando ? null : () => _elegirMotivo(motivo),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviando ? null : _registrar,
          child: _enviando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.entrada ? 'Registrar entrada' : 'Registrar salida'),
        ),
      ],
    );
  }
}
