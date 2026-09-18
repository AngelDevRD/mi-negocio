import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../customers/domain/entities/cliente.dart';
import '../../../customers/presentation/providers/customers_providers.dart';
import '../../../customers/presentation/widgets/saldo_widgets.dart';

/// Búsqueda de clientes ACTIVOS (con su saldo) para fiar una venta, con la
/// opción "Nuevo cliente" rápido. Devuelve el cliente elegido (o el recién
/// creado), o `null` si se cancela.
class SelectorClienteDialog extends ConsumerStatefulWidget {
  const SelectorClienteDialog({super.key});

  @override
  ConsumerState<SelectorClienteDialog> createState() =>
      _SelectorClienteDialogState();
}

class _SelectorClienteDialogState extends ConsumerState<SelectorClienteDialog> {
  String _texto = '';

  Future<void> _nuevo() async {
    final creado = await showDialog<Cliente>(
      context: context,
      builder: (_) => const _NuevoClienteRapidoDialog(),
    );
    if (creado != null && mounted) Navigator.of(context).pop(creado);
  }

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesBusquedaProvider(_texto.trim()));

    return AlertDialog(
      title: const Text('Elegir cliente'),
      content: SizedBox(
        width: double.maxFinite,
        height: 360,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre o teléfono',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _texto = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_outlined),
              title: const Text('Nuevo cliente'),
              onTap: _nuevo,
            ),
            const Divider(height: 1),
            Expanded(
              child: clientes.when(
                loading: () => const LoadingView(),
                error: (error, stackTrace) => ErrorState(
                  compacto: true,
                  mensaje: 'No se pudieron cargar los clientes.',
                  error: error,
                  stackTrace: stackTrace,
                  onReintentar: () =>
                      ref.invalidate(clientesBusquedaProvider(_texto.trim())),
                ),
                data: (todos) {
                  final activos = todos.where((c) => c.activo).toList();
                  if (activos.isEmpty) {
                    return EmptyState(
                      compacto: true,
                      icono: Icons.search_off_outlined,
                      titulo: _texto.trim().isEmpty
                          ? 'Aún no tienes clientes'
                          : 'Sin resultados',
                    );
                  }
                  return ListView.builder(
                    itemCount: activos.length,
                    itemBuilder: (context, i) {
                      final c = activos[i];
                      return ListTile(
                        title: Text(c.nombre),
                        subtitle: c.telefono == null ? null : Text(c.telefono!),
                        trailing: EtiquetaSaldo(saldo: c.saldo),
                        onTap: () => Navigator.of(context).pop(c),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

/// Alta rápida de un cliente (solo nombre y teléfono, sin límite de crédito).
class _NuevoClienteRapidoDialog extends ConsumerStatefulWidget {
  const _NuevoClienteRapidoDialog();

  @override
  ConsumerState<_NuevoClienteRapidoDialog> createState() =>
      _NuevoClienteRapidoDialogState();
}

class _NuevoClienteRapidoDialogState
    extends ConsumerState<_NuevoClienteRapidoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
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
    setState(() => _guardando = true);
    final repo = ref.read(customersRepositoryProvider);
    final r = await repo.crearCliente(
      nombre: _nombreController.text,
      telefono: _telefonoController.text,
      usuarioId: usuarioId,
    );
    final id = r.valueOrNull;
    final cliente = id == null ? null : await repo.obtenerCliente(id);
    if (!mounted) return;
    setState(() => _guardando = false);
    if (cliente == null) {
      r.when(ok: (_) {}, fail: (f) => AppSnackbar.error(context, f.message));
      return;
    }
    Navigator.of(context).pop(cliente);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo cliente'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
              ),
              onFieldSubmitted: (_) => _crear(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _crear,
          child: const Text('Crear y elegir'),
        ),
      ],
    );
  }
}
