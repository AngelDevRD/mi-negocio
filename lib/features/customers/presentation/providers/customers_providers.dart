import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/app_database.dart'
    hide Cliente, MovimientoClienteData;
import '../../../../core/utils/money.dart';
import '../../data/datasources/customers_local_datasource.dart';
import '../../data/repositories/customers_repository_impl.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/customers_repository.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  return CustomersRepositoryImpl(
    CustomersLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

/// Todos los clientes (activos e inactivos) con su saldo calculado.
final clientesProvider = StreamProvider.autoDispose<List<Cliente>>((ref) {
  return ref.watch(customersRepositoryProvider).watchClientes();
});

/// Clientes cuyo nombre o teléfono contiene [busqueda] (vacío = todos).
final clientesBusquedaProvider = StreamProvider.autoDispose
    .family<List<Cliente>, String>((ref, busqueda) {
      return ref
          .watch(customersRepositoryProvider)
          .watchClientes(busqueda: busqueda);
    });

/// Total por cobrar: suma de los saldos POSITIVOS (lo que los clientes
/// deben). Un saldo a favor no compensa la deuda de otro cliente.
final totalPorCobrarProvider = StreamProvider.autoDispose<Money>((ref) {
  return ref
      .watch(customersRepositoryProvider)
      .watchClientes()
      .map(totalPorCobrar);
});

/// Suma de los saldos positivos de [clientes].
Money totalPorCobrar(List<Cliente> clientes) => clientes.fold(
  const Money(0),
  (suma, c) => c.saldo.cents > 0 ? Money(suma.cents + c.saldo.cents) : suma,
);

/// Historial del cliente, más reciente primero.
final movimientosClienteProvider = StreamProvider.autoDispose
    .family<List<MovimientoCliente>, String>((ref, clienteId) {
      return ref.watch(customersRepositoryProvider).watchMovimientos(clienteId);
    });

/// Comparte un texto con la hoja del sistema (sustituible en tests).
final compartirTextoProvider = Provider<Future<void> Function(String)>((ref) {
  return (texto) async {
    await Share.share(texto);
  };
});
