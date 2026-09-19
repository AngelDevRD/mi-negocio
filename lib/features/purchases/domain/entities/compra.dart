import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/utils/money.dart';

part 'compra.freezed.dart';

/// Ítem de una compra (RF-COM): producto, cantidad y costo unitario vigentes
/// al momento de comprar.
@freezed
abstract class CompraItem with _$CompraItem {
  const factory CompraItem({
    required String productoId,
    required String productoNombre,
    required double cantidad,
    required Money costoUnitario,

    /// Unidad del producto ("libra", "unidad"...), de la misma consulta que
    /// trae el nombre.
    @Default('unidad') String unidad,

    /// Existencia ACTUAL del producto (no la de cuando se compró): sirve para
    /// avisar qué stock quedaría al anular la compra.
    @Default(0) double stockActual,
  }) = _CompraItem;

  const CompraItem._();

  Money get subtotal => Money((costoUnitario.cents * cantidad).round());
}

/// Compra a un proveedor (RF-COM): factura con foto opcional y sus ítems.
@freezed
abstract class Compra with _$Compra {
  const factory Compra({
    required String id,
    String? proveedorId,
    String? proveedorNombre,
    String? numeroFactura,
    String? fotoFacturaPath,
    required Money total,
    required bool pagadaDeCaja,
    required EstadoCompra estado,
    required String usuarioNombre,
    required DateTime fecha,
    @Default([]) List<CompraItem> items,

    /// Solo en el detalle y solo si se pagó de caja: `true` si la sesión de
    /// caja de ESE pago sigue abierta, `false` si ya se cerró; `null` si no
    /// se pagó de caja (o no hay registro del pago).
    bool? cajaDelPagoAbierta,
  }) = _Compra;
}

/// Ítem a registrar en una nueva compra (entrada de formulario).
@freezed
abstract class ItemCompraInput with _$ItemCompraInput {
  const factory ItemCompraInput({
    required String productoId,
    required String productoNombre,
    required double cantidad,
    required Money costoUnitario,

    /// Solo para mostrar ("2 libras × RD$ 150.00"); no se guarda.
    @Default('unidad') String unidad,
  }) = _ItemCompraInput;

  const ItemCompraInput._();

  Money get subtotal => Money((costoUnitario.cents * cantidad).round());
}

/// Qué pasó al anular una compra (RN-10), para que la pantalla lo informe.
class ResultadoAnulacionCompra {
  const ResultadoAnulacionCompra({
    this.cajaYaCerrada = false,
    this.costoRestaurado = const [],
    this.costoConservado = const [],
  });

  /// La compra se pagó de caja pero esa sesión ya se cerró: NO se generó
  /// movimiento (ese cierre ya cuadró con el efectivo real).
  final bool cajaYaCerrada;

  /// Productos cuyo costo volvió al anterior a esta compra.
  final List<String> costoRestaurado;

  /// Productos cuyo costo esta compra cambió pero que NO se restauró (alguien
  /// lo cambió después o no se puede identificar sin ambigüedad).
  final List<String> costoConservado;
}
