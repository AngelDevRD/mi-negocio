import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_updater.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class AppGestion extends ConsumerWidget {
  const AppGestion({super.key});

  // AppGestion puede reconstruirse varias veces (router, tema, etc.), pero
  // el chequeo de actualizacion solo debe dispararse una vez por sesion.
  static bool _updateChecked = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    if (!_updateChecked) {
      _updateChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          AppUpdater.checkForUpdate(context, slug: 'mi-negocio');
        }
      });
    }

    return MaterialApp.router(
      title: 'App Gestión Negocios',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
