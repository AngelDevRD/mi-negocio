import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/utils/money.dart';

part 'caja_sesion.freezed.dart';

/// Movimiento de caja (RF-CAJ): entradas y salidas con signo.
@freezed
abstract class CajaMovimiento with _$CajaMovimiento {
  const factory CajaMovimiento({
    required String id,
    required TipoCajaMovimiento tipo,
    required Money monto,
    String? motivo,
    String? referenciaId,
    required DateTime fecha,
  }) = _CajaMovimiento;
}

/// Sesión de caja diaria (RF-CAJ). RN-08: diferencia = contado − esperado.
/// RN-09: `montoDejadoSiguiente` precarga la apertura del día siguiente.
@freezed
abstract class CajaSesion with _$CajaSesion {
  const factory CajaSesion({
    required String id,
    required DateTime fechaApertura,
    required Money montoApertura,
    DateTime? fechaCierre,
    Money? montoEsperado,
    Money? montoContado,
    Money? diferencia,
    Money? montoDejadoSiguiente,
    required String usuarioAperturaNombre,
    String? usuarioCierreNombre,
    required EstadoCajaSesion estado,
    @Default([]) List<CajaMovimiento> movimientos,
  }) = _CajaSesion;

  const CajaSesion._();

  /// Apertura + suma de movimientos (esperado en vivo mientras está abierta).
  Money get montoActual =>
      movimientos.fold(montoApertura, (suma, m) => suma + m.monto);
}
