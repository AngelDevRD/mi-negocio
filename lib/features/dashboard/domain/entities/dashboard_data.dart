import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/money.dart';

part 'dashboard_data.freezed.dart';

/// Origen de un movimiento reciente mostrado en el dashboard.
enum TipoMovimientoReciente { venta, compra, gasto }

/// Sesión de caja abierta y su monto actual (apertura + movimientos).
@freezed
abstract class CajaActual with _$CajaActual {
  const factory CajaActual({
    required String sesionId,
    required DateTime fechaApertura,
    required Money montoApertura,
    required Money montoActual,
  }) = _CajaActual;
}

/// Entrada de la lista "últimos movimientos" (mezcla ventas/compras/gastos).
@freezed
abstract class MovimientoReciente with _$MovimientoReciente {
  const factory MovimientoReciente({
    required String id,
    required TipoMovimientoReciente tipo,
    required DateTime fecha,
    required Money monto,
  }) = _MovimientoReciente;
}

/// Producto cuyo stock actual llegó al mínimo o por debajo (RF-INV-02).
@freezed
abstract class ProductoBajoStock with _$ProductoBajoStock {
  const factory ProductoBajoStock({
    required String id,
    required String nombre,
    required double stockActual,
    required double stockMinimo,
    required String unidad,
  }) = _ProductoBajoStock;
}
