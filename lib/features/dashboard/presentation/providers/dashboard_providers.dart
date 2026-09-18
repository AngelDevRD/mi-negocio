import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/money.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../data/datasources/dashboard_dao.dart';
import '../../domain/entities/dashboard_data.dart';

final dashboardDaoProvider = Provider<DashboardDao>((ref) {
  return DashboardDao(ref.watch(appDatabaseProvider));
});

/// Instante "actual" para los agregados de hoy/mes del dashboard.
///
/// El dashboard es la ruta raíz y sus providers no son autoDispose (la app
/// puede quedar abierta indefinidamente), así que sin esto los límites de
/// día/mes se congelarían en el instante en que se creó el stream. Se
/// reprograma un único Timer hasta la próxima medianoche LOCAL (sin
/// polling): al dispararse, invalida este provider, lo que reconstruye los
/// streams de abajo con el nuevo día.
final diaActualProvider = Provider<DateTime>((ref) {
  final ahora = DateTime.now();
  final proximaMedianocheLocal = DateTime(
    ahora.year,
    ahora.month,
    ahora.day + 1,
  );
  final timer = Timer(proximaMedianocheLocal.difference(ahora), () {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);
  return ahora;
});

final cajaActualProvider = StreamProvider<CajaActual?>((ref) {
  return ref.watch(dashboardDaoProvider).watchCajaActual();
});

final ventasDelDiaProvider = StreamProvider<Money>((ref) {
  final ahora = ref.watch(diaActualProvider);
  return ref.watch(dashboardDaoProvider).watchVentasDelDia(ahora: ahora);
});

final ventasDelMesProvider = StreamProvider<Money>((ref) {
  final ahora = ref.watch(diaActualProvider);
  return ref.watch(dashboardDaoProvider).watchVentasDelMes(ahora: ahora);
});

final comprasDelMesProvider = StreamProvider<Money>((ref) {
  final ahora = ref.watch(diaActualProvider);
  return ref.watch(dashboardDaoProvider).watchComprasDelMes(ahora: ahora);
});

final gastosDelMesProvider = StreamProvider<Money>((ref) {
  final ahora = ref.watch(diaActualProvider);
  return ref.watch(dashboardDaoProvider).watchGastosDelMes(ahora: ahora);
});

/// Solo para Administrador (RN-15): la pantalla decide si lo muestra.
final gananciaDelMesProvider = StreamProvider<Money>((ref) {
  final ahora = ref.watch(diaActualProvider);
  return ref.watch(dashboardDaoProvider).watchGananciaDelMes(ahora: ahora);
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

/// ¿El negocio ya tiene productos (activos o no)? Decide si el Inicio muestra
/// los indicadores o la bienvenida de primer uso. Se lee del repositorio de
/// productos sin pasar por [productosFiltroProvider]: el filtro de la pestaña
/// Productos no debe afectar a esta decisión.
final negocioTieneProductosProvider = StreamProvider.autoDispose<bool>((ref) {
  return ref
      .watch(productsRepositoryProvider)
      .watchProductos()
      .map((productos) => productos.isNotEmpty);
});
