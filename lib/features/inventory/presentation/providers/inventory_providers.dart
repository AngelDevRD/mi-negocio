import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' hide Producto;
import '../../data/datasources/inventory_local_datasource.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/movimiento_inventario.dart';
import '../../domain/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(
    InventoryLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

final kardexProvider = StreamProvider.autoDispose
    .family<List<MovimientoInventario>, String>((ref, productoId) {
      return ref.watch(inventoryRepositoryProvider).watchKardex(productoId);
    });
