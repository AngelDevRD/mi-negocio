import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../sales/presentation/metodo_pago_texto.dart';
import '../../domain/entities/cliente.dart';
import '../providers/customers_providers.dart';

/// Métodos con los que se puede abonar (el fiado no: un abono nunca es crédito).
const _metodosDeAbono = [
  MetodoPago.efectivo,
  MetodoPago.tarjeta,
  MetodoPago.transferencia,
];

/// Diálogo "Registrar abono". Devuelve el saldo restante si el abono se
/// registró, o `null` si se canceló. Los errores del repositorio (caja
/// cerrada, abono mayor que el saldo...) se muestran sin cerrar el diálogo.
class AbonoDialog extends ConsumerStatefulWidget {
  const AbonoDialog({super.key, required this.cliente});

  final Cliente cliente;

  @override
  ConsumerState<AbonoDialog> createState() => _AbonoDialogState();
}

class _AbonoDialogState extends ConsumerState<AbonoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _montoController = TextEditingController(
    text: widget.cliente.saldo.format(symbol: false),
  );
  final _notaController = TextEditingController();
  MetodoPago _metodo = MetodoPago.efectivo;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _seleccionarTodo();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  void _seleccionarTodo() {
    _montoController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _montoController.text.length,
    );
  }

  Future<void> _registrar() async {
    if (_enviando) return;
    if (!_formKey.currentState!.validate()) return;
    final monto = Money.tryParse(_montoController.text)!;
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
        .read(customersRepositoryProvider)
        .registrarAbono(
          clienteId: widget.cliente.id,
          monto: monto,
          metodo: _metodo,
          usuarioId: usuarioId,
          nota: _notaController.text,
        );
    if (!mounted) return;
    setState(() => _enviando = false);
    resultado.when(
      ok: (_) => Navigator.of(
        context,
      ).pop(Money(widget.cliente.saldo.cents - monto.cents)),
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Registrar abono'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Saldo de ${widget.cliente.nombre}',
                      style: textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  MoneyText(
                    widget.cliente.saldo,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _montoController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Monto del abono',
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
                    return 'El monto del abono debe ser mayor que cero.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _registrar(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  label: const Text('Todo el saldo'),
                  onPressed: () => setState(() {
                    _montoController.text = widget.cliente.saldo.format(
                      symbol: false,
                    );
                    _seleccionarTodo();
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SegmentedButton<MetodoPago>(
                  showSelectedIcon: false,
                  segments: [
                    for (final metodo in _metodosDeAbono)
                      ButtonSegment(
                        value: metodo,
                        label: Text(metodo.etiqueta),
                      ),
                  ],
                  selected: {_metodo},
                  onSelectionChanged: (s) => setState(() => _metodo = s.single),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _notaController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Nota (opcional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
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
              : const Text('Registrar abono'),
        ),
      ],
    );
  }
}
