import 'package:drift/drift.dart';

import '../enums.dart';
import 'base.dart';
import 'negocio_tables.dart';

/// Auditoría (RF-AUD). Append-only: la app nunca actualiza ni borra filas
/// (RN-14); se garantiza en los repositorios, no hay API de edición.
@TableIndex(name: 'idx_auditoria_fecha', columns: {#fecha})
@TableIndex(name: 'idx_auditoria_modulo', columns: {#modulo})
class Auditoria extends BaseTable {
  TextColumn get usuarioId => text().references(Usuarios, #id)();

  /// Acción corta, ej. 'crear', 'editar', 'anular', 'cerrar_caja'.
  TextColumn get accion => text()();

  /// Módulo origen, ej. 'productos', 'ventas', 'caja'.
  TextColumn get modulo => text()();
  TextColumn get entidadId => text().nullable()();

  /// Snapshots JSON del registro afectado (RF-AUD-01).
  TextColumn get datosAntes => text().nullable()();
  TextColumn get datosDespues => text().nullable()();
  DateTimeColumn get fecha =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}

/// Historial de respaldos realizados (RF-RES-03).
class Respaldos extends BaseTable {
  DateTimeColumn get fecha => dateTime()();
  TextColumn get archivo => text()();
  IntColumn get tamanoBytes => integer()();
  TextColumn get tipo => textEnum<TipoRespaldo>()();

  /// 'ok' o mensaje de error.
  TextColumn get resultado => text()();
}

/// Cola de sincronización (RF-SYN-03). Vacía hasta la Fase 19; existe desde
/// la v1 para no migrar el schema cuando se active el plan Nube.
@TableIndex(name: 'idx_sync_estado', columns: {#estado})
class SyncQueue extends BaseTable {
  /// Nombre de la tabla local afectada.
  TextColumn get tabla => text()();
  TextColumn get registroId => text()();
  TextColumn get operacion => textEnum<OperacionSync>()();

  /// Snapshot JSON del registro al momento del cambio.
  TextColumn get payload => text()();
  TextColumn get estado => textEnum<EstadoSync>()();
  IntColumn get intentos => integer().withDefault(const Constant(0))();
}
