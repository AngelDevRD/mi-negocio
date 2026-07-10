import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as xls;

/// Una hoja de cálculo ya leída: encabezados (primera fila) y filas de
/// datos (resto, sin filas completamente vacías).
class HojaImportada {
  const HojaImportada({
    required this.nombre,
    required this.encabezados,
    required this.filas,
  });

  final String nombre;
  final List<String> encabezados;

  /// Cada fila tiene exactamente `encabezados.length` celdas (rellenas con
  /// `''` si la fila original era más corta).
  final List<List<String>> filas;
}

/// Lee un archivo Excel (.xlsx/.xls) en memoria y devuelve sus hojas con
/// encabezados y datos como texto plano (FASE 20, RF-IMP-01).
abstract final class ExcelImportReader {
  static List<HojaImportada> leer(List<int> bytes) {
    final libro = xls.Excel.decodeBytes(_normalizarRelaciones(bytes));
    final hojas = <HojaImportada>[];

    for (final entry in libro.tables.entries) {
      final filasCrudas = entry.value.rows;
      if (filasCrudas.isEmpty) continue;

      final encabezados = filasCrudas.first
          .map((celda) => celda?.value?.toString().trim() ?? '')
          .toList();
      if (encabezados.every((e) => e.isEmpty)) continue;

      final filas = <List<String>>[];
      for (final filaCruda in filasCrudas.skip(1)) {
        final valores = List<String>.generate(encabezados.length, (i) {
          if (i >= filaCruda.length) return '';
          return filaCruda[i]?.value?.toString().trim() ?? '';
        });
        if (valores.every((v) => v.isEmpty)) continue;
        filas.add(valores);
      }
      if (filas.isEmpty) continue;

      hojas.add(
        HojaImportada(
          nombre: entry.key,
          encabezados: encabezados,
          filas: filas,
        ),
      );
    }

    return hojas;
  }

  /// Algunos generadores (p. ej. openpyxl) escriben rutas absolutas
  /// (`Target="/xl/worksheets/sheet1.xml"`) en `xl/_rels/workbook.xml.rels`.
  /// El paquete `excel` las resuelve como `xl/$target` sin tener en cuenta
  /// la barra inicial, busca `xl//xl/worksheets/sheet1.xml` (no existe) y
  /// lanza un null-check error. Se normalizan a rutas relativas antes de
  /// decodificar.
  static List<int> _normalizarRelaciones(List<int> bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object {
      return bytes;
    }

    final rels = archive.findFile('xl/_rels/workbook.xml.rels');
    if (rels == null) return bytes;

    final contenido = utf8.decode(rels.content as List<int>);
    if (!contenido.contains('Target="/xl/')) return bytes;

    final corregido = contenido.replaceAll('Target="/xl/', 'Target="');
    final bytesCorregidos = utf8.encode(corregido);
    archive.addFile(
      ArchiveFile(
        'xl/_rels/workbook.xml.rels',
        bytesCorregidos.length,
        bytesCorregidos,
      ),
    );

    return ZipEncoder().encode(archive) ?? bytes;
  }
}
