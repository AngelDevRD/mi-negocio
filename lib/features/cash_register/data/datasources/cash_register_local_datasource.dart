import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';
import '../../../../core/sync/payloads/auditoria_payload.dart';
import '../../../../core/sync/payloads/operacion_payloads.dart';
import '../../../../core/sync/sync_queue_writer.dart';
import '../../../../core/utils/money.dart';
import '../../../customers/data/datasources/customers_local_datasource.dart';
import '../../../sales/data/datasources/sales_local_datasource.dart';
import '../../domain/entities/resumen_turno.dart';

/// Lanzada dentro de la transacción de
/// [CashRegisterLocalDatasource.registrarMovimientoManual] cuando la salida
/// pediría más efectivo del que hay en la caja: se lanza antes de escribir.
class SalidaExcedeEfectivoException implements Exception {
  const SalidaExcedeEfectivoException({
    required this.disponible,
    required this.monto,
  });

  /// Centavos de efectivo que hay en la caja en ese momento.
  final int disponible;
  final int monto;
}

/// Acceso a `caja_sesiones`/`caja_movimientos` (RF-CAJ): sesión actual,
/// historial, movimientos manuales, arqueo y cierre de caja.
class CashRegisterLocalDatasource {
  CashRegisterLocalDatasource(this._db);

  final AppDatabase _db;

  /// Sesión de caja abierta (si hay), con el nombre del usuario que la abrió.
  ///
  /// El `leftOuterJoin` con `caja_movimientos` + `count` no aporta datos: hace
  /// que drift observe también esa tabla, así el stream se re-emite cuando
  /// entra un movimiento (venta, entrada, salida...) y no solo cuando cambia
  /// la fila de la sesión. Sin esto la pestaña Caja quedaba desactualizada.
  Stream<(CajaSesione, String)?> watchSesionAbierta() {
    final movimientos = _db.cajaMovimientos.id.count();
    final query =
        _db.select(_db.cajaSesiones).join([
            innerJoin(
              _db.usuarios,
              _db.usuarios.id.equalsExp(_db.cajaSesiones.usuarioApertura),
            ),
            leftOuterJoin(
              _db.cajaMovimientos,
              _db.cajaMovimientos.cajaSesionId.equalsExp(_db.cajaSesiones.id),
            ),
          ])
          ..addColumns([movimientos])
          ..where(_db.cajaSesiones.estado.equalsValue(EstadoCajaSesion.abierta))
          ..groupBy([_db.cajaSesiones.id]);
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

  /// Registra una entrada o salida manual de efectivo en UNA transacción:
  /// el `caja_movimiento` (con signo), su auditoría y ambas filas en la cola de
  /// sync. Lanza [SinCajaAbiertaException] o [SalidaExcedeEfectivoException]
  /// SIN escribir nada (ambas se comprueban dentro de la transacción).
  Future<void> registrarMovimientoManual({
    required bool entrada,
    required int montoCents,
    required String motivo,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final sesion =
          await (_db.select(_db.cajaSesiones)
                ..where((t) => t.estado.equalsValue(EstadoCajaSesion.abierta))
                ..orderBy([(t) => OrderingTerm.desc(t.fechaApertura)])
                ..limit(1))
              .getSingleOrNull();
      if (sesion == null) throw const SinCajaAbiertaException();

      if (!entrada) {
        final suma = _db.cajaMovimientos.monto.sum();
        final fila =
            await (_db.selectOnly(_db.cajaMovimientos)
                  ..addColumns([suma])
                  ..where(_db.cajaMovimientos.cajaSesionId.equals(sesion.id)))
                .getSingle();
        final disponible =
            sesion.montoApertura + (fila.read(suma) ?? 0).toInt();
        if (montoCents > disponible) {
          throw SalidaExcedeEfectivoException(
            disponible: disponible,
            monto: montoCents,
          );
        }
      }

      final movId = generateUuidV4();
      await _db
          .into(_db.cajaMovimientos)
          .insert(
            CajaMovimientosCompanion.insert(
              id: Value(movId),
              cajaSesionId: sesion.id,
              tipo: entrada
                  ? TipoCajaMovimiento.entradaManual
                  : TipoCajaMovimiento.salidaManual,
              monto: entrada ? montoCents : -montoCents,
              motivo: Value(motivo),
              usuarioId: usuarioId,
            ),
          );
      final movFila = await (_db.select(
        _db.cajaMovimientos,
      )..where((t) => t.id.equals(movId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'caja_movimientos',
        registroId: movId,
        operacion: OperacionSync.insert,
        payload: cajaMovimientoPayload(movFila),
      );

      final auditId = generateUuidV4();
      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              id: Value(auditId),
              usuarioId: usuarioId,
              accion: entrada ? 'entrada_manual' : 'salida_manual',
              modulo: 'caja',
              entidadId: Value(movId),
              datosDespues: Value(
                jsonEncode({
                  'cajaSesionId': sesion.id,
                  'monto': montoCents,
                  'motivo': motivo,
                }),
              ),
            ),
          );
      final auditFila = await (_db.select(
        _db.auditoria,
      )..where((t) => t.id.equals(auditId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'auditoria',
        registroId: auditId,
        operacion: OperacionSync.insert,
        payload: auditoriaPayload(auditFila),
      );
    });
  }

  /// Arqueo de una sesión (SOLO LECTURA). Ventas por método según
  /// `venta_pagos` (la venta sin pagos cuenta como efectivo: [pagosDeVenta]);
  /// abonos de clientes por método; y el resto sale de `caja_movimientos`.
  ///
  /// Un abono en efectivo queda ligado a la sesión (`cajaSesionId`); uno por
  /// tarjeta o transferencia no toca la caja, así que se ubica por la ventana
  /// de tiempo de la sesión (apertura → cierre, o hasta ahora si sigue abierta).
  Future<ResumenTurno?> obtenerResumenTurno(String sesionId) async {
    final sesion = await (_db.select(
      _db.cajaSesiones,
    )..where((t) => t.id.equals(sesionId))).getSingleOrNull();
    if (sesion == null) return null;

    final ventas =
        await (_db.select(_db.ventas)..where(
              (t) =>
                  t.cajaSesionId.equals(sesionId) &
                  t.estado.equalsValue(EstadoVenta.completada),
            ))
            .get();
    final porMetodo = {for (final m in MetodoPago.values) m: 0};
    for (final venta in ventas) {
      for (final pago in await pagosDeVenta(_db, venta.id, venta.total)) {
        porMetodo[pago.metodo] = porMetodo[pago.metodo]! + pago.monto;
      }
    }

    final cierre = sesion.fechaCierre;
    final abonos =
        await (_db.select(_db.movimientosCliente)..where((t) {
              final enLaVentana =
                  t.cajaSesionId.isNull() &
                  (cierre == null
                      ? t.fecha.isBiggerOrEqualValue(sesion.fechaApertura)
                      : t.fecha.isBetweenValues(sesion.fechaApertura, cierre));
              return t.tipo.equalsValue(TipoMovimientoCliente.abono) &
                  (t.cajaSesionId.equals(sesionId) | enLaVentana);
            }))
            .get();
    final abonosPorMetodo = {for (final m in MetodoPago.values) m: 0};
    for (final abono in abonos) {
      // El monto del abono va con signo negativo en el libro del cliente.
      final metodo = abono.metodoPago ?? MetodoPago.efectivo;
      abonosPorMetodo[metodo] = abonosPorMetodo[metodo]! - abono.monto;
    }

    final movimientos = await obtenerMovimientos(sesionId);
    int suma(TipoCajaMovimiento tipo) => movimientos
        .where((m) => m.tipo == tipo)
        .fold<int>(0, (total, m) => total + m.monto);
    // El retiro del cierre se hace DESPUÉS de contar: no forma parte del
    // esperado (por eso una sesión cerrada muestra el mismo esperado que guardó).
    final esperado = movimientos
        .where((m) => m.tipo != TipoCajaMovimiento.retiroCierre)
        .fold<int>(sesion.montoApertura, (total, m) => total + m.monto);

    return ResumenTurno(
      montoApertura: Money(sesion.montoApertura),
      ventasEfectivo: Money(porMetodo[MetodoPago.efectivo]!),
      ventasTarjeta: Money(porMetodo[MetodoPago.tarjeta]!),
      ventasTransferencia: Money(porMetodo[MetodoPago.transferencia]!),
      ventasFiado: Money(porMetodo[MetodoPago.credito]!),
      abonosEfectivo: Money(abonosPorMetodo[MetodoPago.efectivo]!),
      abonosTarjeta: Money(abonosPorMetodo[MetodoPago.tarjeta]!),
      abonosTransferencia: Money(abonosPorMetodo[MetodoPago.transferencia]!),
      entradasManuales: Money(suma(TipoCajaMovimiento.entradaManual)),
      salidasManuales: Money(-suma(TipoCajaMovimiento.salidaManual)),
      gastos: Money(-suma(TipoCajaMovimiento.gasto)),
      compras: Money(-suma(TipoCajaMovimiento.compra)),
      pagosEmpleados: Money(-suma(TipoCajaMovimiento.pagoEmpleado)),
      efectivoEsperado: Money(esperado),
    );
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
      final cajaFila = await (_db.select(
        _db.cajaSesiones,
      )..where((t) => t.id.equals(sesionId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'caja_sesiones',
        registroId: sesionId,
        operacion: OperacionSync.update,
        payload: cajaSesionPayload(cajaFila),
      );

      if (retiro != 0) {
        final movId = generateUuidV4();
        await _db
            .into(_db.cajaMovimientos)
            .insert(
              CajaMovimientosCompanion.insert(
                id: Value(movId),
                cajaSesionId: sesionId,
                tipo: TipoCajaMovimiento.retiroCierre,
                monto: -retiro,
                referenciaId: Value(sesionId),
                usuarioId: usuarioId,
              ),
            );
        final movFila = await (_db.select(
          _db.cajaMovimientos,
        )..where((t) => t.id.equals(movId))).getSingle();
        await enqueueSync(
          _db,
          tabla: 'caja_movimientos',
          registroId: movId,
          operacion: OperacionSync.insert,
          payload: cajaMovimientoPayload(movFila),
        );
      }

      final auditId = generateUuidV4();
      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              id: Value(auditId),
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
      final auditFila = await (_db.select(
        _db.auditoria,
      )..where((t) => t.id.equals(auditId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'auditoria',
        registroId: auditId,
        operacion: OperacionSync.insert,
        payload: auditoriaPayload(auditFila),
      );
    });
  }
}
