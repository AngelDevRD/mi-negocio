import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/enums.dart';

part 'movimiento_inventario.freezed.dart';

/// Entrada del kárdex de un producto (RF-INV-02): el stock solo cambia a
/// través de estos movimientos (RN-03).
@freezed
abstract class MovimientoInventario with _$MovimientoInventario {
  const factory MovimientoInventario({
    required String id,
    required TipoMovimientoInventario tipo,

    /// Con signo: positiva = entrada, negativa = salida.
    required double cantidad,
    required double stockResultante,

    /// Obligatorio en ajustes manuales (RN-19).
    String? motivo,

    /// Venta, compra o anulación que originó el movimiento.
    String? referenciaId,
    required String usuarioNombre,
    required DateTime fecha,
  }) = _MovimientoInventario;
}
