import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/export_models.dart';
import '../export_pdf_theme.dart';

/// Genera el reporte de empleados y sus pagos por rango (RF-EXP-02).
class EmpleadosExportBuilder {
  const EmpleadosExportBuilder._();

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  static const _encabezados = [
    'Empleado',
    'Tipo',
    'Cédula',
    'Fecha ingreso',
    'Activo',
    'Total pagado',
    'Fecha pago',
    'Monto pago',
    'Periodo',
  ];

  static List<List<dynamic>> _filas(List<EmpleadoExportRow> empleados) {
    final filas = <List<dynamic>>[];
    for (final empleado in empleados) {
      if (empleado.pagos.isEmpty) {
        filas.add([
          empleado.nombre,
          empleado.tipo,
          empleado.cedula ?? '',
          _fecha.format(empleado.fechaIngreso.toLocal()),
          empleado.activo ? 'Sí' : 'No',
          empleado.totalPagado.format(symbol: false),
          '',
          '',
          '',
        ]);
        continue;
      }
      for (final pago in empleado.pagos) {
        filas.add([
          empleado.nombre,
          empleado.tipo,
          empleado.cedula ?? '',
          _fecha.format(empleado.fechaIngreso.toLocal()),
          empleado.activo ? 'Sí' : 'No',
          empleado.totalPagado.format(symbol: false),
          _fecha.format(pago.fecha.toLocal()),
          pago.monto.format(symbol: false),
          pago.periodo ?? '',
        ]);
      }
    }
    return filas;
  }

  static List<int> excel(List<EmpleadoExportRow> empleados) {
    final libro = xls.Excel.createExcel();
    final nombreHoja = libro.getDefaultSheet()!;
    libro.rename(nombreHoja, 'Empleados');
    final hoja = libro['Empleados'];

    hoja.appendRow(_encabezados.map((e) => xls.TextCellValue(e)).toList());
    for (final fila in _filas(empleados)) {
      hoja.appendRow(
        fila.map((valor) => xls.TextCellValue(valor.toString())).toList(),
      );
    }
    return libro.encode()!;
  }

  static List<int> csv(List<EmpleadoExportRow> empleados) {
    final filas = [_encabezados, ..._filas(empleados)];
    final texto = const ListToCsvConverter().convert(filas);
    return [0xEF, 0xBB, 0xBF, ...utf8.encode(texto)];
  }

  static Future<List<int>> pdf(
    List<EmpleadoExportRow> empleados,
    DateTime desde,
    DateTime hasta,
  ) async {
    final doc = pw.Document();
    final df = DateFormat('dd/MM/yyyy');
    doc.addPage(
      pw.MultiPage(
        theme: await exportPdfTheme(),
        build: (context) => [
          pw.Header(
            child: pw.Text(
              'Reporte de empleados y pagos: '
              '${df.format(desde)} - ${df.format(hasta)}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (empleados.isEmpty)
            pw.Text('No hay empleados registrados.')
          else
            pw.TableHelper.fromTextArray(
              headers: _encabezados,
              data: _filas(
                empleados,
              ).map((fila) => fila.map((c) => c.toString()).toList()).toList(),
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerStyle: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
              ),
              cellAlignment: pw.Alignment.centerLeft,
            ),
        ],
      ),
    );
    return doc.save();
  }
}
