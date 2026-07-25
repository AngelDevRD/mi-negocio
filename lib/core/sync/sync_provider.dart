import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../features/cloud_sync/data/cloud_auth_repository.dart';
import '../config/supabase_config.dart';
import '../database/app_database.dart';
import 'sync_engine.dart';
import 'sync_settings.dart';

/// Mantiene vivo el SyncEngine mientras haya sesión de nube (propietario) y
/// Supabase esté configurado. Se recrea automáticamente si cambia la sesión
/// o la frecuencia elegida en Ajustes.
final syncEngineProvider = Provider<SyncEngine?>((ref) {
  // Orden importa: cloudCurrentUserProvider toca Supabase.instance, que
  // nunca se inicializa si la build no trae credenciales.
  if (!SupabaseConfig.configurado) return null;

  final user = ref.watch(cloudCurrentUserProvider);
  if (user == null) return null;

  final frequency = ref.watch(syncFrequencyProvider);
  final db = ref.watch(appDatabaseProvider);

  final engine = SyncEngine(
    db: db,
    client: sb.Supabase.instance.client,
    backupInterval: frequency.interval,
  )..start();

  ref.onDispose(engine.dispose);
  return engine;
});
