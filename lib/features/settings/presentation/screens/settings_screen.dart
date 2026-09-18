import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/settings_providers.dart';

/// Ajustes del negocio (solo Administrador). Por ahora: vender sin stock
/// (RN-12). Cada cambio se guarda al instante.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _guardar(BuildContext context, WidgetRef ref, bool valor) async {
    final usuarioId = switch (ref.read(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    try {
      if (usuarioId == null) throw StateError('Sin sesión activa.');
      await ref
          .read(settingsLocalDatasourceProvider)
          .establecerPermitirStockNegativo(valor, usuarioId: usuarioId);
      if (context.mounted) AppSnackbar.exito(context, 'Ajuste guardado');
    } catch (_) {
      // El interruptor muestra el valor guardado (el stream no cambió), así
      // que vuelve solo a su valor anterior.
      if (context.mounted) {
        AppSnackbar.error(context, 'No se pudo guardar el ajuste.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permitir = ref.watch(permitirStockNegativoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes del negocio')),
      body: permitir.when(
        loading: () => const LoadingView(),
        error: (error, stackTrace) => ErrorState(
          mensaje: 'No se pudieron cargar los ajustes.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: () => ref.invalidate(permitirStockNegativoProvider),
        ),
        data: (valor) => ListView(
          children: [
            SwitchListTile(
              title: const Text('Permitir vender sin stock'),
              subtitle: const Text(
                'Si está desactivado, no se podrán vender productos sin '
                'existencias suficientes.',
              ),
              value: valor,
              onChanged: (nuevo) => _guardar(context, ref, nuevo),
            ),
          ],
        ),
      ),
    );
  }
}
