import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/money.dart';

part 'pago_empleado.freezed.dart';

/// Pago realizado a un empleado (RF-EMP-03): fecha, monto, período cubierto
/// y si salió de la caja del día.
@freezed
abstract class PagoEmpleado with _$PagoEmpleado {
  const factory PagoEmpleado({
    required String id,
    required DateTime fecha,
    required Money monto,
    String? periodo,
    required bool saleDeCaja,
    required String usuarioNombre,
  }) = _PagoEmpleado;
}
