import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

/// Acceso a `caja_sesiones`/`caja_movimientos` (RF-CAJ): sesión actual,
/// historial y cierre de caja.
class CashRegisterLocalDatasource {
  CashRegisterLocalDatasource(this._db);

  final AppDatabase _db;

  /// Sesión de caja abierta (si hay), con el nombre del usuario que la abrió.
  Stream<(CajaSesione, String)?> watchSesionAbierta() {
    final query = _db.select(_db.cajaSesiones).join([
      innerJoin(
        _db.usuarios,
        _db.usuarios.id.equalsExp(_db.cajaSesiones.usuarioApertura),
      ),
    ])..where(_db.cajaSesiones.estado.equalsValue(EstadoCajaSesion.abierta));
    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      return (
        row.readTable(_db.cajaSesiones),
        row.readTable(_db.usuarios).nombre,
      );
    });
  }

  /// Movimientos de una sesión, más reciente primero.
  Stream<List<CajaMovimiento>> watchMovimientos(String sesionId) {
    final query = _db.select(_db.cajaMovimientos)
      ..where((t) => t.cajaSesionId.equals(sesionId))
      ..orderBy([(t) => OrderingTerm.desc(t.fecha)]);
    return query.watch();
  }

  Future<List<CajaMovimiento>> obtenerMovimientos(String sesionId) {
    final query = _db.select(_db.cajaMovimientos)
      ..where((t) => t.cajaSesionId.equals(sesionId))
      ..orderBy([(t) => OrderingTerm.desc(t.fecha)]);
    return query.get();
  }

  /// Sesiones cerradas, con el nombre de quien abrió y quien cerró.
  Stream<List<(CajaSesione, String, String?)>> watchHistorial() {
    final aperturaUsuarios = _db.alias(_db.usuarios, 'apertura_usuarios');
    final cierreUsuarios = _db.alias(_db.usuarios, 'cierre_usuarios');
    final query =
        _db.select(_db.cajaSesiones).join([
            innerJoin(
              aperturaUsuarios,
              aperturaUsuarios.id.equalsExp(_db.cajaSesiones.usuarioApertura),
            ),
            leftOuterJoin(
              cierreUsuarios,
              cierreUsuarios.id.equalsExp(_db.cajaSesiones.usuarioCierre),
            ),
          ])
          ..where(_db.cajaSesiones.estado.equalsValue(EstadoCajaSesion.cerrada))
          ..orderBy([OrderingTerm.desc(_db.cajaSesiones.fechaCierre)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.cajaSesiones),
              row.readTable(aperturaUsuarios).nombre,
              row.readTableOrNull(cierreUsuarios)?.nombre,
            ),
          )
          .toList(),
    );
  }

  /// Sesión por id, con el nombre de quien abrió y quien cerró.
  Future<(CajaSesione, String, String?)?> obtenerSesion(String id) async {
    final aperturaUsuarios = _db.alias(_db.usuarios, 'apertura_usuarios');
    final cierreUsuarios = _db.alias(_db.usuarios, 'cierre_usuarios');
    final query = _db.select(_db.cajaSesiones).join([
      innerJoin(
        aperturaUsuarios,
        aperturaUsuarios.id.equalsExp(_db.cajaSesiones.usuarioApertura),
      ),
      leftOuterJoin(
        cierreUsuarios,
        cierreUsuarios.id.equalsExp(_db.cajaSesiones.usuarioCierre),
      ),
    ])..where(_db.cajaSesiones.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return (
      row.readTable(_db.cajaSesiones),
      row.readTable(aperturaUsuarios).nombre,
      row.readTableOrNull(cierreUsuarios)?.nombre,
    );
  }

  /// Última sesión cerrada, para precargar la próxima apertura (RN-09).
  Future<CajaSesione?> obtenerUltimaSesionCerrada() {
    final query = _db.select(_db.cajaSesiones)
      ..where((t) => t.estado.equalsValue(EstadoCajaSesion.cerrada))
      ..orderBy([(t) => OrderingTerm.desc(t.fechaCierre)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Cierra la sesión abierta (RF-CAJ/RN-08): calcula el monto esperado,
  /// registra el monto contado, la diferencia, el monto a dejar para el día
  /// siguiente, el retiro del excedente y la auditoría.
  Future<void> cerrarCaja({
    required String sesionId,
    required int montoEsperadoCents,
    required int montoContadoCents,
    required int montoDejarSiguienteCents,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final sesion = await (_db.select(
        _db.cajaSesiones,
      )..where((t) => t.id.equals(sesionId))).getSingle();

      final diferencia = montoContadoCents - montoEsperadoCents;
      final retiro = montoContadoCents - montoDejarSiguienteCents;

      await (_db.update(
        _db.cajaSesiones,
      )..where((t) => t.id.equals(sesionId))).write(
        CajaSesionesCompanion(
          fechaCierre: Value(DateTime.now().toUtc()),
          montoEsperado: Value(montoEsperadoCents),
          montoContado: Value(montoContadoCents),
          diferencia: Value(diferencia),
          montoDejadoSiguiente: Value(montoDejarSiguienteCents),
          usuarioCierre: Value(usuarioId),
          estado: const Value(EstadoCajaSesion.cerrada),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      if (retiro != 0) {
        await _db
            .into(_db.cajaMovimientos)
            .insert(
              CajaMovimientosCompanion.insert(
                cajaSesionId: sesionId,
                tipo: TipoCajaMovimiento.retiroCierre,
                monto: -retiro,
                referenciaId: Value(sesionId),
                usuarioId: usuarioId,
              ),
            );
      }

      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: usuarioId,
              accion: 'cerrar',
              modulo: 'caja',
              entidadId: Value(sesionId),
              datosAntes: Value(jsonEncode({'estado': sesion.estado.name})),
              datosDespues: Value(
                jsonEncode({
                  'estado': EstadoCajaSesion.cerrada.name,
                  'montoEsperado': montoEsperadoCents,
                  'montoContado': montoContadoCents,
                  'diferencia': diferencia,
                  'montoDejadoSiguiente': montoDejarSiguienteCents,
                }),
              ),
            ),
          );
    });
  }
}
