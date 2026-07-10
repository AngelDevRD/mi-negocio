import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cash_register/presentation/providers/cash_register_providers.dart';
import '../../domain/entities/gasto.dart';
import '../providers/expenses_providers.dart';

const String _otraCategoria = 'Otra';

/// Formulario de nuevo gasto (RF-GAS-01): categoría (predefinida o
/// personalizada), concepto, fecha y monto. Si hay una caja abierta, permite
/// marcar "sale de caja" (RF-GAS-02).
class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conceptoController = TextEditingController();
  final _montoController = TextEditingController();
  final _categoriaPersonalizadaController = TextEditingController();

  String _categoria = categoriasGastoPredefinidas.first;
  DateTime _fecha = DateTime.now();
  bool _saleDeCaja = false;
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    _categoriaPersonalizadaController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(ahora.year - 5),
      lastDate: ahora,
    );
    if (fecha == null) return;
    setState(() => _fecha = fecha);
  }

  Future<void> _guardar() async {
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

    final categoria = _categoria == _otraCategoria
        ? _categoriaPersonalizadaController.text.trim()
        : _categoria;

    setState(() {
      _guardando = true;
      _error = null;
    });

    final resultado = await ref
        .read(expensesRepositoryProvider)
        .registrarGasto(
          categoria: categoria,
          concepto: _conceptoController.text.trim(),
          fecha: _fecha.toUtc(),
          monto: Money.parse(_montoController.text),
          saleDeCaja: _saleDeCaja,
          usuarioId: usuarioId,
        );
    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) => Navigator.of(context).pop(),
      fail: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesionAsync = ref.watch(sesionActualProvider);
    final hayCajaAbierta = sesionAsync.value != null;
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo gasto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: [
                for (final categoria in categoriasGastoPredefinidas)
                  DropdownMenuItem(value: categoria, child: Text(categoria)),
                const DropdownMenuItem(
                  value: _otraCategoria,
                  child: Text('Otra (especificar)'),
                ),
              ],
              onChanged: (valor) =>
                  setState(() => _categoria = valor ?? _categoria),
            ),
            if (_categoria == _otraCategoria) ...[
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _categoriaPersonalizadaController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la categoría',
                ),
                validator: (v) {
                  if (_categoria != _otraCategoria) return null;
                  if (v == null || v.trim().isEmpty) return 'Obligatorio';
                  return null;
                },
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _conceptoController,
              decoration: const InputDecoration(labelText: 'Concepto'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obligatorio';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _montoController,
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
                if (v == null || v.trim().isEmpty) return 'Obligatorio';
                if (Money.parse(v).cents <= 0) {
                  return 'El monto debe ser mayor que cero';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha'),
              subtitle: Text(formatoFecha.format(_fecha)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _elegirFecha,
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sale de caja'),
              subtitle: Text(
                hayCajaAbierta
                    ? 'Registra una salida en la caja abierta.'
                    : 'No hay una caja abierta.',
              ),
              value: _saleDeCaja && hayCajaAbierta,
              onChanged: hayCajaAbierta
                  ? (valor) => setState(() => _saleDeCaja = valor)
                  : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
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
