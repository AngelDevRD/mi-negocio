import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/analytics_dao.dart';
import '../../domain/entities/analytics_data.dart';

final analyticsDaoProvider = Provider<AnalyticsDao>((ref) {
  return AnalyticsDao(ref.watch(appDatabaseProvider));
});

/// Rango de tiempo seleccionado para los históricos (RF-ANL-01).
final rangoAnalisisProvider =
    NotifierProvider<RangoAnalisisController, RangoAnalisis>(
      RangoAnalisisController.new,
    );

class RangoAnalisisController extends Notifier<RangoAnalisis> {
  @override
  RangoAnalisis build() => RangoAnalisis.mes;

  void seleccionar(RangoAnalisis rango) => state = rango;
}

final resumenFinancieroProvider = StreamProvider<ResumenFinanciero>((ref) {
  final rango = ref.watch(rangoAnalisisProvider);
  return ref.watch(analyticsDaoProvider).watchResumen(rango);
});

final serieMensualProvider = StreamProvider<List<PuntoMensual>>((ref) {
  final rango = ref.watch(rangoAnalisisProvider);
  return ref.watch(analyticsDaoProvider).watchSerieMensual(rango);
});

final gastosPorCategoriaProvider = StreamProvider<List<GastoPorCategoria>>((
  ref,
) {
  final rango = ref.watch(rangoAnalisisProvider);
  return ref.watch(analyticsDaoProvider).watchGastosPorCategoria(rango);
});

final comparativaMensualProvider = StreamProvider<ComparativaMensual>((ref) {
  return ref.watch(analyticsDaoProvider).watchComparativaMensual();
});

final rankingProductosProvider = StreamProvider<List<ProductoVentasRanking>>((
  ref,
) {
  final rango = ref.watch(rangoAnalisisProvider);
  return ref.watch(analyticsDaoProvider).watchRankingProductos(rango);
});

final rankingEmpleadosProvider = StreamProvider<List<EmpleadoPagosRanking>>((
  ref,
) {
  return ref.watch(analyticsDaoProvider).watchRankingEmpleados();
});
