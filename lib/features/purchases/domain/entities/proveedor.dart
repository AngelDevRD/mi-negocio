import 'package:freezed_annotation/freezed_annotation.dart';

part 'proveedor.freezed.dart';

/// Proveedor de productos (RF-COM). Alta rápida desde el formulario de
/// compra.
@freezed
abstract class Proveedor with _$Proveedor {
  const factory Proveedor({
    required String id,
    required String nombre,
    String? telefono,
  }) = _Proveedor;
}
