import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/utils/money.dart';

part 'producto.freezed.dart';

/// Categoría de productos (RF-PROD). CRUD inline desde el formulario de
/// producto y desde la pantalla de gestión de categorías.
@freezed
abstract class Categoria with _$Categoria {
  const factory Categoria({required String id, required String nombre}) =
      _Categoria;
}

/// Producto del catálogo (RF-PROD). Precios en centavos vía [Money]; el
/// stock se replica aquí pero su fuente de verdad son los movimientos
/// de inventario (RN-03).
@freezed
abstract class Producto with _$Producto {
  const factory Producto({
    required String id,
    required String nombre,
    String? categoriaId,
    String? categoriaNombre,
    required String unidad,
    required Money precioCompra,
    required Money precioVenta,
    required double stockActual,
    required double stockMinimo,
    required bool activo,
  }) = _Producto;

  const Producto._();

  bool get stockBajo => stockActual <= stockMinimo;
}

/// Entrada del historial de cambios de precio de un producto (RN-04).
@freezed
abstract class HistorialPrecio with _$HistorialPrecio {
  const factory HistorialPrecio({
    required String id,
    required TipoPrecio tipo,
    required Money precioAnterior,
    required Money precioNuevo,
    required DateTime fecha,
    required String usuarioNombre,
  }) = _HistorialPrecio;
}
