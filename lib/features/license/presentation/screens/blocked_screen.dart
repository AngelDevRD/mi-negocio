import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/licencia.dart';
import '../providers/license_providers.dart';

/// Pantalla bloqueante (RF-LIC-05/RN-15): licencia suspendida, vencida o
/// fuera del período de gracia. No permite acceso a ningún módulo.
class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final estado = ref.watch(licenseControllerProvider);
    final motivo = switch (estado.value) {
      LicenciaBloqueada(:final motivo) => motivo,
      _ => 'La licencia no está activa.',
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: scheme.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Acceso bloqueado',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    motivo,
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tus datos están guardados y volverán a estar '
                    'disponibles al reactivar la licencia.',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: estado.isLoading
                        ? null
                        : () => ref
                              .read(licenseControllerProvider.notifier)
                              .revalidar(),
                    icon: estado.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('Reintentar validación'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.licenseActivation),
                    child: const Text('Activar otra licencia'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
