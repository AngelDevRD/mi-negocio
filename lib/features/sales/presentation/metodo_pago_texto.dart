import 'package:flutter/material.dart';

import '../../../core/database/enums.dart';

/// Texto de un [MetodoPago] para la UI.
extension MetodoPagoTexto on MetodoPago {
  String get etiqueta => switch (this) {
    MetodoPago.efectivo => 'Efectivo',
    MetodoPago.tarjeta => 'Tarjeta',
    MetodoPago.transferencia => 'Transferencia',
    MetodoPago.credito => 'Fiado',
  };

  /// Ícono del método (siempre junto a [etiqueta]).
  IconData get icono => switch (this) {
    MetodoPago.efectivo => Icons.payments_outlined,
    MetodoPago.tarjeta => Icons.credit_card_outlined,
    MetodoPago.transferencia => Icons.account_balance_outlined,
    MetodoPago.credito => Icons.menu_book_outlined,
  };
}
