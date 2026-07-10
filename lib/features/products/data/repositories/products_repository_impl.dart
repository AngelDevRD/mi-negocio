import '../../../../core/database/app_database.dart' as db;
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/producto.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_datasource.dart';

/// Implementación del catálogo de productos y categorías (RF-PROD).
class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._local);

  final ProductsLocalDatasource _local;

  Categoria _categoriaAEntidad(db.Categoria row) =>
      Categoria(id: row.id, nombre: row.nombre);

  Producto _productoAEntidad((db.Producto, String?) row) {
    final (producto, categoriaNombre) = row;
    return Producto(
      id: producto.id,
      nombre: producto.nombre,
      categoriaId: producto.categoriaId,
      categoriaNombre: categoriaNombre,
      unidad: producto.unidad,
      precioCompra: Money(producto.precioCompra),
      precioVenta: Money(producto.precioVenta),
      stockActual: producto.stockActual,
      stockMinimo: producto.stockMinimo,
      activo: producto.activo,
    );
  }

  HistorialPrecio _historialAEntidad((db.HistorialPrecio, String) row) {
    final (historial, usuarioNombre) = row;
    return HistorialPrecio(
      id: historial.id,
      tipo: historial.tipo,
      precioAnterior: Money(historial.precioAnterior),
      precioNuevo: Money(historial.precioNuevo),
      fecha: historial.fecha,
      usuarioNombre: usuarioNombre,
    );
  }

  @override
  Stream<List<Categoria>> watchCategorias() {
    return _local.watchCategorias().map(
      (rows) => rows.map(_categoriaAEntidad).toList(),
    );
  }

  @override
  Future<Result<Categoria>> crearCategoria(String nombre) async {
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.isEmpty) {
      return const Result.fail(
        ValidationFailure('El nombre de la categoría es obligatorio.'),
      );
    }
    if (await _local.existeCategoria(nombreLimpio)) {
      return const Result.fail(
        ValidationFailure('Ya existe una categoría con ese nombre.'),
      );
    }
    final fila = await _local.crearCategoria(nombreLimpio);
    return Result.ok(_categoriaAEntidad(fila));
  }

  @override
  Future<Result<void>> renombrarCategoria({
    required String id,
    required String nombre,
  }) async {
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.isEmpty) {
      return const Result.fail(
        ValidationFailure('El nombre de la categoría es obligatorio.'),
      );
    }
    if (await _local.existeCategoria(nombreLimpio, excluirId: id)) {
      return const Result.fail(
        ValidationFailure('Ya existe una categoría con ese nombre.'),
      );
    }
    await _local.renombrarCategoria(id, nombreLimpio);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> eliminarCategoria(String id) async {
    await _local.eliminarCategoria(id);
    return const Result.ok(null);
  }

  @override
  Stream<List<Producto>> watchProductos({
    String busqueda = '',
    String? categoriaId,
    bool? activo,
  }) {
    return _local
        .watchProductos(
          busqueda: busqueda,
          categoriaId: categoriaId,
          activo: activo,
        )
        .map((rows) => rows.map(_productoAEntidad).toList());
  }

  @override
  Future<Producto?> obtenerProducto(String id) async {
    final fila = await _local.obtenerProducto(id);
    return fila == null ? null : _productoAEntidad(fila);
  }

  Result<void>? _validarDatosProducto({
    required String nombre,
    required String unidad,
    required Money precioCompra,
    required Money precioVenta,
    required double stockMinimo,
  }) {
    if (nombre.trim().isEmpty) {
      return const Result.fail(
        ValidationFailure('El nombre del producto es obligatorio.'),
      );
    }
    if (unidad.trim().isEmpty) {
      return const Result.fail(ValidationFailure('La unidad es obligatoria.'));
    }
    if (precioCompra.cents < 0 || precioVenta.cents < 0) {
      return const Result.fail(
        ValidationFailure('Los precios no pueden ser negativos.'),
      );
    }
    if (stockMinimo < 0) {
      return const Result.fail(
        ValidationFailure('El stock mínimo no puede ser negativo.'),
      );
    }
    return null;
  }

  @override
  Future<Result<Producto>> crearProducto({
    required String nombre,
    String? categoriaId,
    required String unidad,
    required Money precioCompra,
    required Money precioVenta,
    required double stockInicial,
    required double stockMinimo,
    required String usuarioId,
  }) async {
    final validacion = _validarDatosProducto(
      nombre: nombre,
      unidad: unidad,
      precioCompra: precioCompra,
      precioVenta: precioVenta,
      stockMinimo: stockMinimo,
    );
    if (validacion is Fail<void>) return Result.fail(validacion.failure);

    final nombreLimpio = nombre.trim();
    if (await _local.existeNombreProducto(nombreLimpio)) {
      return const Result.fail(
        ValidationFailure('Ya existe un producto con ese nombre.'),
      );
    }
    if (stockInicial < 0) {
      return const Result.fail(
        ValidationFailure('El stock inicial no puede ser negativo.'),
      );
    }

    final id = await _local.crearProducto(
      nombre: nombreLimpio,
      categoriaId: categoriaId,
      unidad: unidad.trim(),
      precioCompra: precioCompra.cents,
      precioVenta: precioVenta.cents,
      stockInicial: stockInicial,
      stockMinimo: stockMinimo,
      usuarioId: usuarioId,
    );
    final creado = await obtenerProducto(id);
    return Result.ok(creado!);
  }

  @override
  Future<Result<void>> actualizarProducto({
    required String id,
    required String nombre,
    String? categoriaId,
    required String unidad,
    required Money precioCompra,
    required Money precioVenta,
    required double stockMinimo,
    required String usuarioId,
  }) async {
    final validacion = _validarDatosProducto(
      nombre: nombre,
      unidad: unidad,
      precioCompra: precioCompra,
      precioVenta: precioVenta,
      stockMinimo: stockMinimo,
    );
    if (validacion is Fail<void>) return Result.fail(validacion.failure);

    final actualFila = await _local.obtenerProducto(id);
    if (actualFila == null) {
      return const Result.fail(
        ValidationFailure('El producto no existe o fue eliminado.'),
      );
    }
    final nombreLimpio = nombre.trim();
    if (await _local.existeNombreProducto(nombreLimpio, excluirId: id)) {
      return const Result.fail(
        ValidationFailure('Ya existe un producto con ese nombre.'),
      );
    }

    await _local.actualizarProducto(
      id: id,
      actual: actualFila.$1,
      nombre: nombreLimpio,
      categoriaId: categoriaId,
      unidad: unidad.trim(),
      precioCompra: precioCompra.cents,
      precioVenta: precioVenta.cents,
      stockMinimo: stockMinimo,
      usuarioId: usuarioId,
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  }) async {
    await _local.establecerActivo(id: id, activo: activo, usuarioId: usuarioId);
    return const Result.ok(null);
  }

  @override
  Stream<List<HistorialPrecio>> watchHistorialPrecios(String productoId) {
    return _local
        .watchHistorialPrecios(productoId)
        .map((rows) => rows.map(_historialAEntidad).toList());
  }
}
