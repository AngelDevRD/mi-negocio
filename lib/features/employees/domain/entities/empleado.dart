import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/utils/money.dart';

part 'empleado.freezed.dart';

/// Frecuencias de pago predefinidas (RF-EMP-02).
const List<String> frecuenciasPagoPredefinidas = [
  'Semanal',
  'Quincenal',
  'Mensual',
];

/// Formato de cédula dominicana: 000-0000000-0 (RF-EMP-02).
final RegExp formatoCedulaRD = RegExp(r'^\d{3}-\d{7}-\d{1}$');

/// Empleado de ventas o delivery (RF-EMP). Salario en centavos.
@freezed
abstract class Empleado with _$Empleado {
  const factory Empleado({
    required String id,
    required TipoEmpleado tipo,
    String? fotoPath,
    required String nombre,
    String? cedula,
    String? direccion,
    String? telefono,
    required DateTime fechaIngreso,
    required bool activo,
    Money? salario,
    String? frecuenciaPago,
  }) = _Empleado;

  const Empleado._();

  /// Tiempo trabajado desde [fechaIngreso] hasta hoy, ej. "2 años, 3 meses"
  /// (RF-EMP-04).
  String get tiempoTrabajado => formatearTiempoTrabajado(fechaIngreso);
}

/// Calcula el tiempo transcurrido entre [desde] y ahora en años y meses.
String formatearTiempoTrabajado(DateTime desde, {DateTime? hasta}) {
  final ahora = (hasta ?? DateTime.now()).toUtc();
  final inicio = desde.toUtc();

  var meses = (ahora.year - inicio.year) * 12 + (ahora.month - inicio.month);
  if (ahora.day < inicio.day) meses--;
  if (meses < 0) meses = 0;

  final anios = meses ~/ 12;
  final mesesRestantes = meses % 12;

  if (anios == 0 && mesesRestantes == 0) return 'Menos de un mes';

  final partes = <String>[];
  if (anios > 0) {
    partes.add(anios == 1 ? '1 año' : '$anios años');
  }
  if (mesesRestantes > 0) {
    partes.add(mesesRestantes == 1 ? '1 mes' : '$mesesRestantes meses');
  }
  return partes.join(', ');
}
