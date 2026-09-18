import 'package:app_gestion/core/utils/fechas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('inicioDelDiaLocal', () {
    test('devuelve la medianoche local del mismo día, como instante', () {
      final ahora = DateTime(2026, 3, 15, 23, 30);
      expect(inicioDelDiaLocal(ahora), DateTime(2026, 3, 15).toUtc());
    });

    test('funciona igual si "ahora" llega en UTC', () {
      final ahoraUtc = DateTime(2026, 3, 15, 10).toUtc();
      expect(inicioDelDiaLocal(ahoraUtc), inicioDelDiaLocal(ahoraUtc.toLocal()));
    });
  });

  group('inicioDelMesLocal', () {
    test('devuelve el primer día del mes local, como instante', () {
      final ahora = DateTime(2026, 3, 31, 23, 59);
      expect(inicioDelMesLocal(ahora), DateTime(2026, 3).toUtc());
    });
  });

  group('inicioDelMesSiguienteLocal', () {
    test('devuelve el primer día del siguiente mes local', () {
      final ahora = DateTime(2026, 3, 10);
      expect(inicioDelMesSiguienteLocal(ahora), DateTime(2026, 4).toUtc());
    });

    test('cruza diciembre -> enero del año siguiente', () {
      final ahora = DateTime(2026, 12, 20);
      expect(
        inicioDelMesSiguienteLocal(ahora),
        DateTime(2027, 1).toUtc(),
      );
    });
  });
}
