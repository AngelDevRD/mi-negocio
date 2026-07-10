import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' hide Producto;
import '../../../products/domain/entities/producto.dart';
import '../../data/datasources/inventory_local_datasource.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/movimiento_inventario.dart';
import '../../domain/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(
    InventoryLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

/// Texto de búsqueda activo en la pantalla de existencias.
final existenciasBusquedaProvider =
    NotifierProvider<ExistenciasBusquedaController, String>(
      ExistenciasBusquedaController.new,
    );

class ExistenciasBusquedaController extends Notifier<String> {
  @override
  String build() => '';

  void actualizar(String texto) => state = texto;
}

final existenciasProvider = StreamProvider<List<Producto>>((ref) {
  final busqueda = ref.watch(existenciasBusquedaProvider);
  return ref
      .watch(inventoryRepositoryProvider)
      .watchExistencias(busqueda: busqueda);
});

final kardexProvider = StreamProvider.autoDispose
    .family<List<MovimientoInventario>, String>((ref, productoId) {
      return ref.watch(inventoryRepositoryProvider).watchKardex(productoId);
    });
