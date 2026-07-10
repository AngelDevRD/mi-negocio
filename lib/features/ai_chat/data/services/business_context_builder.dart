import '../../../analytics/data/datasources/analytics_dao.dart';
import '../../../analytics/domain/entities/analytics_data.dart';
import '../../../dashboard/data/datasources/dashboard_dao.dart';
import '../../../profile/data/datasources/profile_local_datasource.dart';

/// Construye el contexto del negocio (perfil + resumen financiero del mes +
/// productos con stock bajo) para enviarlo a la IA del asistente (FASE 21,
/// RF-IA-01). Es un snapshot puntual, no reactivo.
class BusinessContextBuilder {
  BusinessContextBuilder({
    required this.profile,
    required this.analytics,
    required this.dashboard,
  });

  final ProfileLocalDatasource profile;
  final AnalyticsDao analytics;
  final DashboardDao dashboard;

  Future<Map<String, dynamic>> construir() async {
    final negocio = await profile.watchNegocio().first;
    final resumen = await analytics.watchResumen(RangoAnalisis.mes).first;
    final bajoStock = await dashboard.watchProductosBajoStock(limit: 5).first;

    return {
      'negocio': {
        'nombre': negocio?.nombre,
        'identificacion': negocio?.identificacion,
        'direccion': negocio?.direccion,
        'telefono': negocio?.telefono,
        'moneda': negocio?.moneda,
      },
      'resumenDelMes': {
        'ventas': resumen.ventas.format(),
        'compras': resumen.compras.format(),
        'gastos': resumen.gastos.format(),
        'sueldos': resumen.sueldos.format(),
        'ganancia': resumen.ganancia.format(),
        'valorInventario': resumen.valorInventario.format(),
      },
      'productosConStockBajo': [
        for (final producto in bajoStock)
          {
            'nombre': producto.nombre,
            'stockActual': producto.stockActual,
            'stockMinimo': producto.stockMinimo,
            'unidad': producto.unidad,
          },
      ],
    };
  }
}
