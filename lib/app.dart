import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_updater.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

bool _updateCheckStarted = false;

class AppGestion extends ConsumerWidget {
  const AppGestion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'App Gestión Negocios',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        if (!_updateCheckStarted) {
          _updateCheckStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              AppUpdater.checkForUpdate(context, slug: 'mi-negocio');
            }
          });
        }
        return child!;
      },
    );
  }
}
