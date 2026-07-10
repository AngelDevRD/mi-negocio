import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/export_models.dart';
import '../export_pdf_theme.dart';

/// Genera el reporte de ventas por rango con líneas (RF-EXP-02).
class VentasExportBuilder {
  const VentasExportBuilder._();

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy HH:mm');

  static const _encabezados = [
    'Fecha',
    'Venta',
    'Tipo',
    'Usuario',
    'Estado',
    'Producto',
    'Cantidad',
    'Precio unitario',
    'Costo unitario',
    'Subtotal',
    'Total venta',
    'Ganancia venta',
  ];

  static List<List<dynamic>> _filas(List<VentaExportRow> ventas) {
    final filas = <List<dynamic>>[];
    for (final venta in ventas) {
      if (venta.items.isEmpty) {
        filas.add([
          _fecha.format(venta.fecha.toLocal()),
          venta.id,
          venta.tipo,
          venta.usuario,
          venta.estado,
          '',
          '',
          '',
          '',
          '',
          venta.total.format(symbol: false),
          venta.ganancia.format(symbol: false),
        ]);
        continue;
      }
      for (final item in venta.items) {
        final subtotal = item.precioUnitario * item.cantidad.round();
        filas.add([
          _fecha.format(venta.fecha.toLocal()),
          venta.id,
          venta.tipo,
          venta.usuario,
          venta.estado,
          item.producto,
          item.cantidad,
          item.precioUnitario.format(symbol: false),
          item.costoUnitario.format(symbol: false),
          subtotal.format(symbol: false),
          venta.total.format(symbol: false),
          venta.ganancia.format(symbol: false),
        ]);
      }
    }
    return filas;
  }

  static List<int> excel(List<VentaExportRow> ventas) {
    final libro = xls.Excel.createExcel();
    final nombreHoja = libro.getDefaultSheet()!;
    libro.rename(nombreHoja, 'Ventas');
    final hoja = libro['Ventas'];

    hoja.appendRow(_encabezados.map((e) => xls.TextCellValue(e)).toList());
    for (final fila in _filas(ventas)) {
      hoja.appendRow(
        fila.map((valor) => xls.TextCellValue(valor.toString())).toList(),
      );
    }
    return libro.encode()!;
  }

  static List<int> csv(List<VentaExportRow> ventas) {
    final filas = [_encabezados, ..._filas(ventas)];
    final texto = const ListToCsvConverter().convert(filas);
    return [0xEF, 0xBB, 0xBF, ...utf8.encode(texto)];
  }

  static Future<List<int>> pdf(
    List<VentaExportRow> ventas,
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
              'Reporte de ventas: ${df.format(desde)} - ${df.format(hasta)}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (ventas.isEmpty)
            pw.Text('No hay ventas en el rango seleccionado.')
          else
            pw.TableHelper.fromTextArray(
              headers: _encabezados,
              data: _filas(
                ventas,
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
