import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/money.dart';

part 'gasto.freezed.dart';

/// Categorías predefinidas (RF-GAS-01). El usuario también puede escribir
/// una categoría personalizada.
const List<String> categoriasGastoPredefinidas = [
  'Luz',
  'Agua',
  'Alquiler',
  'Transporte',
  'Otros',
];

/// Gasto operativo (RF-GAS): categoría, concepto, fecha y monto. Si
/// [saleDeCaja] es `true`, el monto se registró como salida en
/// `caja_movimientos`.
@freezed
abstract class Gasto with _$Gasto {
  const factory Gasto({
    required String id,
    required String categoria,
    required String concepto,
    required DateTime fecha,
    required Money monto,
    required bool saleDeCaja,
    required String usuarioNombre,
  }) = _Gasto;
}
