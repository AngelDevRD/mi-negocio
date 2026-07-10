import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/export_dao.dart';
import '../../data/services/export_file_service.dart';
import '../../domain/entities/export_models.dart';

final exportDaoProvider = Provider<ExportDao>((ref) {
  return ExportDao(ref.watch(appDatabaseProvider));
});

final exportFileServiceProvider = Provider<ExportFileService>((ref) {
  return ExportFileService(ref.watch(exportDaoProvider));
});

/// Reporte seleccionado en la pantalla de exportaciones (RF-EXP-02).
final tipoReporteProvider =
    NotifierProvider<TipoReporteController, TipoReporte>(
      TipoReporteController.new,
    );

class TipoReporteController extends Notifier<TipoReporte> {
  @override
  TipoReporte build() => TipoReporte.ventas;

  void seleccionar(TipoReporte tipo) => state = tipo;
}

/// Formato de salida seleccionado (RF-EXP-01).
final formatoExportProvider =
    NotifierProvider<FormatoExportController, FormatoExport>(
      FormatoExportController.new,
    );

class FormatoExportController extends Notifier<FormatoExport> {
  @override
  FormatoExport build() => FormatoExport.excel;

  void seleccionar(FormatoExport formato) => state = formato;
}

/// Rango de fechas para ventas, compras y empleados/pagos (RF-EXP-02).
/// Por defecto, el mes en curso.
final rangoExportProvider =
    NotifierProvider<RangoExportController, DateTimeRange>(
      RangoExportController.new,
    );

class RangoExportController extends Notifier<DateTimeRange> {
  @override
  DateTimeRange build() {
    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);
    final inicioMesSiguiente = DateTime(ahora.year, ahora.month + 1, 1);
    return DateTimeRange(
      start: inicioMes,
      end: inicioMesSiguiente.subtract(const Duration(seconds: 1)),
    );
  }

  void seleccionar(DateTimeRange rango) => state = rango;
}

/// Mes seleccionado para el resumen mensual (RF-EXP-02).
final mesResumenProvider = NotifierProvider<MesResumenController, DateTime>(
  MesResumenController.new,
);

class MesResumenController extends Notifier<DateTime> {
  @override
  DateTime build() {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, 1);
  }

  void seleccionar(DateTime mes) => state = DateTime(mes.year, mes.month, 1);
}

/// Sesiones de caja cerradas disponibles para el reporte de cierre.
final sesionesCajaCerradasProvider = FutureProvider<List<SesionCajaResumen>>((
  ref,
) {
  return ref.watch(exportDaoProvider).listarSesionesCerradas();
});

/// Sesión de caja seleccionada para el reporte de cierre (RF-EXP-02).
final sesionCajaSeleccionadaProvider =
    NotifierProvider<SesionCajaSeleccionadaController, String?>(
      SesionCajaSeleccionadaController.new,
    );

class SesionCajaSeleccionadaController extends Notifier<String?> {
  @override
  String? build() => null;

  void seleccionar(String? sesionId) => state = sesionId;
}
