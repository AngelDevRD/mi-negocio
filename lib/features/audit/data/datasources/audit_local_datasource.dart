import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/repositories/audit_repository.dart';

/// Acceso de solo lectura a la tabla `auditoria` (RF-AUD-02).
class AuditLocalDatasource {
  AuditLocalDatasource(this._db);

  final AppDatabase _db;

  /// Registros que cumplen [filtro], unidos con `usuarios` para mostrar el
  /// nombre, más reciente primero.
  Stream<List<(AuditoriaData, String)>> watchRegistros(AuditoriaFiltro filtro) {
    final query = _db.select(_db.auditoria).join([
      innerJoin(
        _db.usuarios,
        _db.usuarios.id.equalsExp(_db.auditoria.usuarioId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.auditoria.fecha)]);

    if (filtro.modulo != null) {
      query.where(_db.auditoria.modulo.equals(filtro.modulo!));
    }
    if (filtro.accion != null) {
      query.where(_db.auditoria.accion.equals(filtro.accion!));
    }
    if (filtro.usuarioId != null) {
      query.where(_db.auditoria.usuarioId.equals(filtro.usuarioId!));
    }
    if (filtro.desde != null) {
      query.where(_db.auditoria.fecha.isBiggerOrEqualValue(filtro.desde!));
    }
    if (filtro.hasta != null) {
      query.where(_db.auditoria.fecha.isSmallerOrEqualValue(filtro.hasta!));
    }

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.auditoria),
              row.readTable(_db.usuarios).nombre,
            ),
          )
          .toList(),
    );
  }

  Future<List<String>> listarModulos() async {
    final query = _db.selectOnly(_db.auditoria, distinct: true)
      ..addColumns([_db.auditoria.modulo])
      ..orderBy([OrderingTerm.asc(_db.auditoria.modulo)]);
    final rows = await query.get();
    return rows.map((r) => r.read(_db.auditoria.modulo)!).toList();
  }

  Future<List<String>> listarAcciones() async {
    final query = _db.selectOnly(_db.auditoria, distinct: true)
      ..addColumns([_db.auditoria.accion])
      ..orderBy([OrderingTerm.asc(_db.auditoria.accion)]);
    final rows = await query.get();
    return rows.map((r) => r.read(_db.auditoria.accion)!).toList();
  }

  Future<List<UsuarioFiltro>> listarUsuarios() async {
    final filas =
        await (_db.select(_db.usuarios)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
            .get();
    return filas.map((u) => (id: u.id, nombre: u.nombre)).toList();
  }
}

/// Decodifica `datos_antes`/`datos_despues` (JSON o `null`) a un mapa.
Map<String, Object?>? decodificarDatosAuditoria(String? json) {
  if (json == null) return null;
  return jsonDecode(json) as Map<String, Object?>;
}
