import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Rutas nombradas de la aplicación.
abstract final class AppRoutes {
  static const String home = '/';
  static const String licenseActivation = '/licencia/activar';
  static const String licenseBlocked = '/licencia/bloqueada';
  static const String login = '/login';
}

/// Router central con cadena de guards: licencia → auth → rol.
///
/// Orden obligatorio del redirect (RN-15):
///   1. Sin licencia válida → /licencia/activar o /licencia/bloqueada
///   2. Sin sesión → /login
///   3. Ruta de admin con rol cajero → /
///
/// Los guards reales se conectan en F3 (licencia) y F5 (auth). Hasta
/// entonces dejan pasar.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      // F3: validar licencia (licenseGuard) — pendiente.
      // F5: validar sesión y rol (authGuard) — pendiente.
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _PlaceholderScreen(),
      ),
    ],
  );
});

/// Pantalla temporal de la Fase 1. Se reemplaza por activación de licencia
/// (F3) y dashboard (F6).
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront, size: 72, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'App Gestión Negocios',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Fase 1 — Arquitectura lista',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
