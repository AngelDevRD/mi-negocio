import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart'
    hide Empleado, PagosEmpleado;
import '../../../../core/utils/money.dart';
import '../../data/datasources/employees_local_datasource.dart';
import '../../data/repositories/employees_repository_impl.dart';
import '../../domain/entities/empleado.dart';
import '../../domain/entities/pago_empleado.dart';
import '../../domain/repositories/employees_repository.dart';

final employeesRepositoryProvider = Provider<EmployeesRepository>((ref) {
  return EmployeesRepositoryImpl(
    EmployeesLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

/// Empleados de la sección [tipo], activos primero (RF-EMP-01).
final empleadosProvider = StreamProvider.autoDispose
    .family<List<Empleado>, TipoEmpleado>((ref, tipo) {
      return ref.watch(employeesRepositoryProvider).watchEmpleados(tipo: tipo);
    });

final empleadoProvider = FutureProvider.autoDispose.family<Empleado?, String>((
  ref,
  id,
) {
  return ref.watch(employeesRepositoryProvider).obtenerEmpleado(id);
});

/// Pagos del empleado, más reciente primero (RF-EMP-04).
final pagosEmpleadoProvider = StreamProvider.autoDispose
    .family<List<PagoEmpleado>, String>((ref, empleadoId) {
      return ref.watch(employeesRepositoryProvider).watchPagos(empleadoId);
    });

/// Total pagado acumulado al empleado (RF-EMP-04).
final totalPagadoProvider = StreamProvider.autoDispose.family<Money, String>((
  ref,
  empleadoId,
) {
  return ref.watch(employeesRepositoryProvider).watchTotalPagado(empleadoId);
});
