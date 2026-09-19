import 'package:csv/csv.dart';

/// Caracteres con los que Excel (y Calc, Sheets) interpretan una celda como
/// FÓRMULA al abrir un CSV (OWASP "CSV Injection"): `=`, `+`, `-`, `@`,
/// tabulador y retorno de carro.
const _iniciosDeFormula = {'=', '+', '-', '@', '\t', '\r'};

/// Neutraliza un TEXTO LIBRE del usuario (nombre de producto, nota, concepto,
/// proveedor, empleado...) para escribirlo en un CSV: si empieza por un
/// carácter de fórmula le antepone un apóstrofo, con lo que la hoja de cálculo
/// lo trata como texto (`=HYPERLINK(...)` deja de ejecutarse).
///
/// Función pura. NO se aplica a números ni a montos: `-50.00` es un monto
/// negativo legítimo y debe seguir siendo un número. Por eso solo se usa sobre
/// campos marcados con [libre].
String celdaSegura(String texto) =>
    texto.isNotEmpty && _iniciosDeFormula.contains(texto[0])
    ? "'$texto"
    : texto;

/// Marca un valor como TEXTO LIBRE del usuario dentro de una fila de reporte.
/// Los demás formatos (Excel con `TextCellValue`, PDF) lo ven como el texto
/// original (`toString`); solo el CSV le aplica [celdaSegura] (ver [csvSeguro]).
class TextoLibre {
  const TextoLibre(this.valor);

  final String valor;

  @override
  String toString() => valor;
}

/// Atajo para marcar un texto libre (`null` = celda vacía).
TextoLibre libre(String? valor) => TextoLibre(valor ?? '');

/// Convierte [filas] a CSV protegiendo cada [TextoLibre] con [celdaSegura];
/// el resto de las celdas (fechas, montos, cantidades, enumeraciones) se
/// escriben tal cual.
String csvSeguro(List<List<dynamic>> filas) {
  final protegidas = [
    for (final fila in filas)
      [
        for (final celda in fila)
          celda is TextoLibre ? celdaSegura(celda.valor) : celda,
      ],
  ];
  return const ListToCsvConverter().convert(protegidas);
}
