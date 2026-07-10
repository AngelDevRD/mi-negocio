import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cash_register/presentation/providers/cash_register_providers.dart';
import '../providers/employees_providers.dart';

/// Registro de un pago a un empleado (RF-EMP-03): fecha, monto (precargado
/// con el salario), período cubierto y, opcionalmente, salida de caja.
class PaymentFormScreen extends ConsumerStatefulWidget {
  const PaymentFormScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _periodoController = TextEditingController();

  DateTime _fecha = DateTime.now();
  bool _saleDeCaja = false;
  bool _guardando = false;
  bool _inicializado = false;
  String? _error;

  @override
  void dispose() {
    _montoController.dispose();
    _periodoController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(ahora.year - 1),
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

    setState(() {
      _guardando = true;
      _error = null;
    });

    final periodo = _periodoController.text.trim();
    final resultado = await ref
        .read(employeesRepositoryProvider)
        .registrarPago(
          empleadoId: widget.employeeId,
          fecha: _fecha.toUtc(),
          monto: Money.parse(_montoController.text),
          periodo: periodo.isEmpty ? null : periodo,
          saleDeCaja: _saleDeCaja,
          usuarioId: usuarioId,
        );

    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) {
        ref.invalidate(pagosEmpleadoProvider(widget.employeeId));
        ref.invalidate(totalPagadoProvider(widget.employeeId));
        context.pop();
      },
      fail: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empleadoAsync = ref.watch(empleadoProvider(widget.employeeId));
    final sesionAsync = ref.watch(sesionActualProvider);
    final hayCajaAbierta = sesionAsync.value != null;
    final formatoFecha = DateFormat('dd/MM/yyyy');

    if (!_inicializado) {
      empleadoAsync.whenData((empleado) {
        if (empleado?.salario != null) {
          _montoController.text = empleado!.salario!.format(symbol: false);
          _inicializado = true;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pago')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha'),
              subtitle: Text(formatoFecha.format(_fecha)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _elegirFecha,
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
            TextFormField(
              controller: _periodoController,
              decoration: const InputDecoration(
                labelText: 'Período cubierto (opcional)',
                hintText: 'ej. 1-15 junio 2026',
              ),
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
