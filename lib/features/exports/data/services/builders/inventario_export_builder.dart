import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../core/utils/money.dart';
import '../../../domain/entities/export_models.dart';
import '../export_pdf_theme.dart';

/// Genera el reporte de inventario valorizado (RF-EXP-02/RF-ANL-02).
class InventarioExportBuilder {
  const InventarioExportBuilder._();

  static const _encabezados = [
    'Producto',
    'Categoría',
    'Unidad',
    'Stock actual',
    'Precio compra',
    'Precio venta',
    'Valor a costo',
    'Valor a venta',
  ];

  static List<List<dynamic>> _filas(List<InventarioExportRow> productos) {
    return productos
        .map(
          (p) => [
            p.nombre,
            p.categoria,
            p.unidad,
            p.stockActual,
            p.precioCompra.format(symbol: false),
            p.precioVenta.format(symbol: false),
            p.valorCosto.format(symbol: false),
            p.valorVenta.format(symbol: false),
          ],
        )
        .toList();
  }

  static List<int> excel(List<InventarioExportRow> productos) {
    final libro = xls.Excel.createExcel();
    final nombreHoja = libro.getDefaultSheet()!;
    libro.rename(nombreHoja, 'Inventario');
    final hoja = libro['Inventario'];

    hoja.appendRow(_encabezados.map((e) => xls.TextCellValue(e)).toList());
    for (final fila in _filas(productos)) {
      hoja.appendRow(
        fila.map((valor) => xls.TextCellValue(valor.toString())).toList(),
      );
    }
    return libro.encode()!;
  }

  static List<int> csv(List<InventarioExportRow> productos) {
    final filas = [_encabezados, ..._filas(productos)];
    final texto = const ListToCsvConverter().convert(filas);
    return [0xEF, 0xBB, 0xBF, ...utf8.encode(texto)];
  }

  static Future<List<int>> pdf(List<InventarioExportRow> productos) async {
    final doc = pw.Document();
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final totalCosto = productos.fold(
      Money.zero,
      (acc, p) => acc + p.valorCosto,
    );
    final totalVenta = productos.fold(
      Money.zero,
      (acc, p) => acc + p.valorVenta,
    );
    doc.addPage(
      pw.MultiPage(
        theme: await exportPdfTheme(),
        build: (context) => [
          pw.Header(
            child: pw.Text(
              'Inventario valorizado: ${df.format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (productos.isEmpty)
            pw.Text('No hay productos registrados.')
          else ...[
            pw.TableHelper.fromTextArray(
              headers: _encabezados,
              data: _filas(
                productos,
              ).map((fila) => fila.map((c) => c.toString()).toList()).toList(),
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerStyle: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
              ),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Valor total a costo: ${totalCosto.format()}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Valor total a venta: ${totalVenta.format()}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ],
      ),
    );
    return doc.save();
  }
}
