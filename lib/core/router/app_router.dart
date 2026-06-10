import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/license/domain/entities/licencia.dart';
import '../../features/license/presentation/providers/license_providers.dart';
import '../../features/license/presentation/screens/activation_screen.dart';
import '../../features/license/presentation/screens/blocked_screen.dart';

/// Rutas nombradas de la aplicación.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String licenseActivation = '/licencia/activar';
  static const String licenseBlocked = '/licencia/bloqueada';
  static const String login = '/login';
}

/// Router central con cadena de guards: licencia → auth → rol.
///
/// Orden obligatorio del redirect (RN-15):
///   1. Licencia (F3): sin licencia → activación; suspendida/vencida → bloqueo.
///   2. Sin sesión → /login (F5, pendiente).
///   3. Ruta de admin con rol cajero → / (F5, pendiente).
final appRouterProvider = Provider<GoRouter>((ref) {
  // Reevalúa el redirect cuando cambia el estado de la licencia.
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(licenseControllerProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final licencia = ref.read(licenseControllerProvider);
      final destino = state.matchedLocation;

      // Guard 1 — licencia
      if (licencia.isLoading) {
        return destino == AppRoutes.splash ? null : AppRoutes.splash;
      }
      switch (licencia.value) {
        case SinLicencia() || null:
          return destino == AppRoutes.licenseActivation
              ? null
              : AppRoutes.licenseActivation;
        case LicenciaBloqueada():
          // Desde el bloqueo se permite ir a activar otra licencia.
          return (destino == AppRoutes.licenseBlocked ||
                  destino == AppRoutes.licenseActivation)
              ? null
              : AppRoutes.licenseBlocked;
        case LicenciaActiva():
          // F5: aquí se encadena el guard de auth.
          final enPantallaDeLicencia =
              destino == AppRoutes.splash || destino.startsWith('/licencia');
          return enPantallaDeLicencia ? AppRoutes.home : null;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.licenseActivation,
        builder: (context, state) => const ActivationScreen(),
      ),
      GoRoute(
        path: AppRoutes.licenseBlocked,
        builder: (context, state) => const BlockedScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _PlaceholderHomeScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Home temporal: se reemplaza por login (F5) y dashboard (F6).
class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 72, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Licencia activa',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Fase 3 completa — el registro del negocio llega en la Fase 5',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
