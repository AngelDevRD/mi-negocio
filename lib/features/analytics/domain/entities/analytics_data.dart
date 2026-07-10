import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/money.dart';

part 'analytics_data.freezed.dart';

/// Rango de tiempo para los históricos del centro de análisis (RF-ANL-01).
enum RangoAnalisis { mes, trimestre, anio, todo }

/// Resumen financiero acumulado del rango seleccionado, más el valor
/// actual del inventario (RF-ANL-01/02). `ganancia` es la ganancia neta
/// (ganancia bruta de ventas − gastos − sueldos).
@freezed
abstract class ResumenFinanciero with _$ResumenFinanciero {
  const factory ResumenFinanciero({
    required Money ventas,
    required Money compras,
    required Money gastos,
    required Money sueldos,
    required Money ganancia,
    required Money dineroMovido,
    required Money valorInventario,
  }) = _ResumenFinanciero;
}

/// Totales de un mes para las gráficas de línea y barras (RF-ANL-04).
@freezed
abstract class PuntoMensual with _$PuntoMensual {
  const factory PuntoMensual({
    required DateTime mes,
    required Money ventas,
    required Money compras,
    required Money gastos,
    required Money sueldos,
    required Money ganancia,
  }) = _PuntoMensual;
}

/// Total de gastos de una categoría, para el pastel de gastos (RF-ANL-04).
@freezed
abstract class GastoPorCategoria with _$GastoPorCategoria {
  const factory GastoPorCategoria({
    required String categoria,
    required Money total,
  }) = _GastoPorCategoria;
}

/// Comparativa mes actual vs mes anterior con % de variación (RF-ANL-05).
@freezed
abstract class ComparativaMensual with _$ComparativaMensual {
  const factory ComparativaMensual({
    required Money ventasActual,
    required Money ventasAnterior,
    required Money gastosActual,
    required Money gastosAnterior,
    required Money gananciaActual,
    required Money gananciaAnterior,
  }) = _ComparativaMensual;

  const ComparativaMensual._();

  /// % de variación de [actual] respecto a [anterior]. `null` si el mes
  /// anterior fue cero (no hay base para comparar).
  static double? _variacion(Money actual, Money anterior) {
    if (anterior.cents == 0) return null;
    return (actual.cents - anterior.cents) / anterior.cents * 100;
  }

  double? get variacionVentas => _variacion(ventasActual, ventasAnterior);
  double? get variacionGastos => _variacion(gastosActual, gastosAnterior);
  double? get variacionGanancia => _variacion(gananciaActual, gananciaAnterior);
}

/// Ranking de un producto por unidades vendidas y ganancia acumulada
/// (RF-ANL-03): sirve para "más vendido", "menos vendido" y "más rentable".
@freezed
abstract class ProductoVentasRanking with _$ProductoVentasRanking {
  const factory ProductoVentasRanking({
    required String id,
    required String nombre,
    required double unidades,
    required Money ganancia,
  }) = _ProductoVentasRanking;
}

/// Ranking de un empleado por antigüedad y total pagado (RF-ANL-03).
@freezed
abstract class EmpleadoPagosRanking with _$EmpleadoPagosRanking {
  const factory EmpleadoPagosRanking({
    required String id,
    required String nombre,
    required DateTime fechaIngreso,
    required Money totalPagado,
  }) = _EmpleadoPagosRanking;
}
