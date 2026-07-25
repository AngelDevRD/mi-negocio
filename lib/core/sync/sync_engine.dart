import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../database/app_database.dart';

/// Motor de sync genérico: drena `sync_queue` (RF-SYN-03) hacia Supabase. A
/// diferencia de finanzas360/nexfit (una clase Syncable por dominio), acá
/// basta una implementación única porque cada fila de la cola ya trae el
/// nombre de tabla + el payload completo -- el motor solo agrega `user_id` y
/// elige upsert vs delete.
///
/// Se dispara al recuperar conectividad y con un timer periódico
/// configurable (ver SyncSettingsProvider). Los datos siempre viven primero
/// en Drift local -- esto solo decide cada cuánto se replican a Supabase.
class SyncEngine {
  final AppDatabase db;
  final sb.SupabaseClient client;
  Duration backupInterval;

  SyncEngine({
    required this.db,
    required this.client,
    this.backupInterval = const Duration(hours: 3),
  });

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _backupTimer;
  bool _syncing = false;

  void start() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        syncNow();
      }
    });
    _backupTimer = Timer.periodic(backupInterval, (_) => syncNow());
    syncNow();
  }

  void updateInterval(Duration newInterval) {
    if (newInterval == backupInterval) return;
    backupInterval = newInterval;
    _backupTimer?.cancel();
    _backupTimer = Timer.periodic(backupInterval, (_) => syncNow());
  }

  void dispose() {
    _connectivitySub?.cancel();
    _backupTimer?.cancel();
  }

  Future<void> syncNow() async {
    if (_syncing) return;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    _syncing = true;
    try {
      final pending = await (db.select(
        db.syncQueue,
      )..where((q) => q.estado.equalsValue(EstadoSync.pendiente))).get();

      for (final item in pending) {
        try {
          final targetTable = 'mi_negocio_${item.tabla}';
          if (item.operacion == OperacionSync.delete) {
            await client
                .from(targetTable)
                .delete()
                .eq('id', item.registroId);
          } else {
            final payload =
                jsonDecode(item.payload) as Map<String, dynamic>;
            await client.from(targetTable).upsert({
              ...payload,
              'id': item.registroId,
              'user_id': userId,
            });
          }
          await (db.delete(
            db.syncQueue,
          )..where((q) => q.id.equals(item.id))).go();
        } catch (e, st) {
          // Una fila fallando (ej. FK que aun no sincronizo, o sin red a
          // mitad de camino) no debe frenar a las demas -- reintenta en la
          // proxima pasada.
          developer.log(
            'Sync fallo para ${item.tabla}/${item.registroId}',
            error: e,
            stackTrace: st,
            name: 'SyncEngine',
          );
          await (db.update(db.syncQueue)..where((q) => q.id.equals(item.id)))
              .write(
                SyncQueueCompanion(
                  intentos: Value(item.intentos + 1),
                ),
              );
        }
      }
    } finally {
      _syncing = false;
    }
  }
}
