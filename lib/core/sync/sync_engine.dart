import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../database/app_database.dart';

/// Espera mínima antes de reintentar una fila que ya falló [intentos] veces:
/// 30 s, 60 s, 120 s... duplicándose por intento, con tope de 6 h. Con 0
/// intentos no hay espera. Función pura (sin reloj).
Duration esperaReintento(int intentos) {
  const base = Duration(seconds: 30);
  const tope = Duration(hours: 6);
  if (intentos <= 0) return Duration.zero;
  // 30 s * 2^9 ya supera 6 h: se evita calcular potencias enormes.
  if (intentos > 10) return tope;
  final espera = base * (1 << (intentos - 1));
  return espera > tope ? tope : espera;
}

/// ¿Toca intentar una fila? Las nuevas (0 intentos) siempre; las que ya
/// fallaron solo cuando [ahora] alcanza `ultimoIntento + esperaReintento`.
/// [ultimoIntento] es el `updatedAt` de la fila (se actualiza al fallar).
bool tocaReintentar({
  required int intentos,
  required DateTime ultimoIntento,
  required DateTime ahora,
}) {
  if (intentos <= 0) return true;
  return !ahora.isBefore(ultimoIntento.add(esperaReintento(intentos)));
}

/// Destino remoto del sync (lo mínimo que usa el motor de Supabase), para
/// poder sustituirlo en tests sin falsear la API fluida de supabase_flutter.
abstract interface class SyncRemote {
  /// Id del usuario autenticado, o `null` sin sesión.
  String? get userId;

  Future<void> upsert(String tabla, Map<String, dynamic> fila);

  Future<void> delete(String tabla, String id);
}

/// [SyncRemote] real, sobre el cliente de Supabase.
class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this._client);

  final sb.SupabaseClient _client;

  @override
  String? get userId => _client.auth.currentUser?.id;

  @override
  Future<void> upsert(String tabla, Map<String, dynamic> fila) async {
    await _client.from(tabla).upsert(fila);
  }

  @override
  Future<void> delete(String tabla, String id) async {
    await _client.from(tabla).delete().eq('id', id);
  }
}

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
  final SyncRemote _remote;
  final DateTime Function() _ahora;
  Duration backupInterval;

  /// [client] es el cliente de Supabase real; [remote] permite sustituir el
  /// destino (tests) y [ahora] el reloj (por defecto `DateTime.now`).
  SyncEngine({
    required this.db,
    sb.SupabaseClient? client,
    SyncRemote? remote,
    DateTime Function()? ahora,
    this.backupInterval = const Duration(hours: 3),
  }) : assert(client != null || remote != null),
       _remote = remote ?? SupabaseSyncRemote(client!),
       _ahora = ahora ?? DateTime.now;

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
    final userId = _remote.userId;
    if (userId == null) return;

    _syncing = true;
    try {
      final filas = await (db.select(
        db.syncQueue,
      )..where((q) => q.estado.equalsValue(EstadoSync.pendiente))).get();

      // Espera exponencial por fila: una que ya falló no se reintenta hasta
      // que pase su espera (evita martillar al servidor con filas que
      // fallarán siempre, p.ej. una tabla remota aún no creada). Nunca se
      // descarta una fila: solo se espacian los reintentos.
      final ahora = _ahora();
      final pending = filas.where(
        (f) => tocaReintentar(
          intentos: f.intentos,
          ultimoIntento: f.updatedAt,
          ahora: ahora,
        ),
      );

      for (final item in pending) {
        try {
          final targetTable = 'mi_negocio_${item.tabla}';
          if (item.operacion == OperacionSync.delete) {
            await _remote.delete(targetTable, item.registroId);
          } else {
            final payload = jsonDecode(item.payload) as Map<String, dynamic>;
            await _remote.upsert(targetTable, {
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
          // mitad de camino) no debe frenar a las demas -- se reintenta mas
          // adelante, con espera creciente (ver tocaReintentar).
          developer.log(
            'Sync fallo para ${item.tabla}/${item.registroId}',
            error: e,
            stackTrace: st,
            name: 'SyncEngine',
          );
          await (db.update(
            db.syncQueue,
          )..where((q) => q.id.equals(item.id))).write(
            SyncQueueCompanion(
              intentos: Value(item.intentos + 1),
              // Marca el último intento: de aquí corre la espera.
              updatedAt: Value(ahora.toUtc()),
            ),
          );
        }
      }
    } finally {
      _syncing = false;
    }
  }
}
