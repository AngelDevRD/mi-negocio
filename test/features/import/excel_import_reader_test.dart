import 'dart:convert';

import 'package:app_gestion/features/import/data/services/excel_import_reader.dart';
import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as xls;
import 'package:flutter_test/flutter_test.dart';

List<int> _construirLibro(void Function(xls.Excel libro) build) {
  final libro = xls.Excel.createExcel();
  build(libro);
  return libro.encode()!;
}

/// Simula el formato que produce openpyxl: rutas absolutas
/// (`Target="/xl/worksheets/sheet1.xml"`) en `xl/_rels/workbook.xml.rels`.
List<int> _conTargetsAbsolutos(List<int> bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final rels = archive.findFile('xl/_rels/workbook.xml.rels')!;
  final contenido = utf8
      .decode(rels.content as List<int>)
      .replaceAll('Target="worksheets/', 'Target="/xl/worksheets/');
  final corregido = utf8.encode(contenido);
  archive.addFile(
    ArchiveFile('xl/_rels/workbook.xml.rels', corregido.length, corregido),
  );
  return ZipEncoder().encode(archive)!;
}

void main() {
  test('leer extrae encabezados y filas de una hoja simple', () {
    final bytes = _construirLibro((libro) {
      final nombreHoja = libro.getDefaultSheet()!;
      libro.rename(nombreHoja, 'Productos');
      final hoja = libro['Productos'];
      hoja.appendRow(
        ['Nombre', 'Categoría', 'Precio'].map(xls.TextCellValue.new).toList(),
      );
      hoja.appendRow(
        ['Coca Cola', 'Bebidas', '50'].map(xls.TextCellValue.new).toList(),
      );
      hoja.appendRow(
        ['Pan', 'Panadería', '25'].map(xls.TextCellValue.new).toList(),
      );
    });

    final hojas = ExcelImportReader.leer(bytes);

    expect(hojas, hasLength(1));
    final hoja = hojas.single;
    expect(hoja.nombre, 'Productos');
    expect(hoja.encabezados, ['Nombre', 'Categoría', 'Precio']);
    expect(hoja.filas, [
      ['Coca Cola', 'Bebidas', '50'],
      ['Pan', 'Panadería', '25'],
    ]);
  });

  test('rellena filas más cortas que los encabezados con celdas vacías', () {
    final bytes = _construirLibro((libro) {
      final nombreHoja = libro.getDefaultSheet()!;
      libro.rename(nombreHoja, 'Gastos');
      final hoja = libro['Gastos'];
      hoja.appendRow(
        ['Categoría', 'Concepto', 'Monto'].map(xls.TextCellValue.new).toList(),
      );
      // Fila incompleta: falta la columna "Monto".
      hoja.appendRow(
        ['Luz', 'Factura de luz'].map(xls.TextCellValue.new).toList(),
      );
    });

    final hojas = ExcelImportReader.leer(bytes);

    expect(hojas.single.filas, [
      ['Luz', 'Factura de luz', ''],
    ]);
  });

  test('omite filas completamente vacías', () {
    final bytes = _construirLibro((libro) {
      final nombreHoja = libro.getDefaultSheet()!;
      libro.rename(nombreHoja, 'Empleados');
      final hoja = libro['Empleados'];
      hoja.appendRow(['Nombre', 'Tipo'].map(xls.TextCellValue.new).toList());
      hoja.appendRow(['Juan', 'ventas'].map(xls.TextCellValue.new).toList());
      hoja.appendRow(['', ''].map(xls.TextCellValue.new).toList());
      hoja.appendRow(['Pedro', 'delivery'].map(xls.TextCellValue.new).toList());
    });

    final hojas = ExcelImportReader.leer(bytes);

    expect(hojas.single.filas, [
      ['Juan', 'ventas'],
      ['Pedro', 'delivery'],
    ]);
  });

  test(
    'lee archivos con rutas absolutas en workbook.xml.rels (estilo openpyxl)',
    () {
      final bytes = _conTargetsAbsolutos(
        _construirLibro((libro) {
          final nombreHoja = libro.getDefaultSheet()!;
          libro.rename(nombreHoja, 'Productos');
          final hoja = libro['Productos'];
          hoja.appendRow(
            ['Nombre', 'Precio'].map(xls.TextCellValue.new).toList(),
          );
          hoja.appendRow(['Arroz', '250'].map(xls.TextCellValue.new).toList());
        }),
      );

      final hojas = ExcelImportReader.leer(bytes);

      expect(hojas, hasLength(1));
      expect(hojas.single.encabezados, ['Nombre', 'Precio']);
      expect(hojas.single.filas, [
        ['Arroz', '250'],
      ]);
    },
  );

  test('omite hojas sin encabezados o sin filas de datos', () {
    final bytes = _construirLibro((libro) {
      final nombreHoja = libro.getDefaultSheet()!;
      libro.rename(nombreHoja, 'Vacía');
      // Sin filas en absoluto: hoja vacía.

      final hojaSoloEncabezados = libro['SoloEncabezados'];
      hojaSoloEncabezados.appendRow(
        ['Nombre', 'Categoría'].map(xls.TextCellValue.new).toList(),
      );

      final hojaConDatos = libro['ConDatos'];
      hojaConDatos.appendRow(
        ['Nombre', 'Categoría'].map(xls.TextCellValue.new).toList(),
      );
      hojaConDatos.appendRow(
        ['Arroz', 'Granos'].map(xls.TextCellValue.new).toList(),
      );
    });

    final hojas = ExcelImportReader.leer(bytes);

    expect(hojas, hasLength(1));
    expect(hojas.single.nombre, 'ConDatos');
  });
}
