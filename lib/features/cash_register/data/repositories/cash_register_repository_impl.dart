import '../../../../core/database/app_database.dart' as db;
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../../customers/data/datasources/customers_local_datasource.dart'
    show SinCajaAbiertaException;
import '../../domain/entities/caja_sesion.dart';
import '../../domain/entities/resumen_turno.dart';
import '../../domain/repositories/cash_register_repository.dart';
import '../datasources/cash_register_local_datasource.dart';

/// Largo máximo del motivo de un movimiento manual.
const _motivoMaximo = 120;

/// Implementación de caja diaria (RF-CAJ): sesión actual, historial, cierre,
/// movimientos manuales y arqueo.
class CashRegisterRepositoryImpl implements CashRegisterRepository {
  CashRegisterRepositoryImpl(this._local);

  final CashRegisterLocalDatasource _local;

  CajaMovimiento _movimientoAEntidad(db.CajaMovimiento row) {
    return CajaMovimiento(
      id: row.id,
      tipo: row.tipo,
      monto: Money(row.monto),
      motivo: row.motivo,
      referenciaId: row.referenciaId,
      fecha: row.fecha,
    );
  }

  CajaSesion _sesionAEntidad(
    db.CajaSesione sesion,
    String usuarioAperturaNombre,
    String? usuarioCierreNombre, {
    List<CajaMovimiento> movimientos = const [],
  }) {
    return CajaSesion(
      id: sesion.id,
      fechaApertura: sesion.fechaApertura,
      montoApertura: Money(sesion.montoApertura),
      fechaCierre: sesion.fechaCierre,
      montoEsperado: sesion.montoEsperado == null
          ? null
          : Money(sesion.montoEsperado!),
      montoContado: sesion.montoContado == null
          ? null
          : Money(sesion.montoContado!),
      diferencia: sesion.diferencia == null ? null : Money(sesion.diferencia!),
      montoDejadoSiguiente: sesion.montoDejadoSiguiente == null
          ? null
          : Money(sesion.montoDejadoSiguiente!),
      usuarioAperturaNombre: usuarioAperturaNombre,
      usuarioCierreNombre: usuarioCierreNombre,
      estado: sesion.estado,
      movimientos: movimientos,
    );
  }

  @override
  Stream<CajaSesion?> watchSesionActual() {
    return _local.watchSesionAbierta().asyncMap((sesion) async {
      if (sesion == null) return null;
      final (fila, usuarioNombre) = sesion;
      final movimientos = await _local.obtenerMovimientos(fila.id);
      return _sesionAEntidad(
        fila,
        usuarioNombre,
        null,
        movimientos: movimientos.map(_movimientoAEntidad).toList(),
      );
    });
  }

  @override
  Stream<List<CajaSesion>> watchHistorial() {
    return _local.watchHistorial().map(
      (rows) =>
          rows.map((row) => _sesionAEntidad(row.$1, row.$2, row.$3)).toList(),
    );
  }

  @override
  Future<CajaSesion?> obtenerSesion(String id) async {
    final row = await _local.obtenerSesion(id);
    if (row == null) return null;
    final (fila, usuarioAperturaNombre, usuarioCierreNombre) = row;
    final movimientos = await _local.obtenerMovimientos(id);
    return _sesionAEntidad(
      fila,
      usuarioAperturaNombre,
      usuarioCierreNombre,
      movimientos: movimientos.map(_movimientoAEntidad).toList(),
    );
  }

  @override
  Future<Money> obtenerMontoSugeridoApertura() async {
    final ultima = await _local.obtenerUltimaSesionCerrada();
    if (ultima?.montoDejadoSiguiente == null) return Money.zero;
    return Money(ultima!.montoDejadoSiguiente!);
  }

  @override
  Future<Result<void>> cerrarCaja({
    required Money montoContado,
    required Money montoDejarSiguiente,
    required String usuarioId,
  }) async {
    if (montoContado.cents < 0) {
      return const Result.fail(
        ValidationFailure('El monto contado no puede ser negativo.'),
      );
    }
    if (montoDejarSiguiente.cents < 0) {
      return const Result.fail(
        ValidationFailure('El monto a dejar no puede ser negativo.'),
      );
    }
    if (montoDejarSiguiente > montoContado) {
      return const Result.fail(
        ValidationFailure(
          'El monto a dejar no puede ser mayor que el monto contado.',
        ),
      );
    }

    final sesionAbierta = await _local.watchSesionAbierta().first;
    if (sesionAbierta == null) {
      return const Result.fail(
        ValidationFailure('No hay una sesión de caja abierta.'),
      );
    }
    final (fila, _) = sesionAbierta;
    final movimientos = await _local.obtenerMovimientos(fila.id);
    final montoEsperado = movimientos.fold<int>(
      fila.montoApertura,
      (suma, m) => suma + m.monto,
    );

    await _local.cerrarCaja(
      sesionId: fila.id,
      montoEsperadoCents: montoEsperado,
      montoContadoCents: montoContado.cents,
      montoDejarSiguienteCents: montoDejarSiguiente.cents,
      usuarioId: usuarioId,
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> registrarMovimientoManual({
    required bool entrada,
    required Money monto,
    required String motivo,
    required String usuarioId,
  }) async {
    if (monto.cents <= 0) {
      return const Result.fail(
        ValidationFailure('El monto debe ser mayor que cero.'),
      );
    }
    final motivoLimpio = motivo.trim();
    if (motivoLimpio.isEmpty) {
      return const Result.fail(ValidationFailure('Indica el motivo.'));
    }
    if (motivoLimpio.length > _motivoMaximo) {
      return const Result.fail(
        ValidationFailure(
          'El motivo no puede pasar de $_motivoMaximo caracteres.',
        ),
      );
    }

    try {
      await _local.registrarMovimientoManual(
        entrada: entrada,
        montoCents: monto.cents,
        motivo: motivoLimpio,
        usuarioId: usuarioId,
      );
      return const Result.ok(null);
    } on SinCajaAbiertaException {
      return const Result.fail(
        BusinessRuleFailure(
          'Debe abrir una caja antes de registrar movimientos de efectivo.',
          rule: 'RN-01',
        ),
      );
    } on SalidaExcedeEfectivoException catch (e) {
      return Result.fail(
        BusinessRuleFailure(
          'No hay suficiente efectivo en la caja: hay '
          '${Money(e.disponible).format()} y la salida es de '
          '${Money(e.monto).format()}.',
          rule: 'CAJA-SALIDA',
        ),
      );
    }
  }

  @override
  Future<ResumenTurno?> obtenerResumenTurno(String sesionId) =>
      _local.obtenerResumenTurno(sesionId);
}
