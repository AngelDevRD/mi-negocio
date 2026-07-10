import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../entities/producto.dart';

/// Operaciones del catálogo de productos y categorías (RF-PROD).
abstract interface class ProductsRepository {
  /// Categorías activas, para selectores y filtros.
  Stream<List<Categoria>> watchCategorias();

  Future<Result<Categoria>> crearCategoria(String nombre);

  Future<Result<void>> renombrarCategoria({
    required String id,
    required String nombre,
  });

  /// Soft delete: deja de ofrecerse como opción nueva, pero los productos
  /// que ya la tenían conservan la referencia.
  Future<Result<void>> eliminarCategoria(String id);

  /// Productos del catálogo. `busqueda` filtra por nombre (contiene,
  /// insensible a mayúsculas), `categoriaId` por categoría exacta y
  /// `activo` por estado (`null` = todos).
  Stream<List<Producto>> watchProductos({
    String busqueda = '',
    String? categoriaId,
    bool? activo,
  });

  Future<Producto?> obtenerProducto(String id);

  /// Crea el producto. Si `stockInicial != 0`, registra un movimiento de
  /// inventario tipo `stockInicial` (RN-03).
  Future<Result<Producto>> crearProducto({
    required String nombre,
    String? categoriaId,
    required String unidad,
    required Money precioCompra,
    required Money precioVenta,
    required double stockInicial,
    required double stockMinimo,
    required String usuarioId,
  });

  /// Actualiza el producto. Si `precioCompra` o `precioVenta` cambian
  /// respecto al valor actual, inserta una entrada en `historial_precios`
  /// por cada uno (RN-04), todo dentro de la misma transacción.
  Future<Result<void>> actualizarProducto({
    required String id,
    required String nombre,
    String? categoriaId,
    required String unidad,
    required Money precioCompra,
    required Money precioVenta,
    required double stockMinimo,
    required String usuarioId,
  });

  /// Activa/desactiva el producto (no aparece para venta/compra si está
  /// inactivo, pero conserva su historial).
  Future<Result<void>> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  });

  /// Historial de cambios de precio del producto, más reciente primero.
  Stream<List<HistorialPrecio>> watchHistorialPrecios(String productoId);
}
