import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/licencia.dart';
import '../providers/license_providers.dart';

/// Pantalla bloqueante (RF-LIC-05/RN-15): licencia suspendida, vencida o
/// fuera del período de gracia. No permite acceso a ningún módulo.
class BlockedScreen extends ConsumerStatefulWidget {
  const BlockedScreen({super.key});

  @override
  ConsumerState<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends ConsumerState<BlockedScreen> {
  bool _revalidando = false;

  Future<void> _reintentar() async {
    if (_revalidando) return;
    setState(() => _revalidando = true);
    try {
      await ref.read(licenseControllerProvider.notifier).revalidar();
      if (!mounted) return;
      // Si la licencia volvió a estar activa el router ya nos sacó de aquí.
      if (ref.read(licenseControllerProvider).value is! LicenciaActiva) {
        AppSnackbar.info(
          context,
          'La licencia sigue sin estar activa. Si ya la renovaste, revisa tu '
          'conexión e inténtalo de nuevo.',
        );
      }
    } on Object catch (e, st) {
      developer.log(
        'Falló la revalidación de la licencia',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      // La revalidación deja el estado en "cargando" si falla: se reinicia.
      ref.invalidate(licenseControllerProvider);
      if (mounted) {
        AppSnackbar.error(
          context,
          'No se pudo validar la licencia. Revisa tu conexión e inténtalo de '
          'nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _revalidando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final estado = ref.watch(licenseControllerProvider);
    final motivo = switch (estado.value) {
      LicenciaBloqueada(:final motivo) => motivo,
      _ => 'La licencia no está activa.',
    };
    final validando = _revalidando || estado.isLoading;

    if (estado.hasError && !validando) {
      return Scaffold(
        body: ErrorState(
          mensaje: 'No se pudo validar la licencia.',
          error: estado.error,
          stackTrace: estado.stackTrace,
          onReintentar: () => ref.invalidate(licenseControllerProvider),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                    onPressed: validando ? null : _reintentar,
                    icon: validando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      validando ? 'Validando...' : 'Reintentar validación',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: validando
                        ? null
                        : () => context.go(AppRoutes.licenseActivation),
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
