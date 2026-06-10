import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase solo si la build trae credenciales (--dart-define). Sin ellas
  // la app opera 100% local (Demo y plan Local dentro del período de gracia).
  if (SupabaseConfig.configurado) {
    // Acepta tanto la clave nueva (sb_publishable_...) como la anon JWT
    // heredada: ambas viajan en el mismo header `apikey`.
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const ProviderScope(child: AppGestion()));
}
