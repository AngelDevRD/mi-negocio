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
  }) = _ItemCompraInput;

  const ItemCompraInput._();

  Money get subtotal => Money((costoUnitario.cents * cantidad).round());
}
