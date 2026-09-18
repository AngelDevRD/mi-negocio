import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart'
    hide Usuario, Categoria, Producto, HistorialPrecio;
import '../../data/datasources/products_local_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/entities/producto.dart';
import '../../domain/repositories/products_repository.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(
    ProductsLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

final categoriasProvider = StreamProvider<List<Categoria>>((ref) {
  return ref.watch(productsRepositoryProvider).watchCategorias();
});

/// Filtros activos de la lista de productos.
class ProductosFiltro {
  const ProductosFiltro({
    this.busqueda = '',
    this.categoriaId,
    this.soloActivos = true,
  });

  final String busqueda;
  final String? categoriaId;

  /// `true`: solo activos · `false`: solo inactivos · valor por defecto
  /// "Activos"; el toggle en pantalla puede mostrar todos pasando `null`
  /// vía [copyWith].
  final bool? soloActivos;

  ProductosFiltro copyWith({
    String? busqueda,
    Object? categoriaId = _sinCambio,
    Object? soloActivos = _sinCambio,
  }) {
    return ProductosFiltro(
      busqueda: busqueda ?? this.busqueda,
      categoriaId: categoriaId == _sinCambio
          ? this.categoriaId
          : categoriaId as String?,
      soloActivos: soloActivos == _sinCambio
          ? this.soloActivos
          : soloActivos as bool?,
    );
  }

  static const _sinCambio = Object();
}

final productosFiltroProvider =
    NotifierProvider<ProductosFiltroController, ProductosFiltro>(
      ProductosFiltroController.new,
    );

class ProductosFiltroController extends Notifier<ProductosFiltro> {
  @override
  ProductosFiltro build() => const ProductosFiltro();

  void actualizar(ProductosFiltro Function(ProductosFiltro actual) update) {
    state = update(state);
  }
}

final productosProvider = StreamProvider<List<Producto>>((ref) {
  final filtro = ref.watch(productosFiltroProvider);
  return ref
      .watch(productsRepositoryProvider)
      .watchProductos(
        busqueda: filtro.busqueda,
        categoriaId: filtro.categoriaId,
        activo: filtro.soloActivos,
      );
});

/// Texto de búsqueda de la selección de productos al VENDER o COMPRAR
/// (venta rápida, venta detallada, diálogo de compra).
///
/// Es independiente de [productosFiltroProvider] (el de la pestaña
/// Productos, que sigue viva en el shell): así escribir aquí no filtra la
/// lista de Productos ni viceversa. `autoDispose`: se descarta solo cuando
/// la pantalla/diálogo que lo observa se cierra, sin código en `dispose()`.
final busquedaSeleccionProductoProvider =
    NotifierProvider.autoDispose<BusquedaSeleccionProductoController, String>(
      BusquedaSeleccionProductoController.new,
    );

class BusquedaSeleccionProductoController extends Notifier<String> {
  @override
  String build() => '';

  void actualizar(String texto) => state = texto;
}

/// Productos ofrecidos al vender/comprar: SOLO activos (un producto inactivo
/// no se vende ni se compra), filtrados por
/// [busquedaSeleccionProductoProvider]. No depende del filtro de categoría
/// ni de "activos/inactivos" de la pestaña Productos.
final productosParaSeleccionProvider =
    StreamProvider.autoDispose<List<Producto>>((ref) {
      final busqueda = ref.watch(busquedaSeleccionProductoProvider);
      return ref
          .watch(productsRepositoryProvider)
          .watchProductos(busqueda: busqueda, activo: true);
    });

final productoProvider = FutureProvider.autoDispose.family<Producto?, String>((
  ref,
  id,
) {
  return ref.watch(productsRepositoryProvider).obtenerProducto(id);
});

final historialPreciosProvider = StreamProvider.autoDispose
    .family<List<HistorialPrecio>, String>((ref, productoId) {
      return ref
          .watch(productsRepositoryProvider)
          .watchHistorialPrecios(productoId);
    });
