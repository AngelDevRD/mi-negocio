import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/export_models.dart';
import '../datasources/export_dao.dart';
import 'builders/cierre_caja_export_builder.dart';
import 'builders/compras_export_builder.dart';
import 'builders/empleados_export_builder.dart';
import 'builders/inventario_export_builder.dart';
import 'builders/resumen_mensual_export_builder.dart';
import 'builders/ventas_export_builder.dart';

/// Genera los archivos de exportación (RF-EXP-01/02) y los comparte
/// mediante [Share.shareXFiles] (RF-EXP-03).
class ExportFileService {
  ExportFileService(this._dao);

  final ExportDao _dao;

  static final DateFormat _marcaTiempo = DateFormat('yyyyMMdd_HHmmss');

  Future<XFile> generarVentas({
    required DateTime desde,
    required DateTime hasta,
    required FormatoExport formato,
  }) async {
    final ventas = await _dao.obtenerVentas(desde: desde, hasta: hasta);
    final bytes = switch (formato) {
      FormatoExport.excel => VentasExportBuilder.excel(ventas),
      FormatoExport.csv => VentasExportBuilder.csv(ventas),
      FormatoExport.pdf => await VentasExportBuilder.pdf(ventas, desde, hasta),
    };
    return _escribirArchivo(bytes, 'ventas', formato);
  }

  Future<XFile> generarCompras({
    required DateTime desde,
    required DateTime hasta,
    required FormatoExport formato,
  }) async {
    final compras = await _dao.obtenerCompras(desde: desde, hasta: hasta);
    final bytes = switch (formato) {
      FormatoExport.excel => ComprasExportBuilder.excel(compras),
      FormatoExport.csv => ComprasExportBuilder.csv(compras),
      FormatoExport.pdf => await ComprasExportBuilder.pdf(
        compras,
        desde,
        hasta,
      ),
    };
    return _escribirArchivo(bytes, 'compras', formato);
  }

  Future<XFile> generarInventario(FormatoExport formato) async {
    final productos = await _dao.obtenerInventarioValorizado();
    final bytes = switch (formato) {
      FormatoExport.excel => InventarioExportBuilder.excel(productos),
      FormatoExport.csv => InventarioExportBuilder.csv(productos),
      FormatoExport.pdf => await InventarioExportBuilder.pdf(productos),
    };
    return _escribirArchivo(bytes, 'inventario', formato);
  }

  Future<XFile> generarEmpleadosPagos({
    required DateTime desde,
    required DateTime hasta,
    required FormatoExport formato,
  }) async {
    final empleados = await _dao.obtenerEmpleadosPagos(
      desde: desde,
      hasta: hasta,
    );
    final bytes = switch (formato) {
      FormatoExport.excel => EmpleadosExportBuilder.excel(empleados),
      FormatoExport.csv => EmpleadosExportBuilder.csv(empleados),
      FormatoExport.pdf => await EmpleadosExportBuilder.pdf(
        empleados,
        desde,
        hasta,
      ),
    };
    return _escribirArchivo(bytes, 'empleados_pagos', formato);
  }

  Future<XFile> generarCierreCaja({
    required String sesionId,
    required FormatoExport formato,
  }) async {
    final cierre = await _dao.obtenerCierreCaja(sesionId);
    final bytes = switch (formato) {
      FormatoExport.excel => CierreCajaExportBuilder.excel(cierre),
      FormatoExport.csv => CierreCajaExportBuilder.csv(cierre),
      FormatoExport.pdf => await CierreCajaExportBuilder.pdf(cierre),
    };
    return _escribirArchivo(bytes, 'cierre_caja', formato);
  }

  /// Resumen mensual: solo PDF, con logo y datos del negocio (RF-EXP-02).
  Future<XFile> generarResumenMensual(DateTime mes) async {
    final resumen = await _dao.obtenerResumenMensual(mes);
    final bytes = await ResumenMensualExportBuilder.pdf(resumen);
    return _escribirArchivo(bytes, 'resumen_mensual', FormatoExport.pdf);
  }

  Future<void> compartir(XFile archivo, {String? subject}) async {
    await Share.shareXFiles([archivo], subject: subject);
  }

  Future<XFile> _escribirArchivo(
    List<int> bytes,
    String nombreBase,
    FormatoExport formato,
  ) async {
    final extension = switch (formato) {
      FormatoExport.excel => 'xlsx',
      FormatoExport.csv => 'csv',
      FormatoExport.pdf => 'pdf',
    };
    final mimeType = switch (formato) {
      FormatoExport.excel =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      FormatoExport.csv => 'text/csv',
      FormatoExport.pdf => 'application/pdf',
    };
    final directorio = await getTemporaryDirectory();
    final nombre =
        '${nombreBase}_${_marcaTiempo.format(DateTime.now())}'
        '.$extension';
    final archivo = File('${directorio.path}/$nombre');
    await archivo.writeAsBytes(bytes, flush: true);
    return XFile(archivo.path, mimeType: mimeType, name: nombre);
  }
}
