import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart'
    hide Cliente, MovimientoClienteData;
import '../../data/datasources/customers_local_datasource.dart';
import '../../data/repositories/customers_repository_impl.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/customers_repository.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  return CustomersRepositoryImpl(
    CustomersLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

/// Clientes con saldo (la UI de fiado llega en la siguiente tarea).
final clientesProvider = StreamProvider.autoDispose<List<Cliente>>((ref) {
  return ref.watch(customersRepositoryProvider).watchClientes();
});

/// Historial del cliente, más reciente primero.
final movimientosClienteProvider = StreamProvider.autoDispose
    .family<List<MovimientoCliente>, String>((ref, clienteId) {
      return ref.watch(customersRepositoryProvider).watchMovimientos(clienteId);
    });
