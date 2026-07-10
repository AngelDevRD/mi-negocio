import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';

/// Acceso a `gastos` (RF-GAS): listado con filtros y registro.
class ExpensesLocalDatasource {
  ExpensesLocalDatasource(this._db);

  final AppDatabase _db;

  /// Gastos no eliminados con el nombre del usuario, más reciente primero.
  Stream<List<(Gasto, String)>> watchGastos({
    DateTime? desde,
    DateTime? hasta,
    String? categoria,
  }) {
    final query = _db.select(_db.gastos).join([
      innerJoin(_db.usuarios, _db.usuarios.id.equalsExp(_db.gastos.usuarioId)),
    ])..where(_db.gastos.deletedAt.isNull());

    if (desde != null) {
      query.where(_db.gastos.fecha.isBiggerOrEqualValue(desde));
    }
    if (hasta != null) {
      query.where(_db.gastos.fecha.isSmallerOrEqualValue(hasta));
    }
    if (categoria != null) {
      query.where(_db.gastos.categoria.equals(categoria));
    }
    query.orderBy([OrderingTerm.desc(_db.gastos.fecha)]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) =>
                (row.readTable(_db.gastos), row.readTable(_db.usuarios).nombre),
          )
          .toList(),
    );
  }

  /// Id de la sesión de caja abierta, si hay una (RF-CAJ).
  Future<String?> obtenerCajaAbiertaId() async {
    final query = _db.select(_db.cajaSesiones)
      ..where((t) => t.estado.equalsValue(EstadoCajaSesion.abierta));
    final sesion = await query.getSingleOrNull();
    return sesion?.id;
  }

  /// Registra el gasto y, si [cajaSesionId] no es nulo, una salida en
  /// `caja_movimientos` (RF-GAS-02), junto con la auditoría.
  Future<String> registrarGasto({
    required String categoria,
    required String concepto,
    required DateTime fecha,
    required int montoCents,
    String? cajaSesionId,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final id = generateUuidV4();

      await _db
          .into(_db.gastos)
          .insert(
            GastosCompanion.insert(
              id: Value(id),
              categoria: categoria,
              concepto: concepto,
              fecha: fecha,
              monto: montoCents,
              cajaSesionId: Value(cajaSesionId),
              usuarioId: usuarioId,
            ),
          );

      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: usuarioId,
              accion: 'crear',
              modulo: 'gastos',
              entidadId: Value(id),
              datosDespues: Value(
                jsonEncode({
                  'categoria': categoria,
                  'concepto': concepto,
                  'monto': montoCents,
                  'saleDeCaja': cajaSesionId != null,
                }),
              ),
            ),
          );

      if (cajaSesionId != null) {
        await _db
            .into(_db.cajaMovimientos)
            .insert(
              CajaMovimientosCompanion.insert(
                cajaSesionId: cajaSesionId,
                tipo: TipoCajaMovimiento.gasto,
                monto: -montoCents,
                referenciaId: Value(id),
                usuarioId: usuarioId,
              ),
            );
      }

      return id;
    });
  }
}
