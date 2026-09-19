import 'package:app_gestion/core/utils/fechas.dart';
import 'package:app_gestion/core/utils/rango_fecha.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Miércoles 17 de septiembre de 2025 a mediodía LOCAL.
  final ahora = DateTime(2025, 9, 17, 12);

  group('inicioDeLaSemanaLocal', () {
    test('la semana empieza el lunes', () {
      expect(inicioDeLaSemanaLocal(ahora).toLocal(), DateTime(2025, 9, 15));
    });

    test('un lunes es el inicio de su propia semana', () {
      expect(
        inicioDeLaSemanaLocal(DateTime(2025, 9, 15, 9)).toLocal(),
        DateTime(2025, 9, 15),
      );
    });

    test('un domingo pertenece a la semana que empezó el lunes anterior', () {
      expect(
        inicioDeLaSemanaLocal(DateTime(2025, 9, 21, 23)).toLocal(),
        DateTime(2025, 9, 15),
      );
    });

    test('cruza el cambio de mes', () {
      // Jueves 2 de octubre de 2025 -> lunes 29 de septiembre.
      expect(
        inicioDeLaSemanaLocal(DateTime(2025, 10, 2, 8)).toLocal(),
        DateTime(2025, 9, 29),
      );
    });
  });

  group('etiquetaDeDia', () {
    test('"Hoy", "Ayer" y la fecha', () {
      expect(etiquetaDeDia(DateTime(2025, 9, 17, 0, 5), ahora), 'Hoy');
      expect(etiquetaDeDia(DateTime(2025, 9, 16, 23, 59), ahora), 'Ayer');
      expect(etiquetaDeDia(DateTime(2025, 9, 15, 10), ahora), '15/09/2025');
    });

    test('compara en el calendario LOCAL aunque llegue en UTC', () {
      final utc = DateTime(2025, 9, 17, 9).toUtc();
      expect(etiquetaDeDia(utc, ahora), 'Hoy');
    });
  });

  group('agruparPorDia', () {
    test('agrupa por día local sin reordenar', () {
      final elementos = [
        DateTime(2025, 9, 17, 15),
        DateTime(2025, 9, 17, 9),
        DateTime(2025, 9, 16, 20),
        DateTime(2025, 9, 10, 8),
      ];

      final grupos = agruparPorDia<DateTime>(elementos, (d) => d, ahora);

      expect(grupos.map((g) => g.etiqueta), ['Hoy', 'Ayer', '10/09/2025']);
      expect(grupos.map((g) => g.elementos.length), [2, 1, 1]);
      expect(grupos.first.elementos.first, DateTime(2025, 9, 17, 15));
    });

    test('una lista vacía no produce grupos', () {
      expect(agruparPorDia<DateTime>([], (d) => d, ahora), isEmpty);
    });
  });

  group('nombreDelMes', () {
    test('en español, sin depender del Intl', () {
      expect(nombreDelMes(DateTime(2025, 9, 1)), 'Septiembre 2025');
      expect(nombreDelMes(DateTime(2026, 1, 20)), 'Enero 2026');
    });
  });

  group('limitesDeRango', () {
    test('todo: sin límites', () {
      final l = limitesDeRango(RangoFecha.todo, ahora);
      expect(l.desde, isNull);
      expect(l.hasta, isNull);
    });

    test('hoy: del inicio del día al último milisegundo del día local', () {
      final l = limitesDeRango(RangoFecha.hoy, ahora);
      expect(l.desde!.toLocal(), DateTime(2025, 9, 17));
      expect(
        l.hasta!.toLocal(),
        DateTime(2025, 9, 18).subtract(const Duration(milliseconds: 1)),
      );
    });

    test('semana: de lunes a domingo', () {
      final l = limitesDeRango(RangoFecha.semana, ahora);
      expect(l.desde!.toLocal(), DateTime(2025, 9, 15));
      expect(
        l.hasta!.toLocal(),
        DateTime(2025, 9, 22).subtract(const Duration(milliseconds: 1)),
      );
    });

    test('mes: del día 1 al último día del mes local', () {
      final l = limitesDeRango(RangoFecha.mes, ahora);
      expect(l.desde!.toLocal(), DateTime(2025, 9));
      expect(
        l.hasta!.toLocal(),
        DateTime(2025, 10).subtract(const Duration(milliseconds: 1)),
      );
    });

    test('personalizado: devuelve los límites recibidos', () {
      final desde = DateTime.utc(2025, 1, 1);
      final hasta = DateTime.utc(2025, 1, 31);
      final l = limitesDeRango(
        RangoFecha.personalizado,
        ahora,
        desde: desde,
        hasta: hasta,
      );
      expect(l.desde, desde);
      expect(l.hasta, hasta);
    });
  });

  test('limitesDeDias incluye el último día completo', () {
    final l = limitesDeDias(DateTime(2025, 9, 10), DateTime(2025, 9, 12));
    expect(l.desde.toLocal(), DateTime(2025, 9, 10));
    expect(
      l.hasta.toLocal(),
      DateTime(2025, 9, 13).subtract(const Duration(milliseconds: 1)),
    );
  });
}
