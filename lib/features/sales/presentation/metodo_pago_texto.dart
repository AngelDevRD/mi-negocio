import '../../../core/database/enums.dart';

/// Texto de un [MetodoPago] para la UI.
extension MetodoPagoTexto on MetodoPago {
  String get etiqueta => switch (this) {
    MetodoPago.efectivo => 'Efectivo',
    MetodoPago.tarjeta => 'Tarjeta',
    MetodoPago.transferencia => 'Transferencia',
    MetodoPago.credito => 'Fiado',
  };
}
