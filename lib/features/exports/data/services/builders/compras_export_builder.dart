import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/export_models.dart';
import '../export_pdf_theme.dart';

/// Genera el reporte de compras por rango con líneas (RF-EXP-02).
class ComprasExportBuilder {
  const ComprasExportBuilder._();

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy HH:mm');

  static const _encabezados = [
    'Fecha',
    'Compra',
    'Proveedor',
    'Factura',
    'Usuario',
    'Estado',
    'Producto',
    'Cantidad',
    'Costo unitario',
    'Subtotal',
    'Total compra',
  ];

  static List<List<dynamic>> _filas(List<CompraExportRow> compras) {
    final filas = <List<dynamic>>[];
    for (final compra in compras) {
      if (compra.items.isEmpty) {
        filas.add([
          _fecha.format(compra.fecha.toLocal()),
          compra.id,
          compra.proveedor ?? '',
          compra.numeroFactura ?? '',
          compra.usuario,
          compra.estado,
          '',
          '',
          '',
          '',
          compra.total.format(symbol: false),
        ]);
        continue;
      }
      for (final item in compra.items) {
        final subtotal = item.costoUnitario * item.cantidad.round();
        filas.add([
          _fecha.format(compra.fecha.toLocal()),
          compra.id,
          compra.proveedor ?? '',
          compra.numeroFactura ?? '',
          compra.usuario,
          compra.estado,
          item.producto,
          item.cantidad,
          item.costoUnitario.format(symbol: false),
          subtotal.format(symbol: false),
          compra.total.format(symbol: false),
        ]);
      }
    }
    return filas;
  }

  static List<int> excel(List<CompraExportRow> compras) {
    final libro = xls.Excel.createExcel();
    final nombreHoja = libro.getDefaultSheet()!;
    libro.rename(nombreHoja, 'Compras');
    final hoja = libro['Compras'];

    hoja.appendRow(_encabezados.map((e) => xls.TextCellValue(e)).toList());
    for (final fila in _filas(compras)) {
      hoja.appendRow(
        fila.map((valor) => xls.TextCellValue(valor.toString())).toList(),
      );
    }
    return libro.encode()!;
  }

  static List<int> csv(List<CompraExportRow> compras) {
    final filas = [_encabezados, ..._filas(compras)];
    final texto = const ListToCsvConverter().convert(filas);
    return [0xEF, 0xBB, 0xBF, ...utf8.encode(texto)];
  }

  static Future<List<int>> pdf(
    List<CompraExportRow> compras,
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
              'Reporte de compras: ${df.format(desde)} - ${df.format(hasta)}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (compras.isEmpty)
            pw.Text('No hay compras en el rango seleccionado.')
          else
            pw.TableHelper.fromTextArray(
              headers: _encabezados,
              data: _filas(
                compras,
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
