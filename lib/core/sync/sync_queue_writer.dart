import 'dart:convert';

import '../database/app_database.dart';

/// Encola un cambio local para subir a Supabase en la próxima pasada del
/// SyncEngine (RF-SYN-03). No hace nada por sí mismo -- solo dejar
/// constancia en `sync_queue`, que ya existe desde el schema v1.
///
/// [tabla] debe ser el nombre de tabla remoto SIN el prefijo `mi_negocio_`
/// (ej. "productos", "ventas") -- el SyncEngine arma el nombre completo.
Future<void> enqueueSync(
  AppDatabase db, {
  required String tabla,
  required String registroId,
  required OperacionSync operacion,
  Map<String, dynamic>? payload,
}) {
  return db
      .into(db.syncQueue)
      .insert(
        SyncQueueCompanion.insert(
          tabla: tabla,
          registroId: registroId,
          operacion: operacion,
          payload: payload == null ? '{}' : jsonEncode(payload),
          estado: EstadoSync.pendiente,
        ),
      );
}
