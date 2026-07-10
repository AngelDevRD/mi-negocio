import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/money.dart';
import '../../data/datasources/dashboard_dao.dart';
import '../../domain/entities/dashboard_data.dart';

final dashboardDaoProvider = Provider<DashboardDao>((ref) {
  return DashboardDao(ref.watch(appDatabaseProvider));
});

final cajaActualProvider = StreamProvider<CajaActual?>((ref) {
  return ref.watch(dashboardDaoProvider).watchCajaActual();
});

final ventasDelDiaProvider = StreamProvider<Money>((ref) {
  return ref.watch(dashboardDaoProvider).watchVentasDelDia();
});

final ventasDelMesProvider = StreamProvider<Money>((ref) {
  return ref.watch(dashboardDaoProvider).watchVentasDelMes();
});

final comprasDelMesProvider = StreamProvider<Money>((ref) {
  return ref.watch(dashboardDaoProvider).watchComprasDelMes();
});

final gastosDelMesProvider = StreamProvider<Money>((ref) {
  return ref.watch(dashboardDaoProvider).watchGastosDelMes();
});

/// Solo para Administrador (RN-15): la pantalla decide si lo muestra.
final gananciaDelMesProvider = StreamProvider<Money>((ref) {
  return ref.watch(dashboardDaoProvider).watchGananciaDelMes();
});

final productosBajoStockProvider = StreamProvider<List<ProductoBajoStock>>((
  ref,
) {
  return ref.watch(dashboardDaoProvider).watchProductosBajoStock();
});

final movimientosRecientesProvider = StreamProvider<List<MovimientoReciente>>((
  ref,
) {
  return ref.watch(dashboardDaoProvider).watchMovimientosRecientes();
});
