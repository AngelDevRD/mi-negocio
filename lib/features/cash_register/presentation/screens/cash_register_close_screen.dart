import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/cash_register_providers.dart';

/// Cierre de caja (RF-CAJ/RN-08): el usuario cuenta el efectivo, el sistema
/// muestra el monto esperado y la diferencia, y define cuánto dinero queda
/// para la apertura del día siguiente (RN-09).
class CashRegisterCloseScreen extends ConsumerStatefulWidget {
  const CashRegisterCloseScreen({super.key});

  @override
  ConsumerState<CashRegisterCloseScreen> createState() =>
      _CashRegisterCloseScreenState();
}

class _CashRegisterCloseScreenState
    extends ConsumerState<CashRegisterCloseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoContadoController = TextEditingController();
  final _montoDejarController = TextEditingController();
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _montoContadoController.dispose();
    _montoDejarController.dispose();
    super.dispose();
  }

  Future<void> _cerrar(Money montoEsperado) async {
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
        .read(cashRegisterRepositoryProvider)
        .cerrarCaja(
          montoContado: Money.parse(_montoContadoController.text),
          montoDejarSiguiente: Money.parse(_montoDejarController.text),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Cerrar caja')),
      body: sesionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudo cargar el estado de caja.')),
        data: (sesion) {
          if (sesion == null) {
            return const Center(child: Text('No hay una caja abierta.'));
          }
          final montoEsperado = sesion.montoActual;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Monto esperado en caja'),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          montoEsperado.format(),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Apertura ${sesion.montoApertura.format()} + '
                          'movimientos del día',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _montoContadoController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Monto contado en caja',
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
                    if (Money.parse(v).isNegative) return 'Monto inválido';
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _montoDejarController,
                  decoration: const InputDecoration(
                    labelText: 'Monto a dejar para mañana',
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
                    final monto = Money.parse(v);
                    if (monto.isNegative) return 'Monto inválido';
                    if (_montoContadoController.text.trim().isNotEmpty &&
                        monto > Money.parse(_montoContadoController.text)) {
                      return 'No puede ser mayor que el monto contado';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.md),
                if (_montoContadoController.text.trim().isNotEmpty)
                  _ResumenCierre(
                    montoEsperado: montoEsperado,
                    montoContado: Money.parse(_montoContadoController.text),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _guardando ? null : () => _cerrar(montoEsperado),
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirmar cierre'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResumenCierre extends StatelessWidget {
  const _ResumenCierre({
    required this.montoEsperado,
    required this.montoContado,
  });

  final Money montoEsperado;
  final Money montoContado;

  @override
  Widget build(BuildContext context) {
    final diferencia = montoContado - montoEsperado;
    final scheme = Theme.of(context).colorScheme;
    final color = diferencia.isZero
        ? scheme.onSurface
        : (diferencia.isNegative ? scheme.error : scheme.tertiary);
    final etiqueta = diferencia.isZero
        ? 'Sin diferencia'
        : (diferencia.isNegative ? 'Faltante' : 'Sobrante');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta),
            Text(
              diferencia.format(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
