import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/utils/money.dart';

part 'venta.freezed.dart';

/// Ítem de una venta (RF-VEN): producto, cantidad, precio de venta y costo
/// vigente capturados al momento de vender (RN-05).
@freezed
abstract class VentaItem with _$VentaItem {
  const factory VentaItem({
    required String productoId,
    required String productoNombre,
    required double cantidad,
    required Money precioUnitario,
    required Money costoUnitario,
  }) = _VentaItem;

  const VentaItem._();

  Money get subtotal => Money((precioUnitario.cents * cantidad).round());

  Money get ganancia =>
      Money(((precioUnitario.cents - costoUnitario.cents) * cantidad).round());
}

/// Venta (RF-VEN). RN-10: se anula, nunca se borra.
@freezed
abstract class Venta with _$Venta {
  const factory Venta({
    required String id,
    required TipoVenta tipo,
    required Money total,
    required Money ganancia,
    required EstadoVenta estado,
    String? nota,
    required String usuarioNombre,
    required DateTime fecha,
    @Default([]) List<VentaItem> items,
  }) = _Venta;
}

/// Ítem a registrar en una nueva venta (entrada de carrito/formulario).
@freezed
abstract class ItemVentaInput with _$ItemVentaInput {
  const factory ItemVentaInput({
    required String productoId,
    required String productoNombre,
    required double cantidad,
    required Money precioUnitario,
  }) = _ItemVentaInput;

  const ItemVentaInput._();

  Money get subtotal => Money((precioUnitario.cents * cantidad).round());
}
