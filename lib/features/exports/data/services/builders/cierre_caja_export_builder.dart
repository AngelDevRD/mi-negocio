import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/export_models.dart';
import '../export_pdf_theme.dart';

/// Genera el reporte de cierre de una sesión de caja (RF-EXP-02).
class CierreCajaExportBuilder {
  const CierreCajaExportBuilder._();

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy HH:mm');

  static const _encabezadosResumen = ['Campo', 'Valor'];
  static const _encabezadosMovimientos = ['Fecha', 'Tipo', 'Monto', 'Motivo'];

  static List<List<dynamic>> _filasResumen(CierreCajaExportRow cierre) {
    return [
      ['Apertura', _fecha.format(cierre.fechaApertura.toLocal())],
      [
        'Cierre',
        cierre.fechaCierre == null
            ? ''
            : _fecha.format(cierre.fechaCierre!.toLocal()),
      ],
      ['Usuario apertura', cierre.usuarioApertura],
      ['Usuario cierre', cierre.usuarioCierre ?? ''],
      ['Monto apertura', cierre.montoApertura.format(symbol: false)],
      ['Monto esperado', cierre.montoEsperado?.format(symbol: false) ?? ''],
      ['Monto contado', cierre.montoContado?.format(symbol: false) ?? ''],
      ['Diferencia', cierre.diferencia?.format(symbol: false) ?? ''],
      [
        'Monto dejado para siguiente turno',
        cierre.montoDejadoSiguiente?.format(symbol: false) ?? '',
      ],
    ];
  }

  static List<List<dynamic>> _filasMovimientos(CierreCajaExportRow cierre) {
    return cierre.movimientos
        .map(
          (m) => [
            _fecha.format(m.fecha.toLocal()),
            m.tipo,
            m.monto.format(symbol: false),
            m.motivo ?? '',
          ],
        )
        .toList();
  }

  static List<int> excel(CierreCajaExportRow cierre) {
    final libro = xls.Excel.createExcel();
    final nombreHoja = libro.getDefaultSheet()!;
    libro.rename(nombreHoja, 'Cierre de caja');
    final hoja = libro['Cierre de caja'];

    hoja.appendRow(
      _encabezadosResumen.map((e) => xls.TextCellValue(e)).toList(),
    );
    for (final fila in _filasResumen(cierre)) {
      hoja.appendRow(
        fila.map((valor) => xls.TextCellValue(valor.toString())).toList(),
      );
    }

    hoja.appendRow([xls.TextCellValue('')]);
    hoja.appendRow(
      _encabezadosMovimientos.map((e) => xls.TextCellValue(e)).toList(),
    );
    for (final fila in _filasMovimientos(cierre)) {
      hoja.appendRow(
        fila.map((valor) => xls.TextCellValue(valor.toString())).toList(),
      );
    }
    return libro.encode()!;
  }

  static List<int> csv(CierreCajaExportRow cierre) {
    final filas = [
      _encabezadosResumen,
      ..._filasResumen(cierre),
      [],
      _encabezadosMovimientos,
      ..._filasMovimientos(cierre),
    ];
    final texto = const ListToCsvConverter().convert(filas);
    return [0xEF, 0xBB, 0xBF, ...utf8.encode(texto)];
  }

  static Future<List<int>> pdf(CierreCajaExportRow cierre) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        theme: await exportPdfTheme(),
        build: (context) => [
          pw.Header(
            child: pw.Text(
              'Cierre de caja: ${_fecha.format(cierre.fechaApertura.toLocal())}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.TableHelper.fromTextArray(
            headers: _encabezadosResumen,
            data: _filasResumen(
              cierre,
            ).map((fila) => fila.map((c) => c.toString()).toList()).toList(),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Movimientos de la sesión',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          if (cierre.movimientos.isEmpty)
            pw.Text('No hay movimientos registrados.')
          else
            pw.TableHelper.fromTextArray(
              headers: _encabezadosMovimientos,
              data: _filasMovimientos(
                cierre,
              ).map((fila) => fila.map((c) => c.toString()).toList()).toList(),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerStyle: pw.TextStyle(
                fontSize: 8,
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
