import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/cliente.dart';
import '../providers/customers_providers.dart';

/// Alta/edición de un cliente. El límite de crédito solo lo ve y cambia el
/// Administrador: un cajero crea clientes sin límite y, al editar, se conserva
/// el que ya tenían.
class ClienteFormScreen extends ConsumerStatefulWidget {
  const ClienteFormScreen({super.key, this.clienteId});

  final String? clienteId;

  @override
  ConsumerState<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends ConsumerState<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _notaController = TextEditingController();
  final _limiteController = TextEditingController();
  bool _guardando = false;
  bool _inicializado = false;

  bool get _esEdicion => widget.clienteId != null;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _notaController.dispose();
    _limiteController.dispose();
    super.dispose();
  }

  void _cargar(Cliente c) {
    if (_inicializado) return;
    _inicializado = true;
    _nombreController.text = c.nombre;
    _telefonoController.text = c.telefono ?? '';
    _notaController.text = c.nota ?? '';
    if (c.limiteCredito != null) {
      _limiteController.text = c.limiteCredito!.format(symbol: false);
    }
  }

  Future<void> _guardar(Cliente? existente, bool esAdmin) async {
    if (_guardando) return;
    if (!_formKey.currentState!.validate()) return;
    final usuarioId = switch (ref.read(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) {
      AppSnackbar.error(context, 'No hay una sesión activa.');
      return;
    }

    // Solo el administrador cambia el límite; el cajero conserva el actual.
    final limite = esAdmin
        ? Money.tryParse(_limiteController.text)
        : existente?.limiteCredito;

    setState(() => _guardando = true);
    final repo = ref.read(customersRepositoryProvider);
    final resultado = _esEdicion
        ? await repo.actualizarCliente(
            id: widget.clienteId!,
            nombre: _nombreController.text,
            telefono: _telefonoController.text,
            nota: _notaController.text,
            limiteCredito: limite,
            usuarioId: usuarioId,
          )
        : await repo.crearCliente(
            nombre: _nombreController.text,
            telefono: _telefonoController.text,
            nota: _notaController.text,
            limiteCredito: limite,
            usuarioId: usuarioId,
          );
    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) {
        AppSnackbar.exito(context, 'Cliente guardado');
        context.pop();
      },
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };
    Cliente? existente;
    if (_esEdicion) {
      final clientes = ref.watch(clientesProvider);
      if (clientes.isLoading) {
        return Scaffold(appBar: AppBar(), body: const LoadingView());
      }
      for (final c in clientes.value ?? const <Cliente>[]) {
        if (c.id == widget.clienteId) existente = c;
      }
      if (existente == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const EmptyState(
            icono: Icons.person_off_outlined,
            titulo: 'Cliente no encontrado',
          ),
        );
      }
      _cargar(existente);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar cliente' : 'Nuevo cliente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _nombreController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El nombre es obligatorio.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notaController,
              textInputAction: esAdmin
                  ? TextInputAction.next
                  : TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Nota (opcional)'),
              onFieldSubmitted: esAdmin
                  ? null
                  : (_) => _guardar(existente, esAdmin),
            ),
            if (esAdmin) ...[
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _limiteController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Límite de crédito (opcional)',
                  prefixText: 'RD\$ ',
                  helperText: 'Vacío = sin límite',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final m = Money.tryParse(v);
                  if (m == null) return 'Monto inválido';
                  if (m.isNegative) {
                    return 'El límite de crédito no puede ser negativo.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _guardar(existente, esAdmin),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _guardando ? null : () => _guardar(existente, esAdmin),
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
