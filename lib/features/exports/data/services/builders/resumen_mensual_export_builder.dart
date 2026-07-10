import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../domain/entities/export_models.dart';
import '../export_pdf_theme.dart';

/// Genera el resumen mensual (mini estado de resultados) en PDF, con el
/// logo y los datos del negocio en el encabezado (RF-EXP-02).
///
/// A diferencia de los demás reportes, este solo se exporta en PDF: es un
/// documento de presentación, no una tabla de datos para reanalizar.
class ResumenMensualExportBuilder {
  const ResumenMensualExportBuilder._();

  static Future<List<int>> pdf(ResumenMensualExportRow resumen) async {
    final mesFormato = DateFormat('MMMM yyyy', 'es');
    final doc = pw.Document();

    pw.ImageProvider? logo;
    final logoPath = resumen.logoPath;
    if (logoPath != null && logoPath.isNotEmpty) {
      final archivo = File(logoPath);
      if (await archivo.exists()) {
        logo = pw.MemoryImage(await archivo.readAsBytes());
      }
    }

    doc.addPage(
      pw.MultiPage(
        theme: await exportPdfTheme(),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                pw.Image(logo, width: 60, height: 60),
                pw.SizedBox(width: 12),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      resumen.negocioNombre,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (resumen.negocioIdentificacion != null)
                      pw.Text('RNC/Cédula: ${resumen.negocioIdentificacion}'),
                    if (resumen.negocioDireccion != null)
                      pw.Text(resumen.negocioDireccion!),
                    if (resumen.negocioTelefono != null)
                      pw.Text('Tel: ${resumen.negocioTelefono}'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Header(
            child: pw.Text(
              'Resumen mensual: '
              '${mesFormato.format(resumen.mes.toLocal())}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.TableHelper.fromTextArray(
            headers: const ['Concepto', 'Monto'],
            data: [
              ['Ventas', resumen.ventas.format()],
              ['Compras', resumen.compras.format()],
              ['Gastos', resumen.gastos.format()],
              ['Sueldos y pagos a empleados', resumen.sueldos.format()],
              ['Ganancia neta del mes', resumen.ganancia.format()],
            ],
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {1: pw.Alignment.centerRight},
          ),
        ],
      ),
    );
    return doc.save();
  }
}
