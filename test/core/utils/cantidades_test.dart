import 'package:app_gestion/core/utils/cantidades.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatoCantidadUnidad', () {
    test('1 unidad en singular', () {
      expect(formatoCantidadUnidad(1, 'unidad'), '1 unidad');
    });

    test('2, 34 y 0 unidades en plural', () {
      expect(formatoCantidadUnidad(2, 'unidad'), '2 unidades');
      expect(formatoCantidadUnidad(34, 'unidad'), '34 unidades');
      expect(formatoCantidadUnidad(0, 'unidad'), '0 unidades');
    });

    test('las abreviaturas se dejan tal cual', () {
      expect(formatoCantidadUnidad(8.5, 'lb'), '8.5 lb');
      expect(formatoCantidadUnidad(1, 'lb'), '1 lb');
      expect(formatoCantidadUnidad(2, 'kg'), '2 kg');
    });

    test('cantidad fraccionaria de unidades va en plural', () {
      expect(formatoCantidadUnidad(1.5, 'unidad'), '1.5 unidades');
    });
  });

  group('pluralización de unidades completas', () {
    test('vocal final + s', () {
      expect(formatoCantidadUnidad(8.5, 'libra'), '8.5 libras');
      expect(formatoCantidadUnidad(57, 'libra'), '57 libras');
      expect(formatoCantidadUnidad(3, 'caja'), '3 cajas');
      expect(formatoCantidadUnidad(2, 'litro'), '2 litros');
    });

    test('consonante final + es', () {
      expect(formatoCantidadUnidad(2, 'galon'), '2 galones');
      expect(formatoCantidadUnidad(2, 'galón'), '2 galones');
      expect(formatoCantidadUnidad(5, 'unidad'), '5 unidades');
    });

    test('cantidad 1 va en singular', () {
      expect(formatoCantidadUnidad(1, 'libra'), '1 libra');
      expect(formatoCantidadUnidad(1, 'galon'), '1 galon');
    });

    test('las abreviaturas NO se pluralizan', () {
      for (final abreviatura in ['lb', 'kg', 'g', 'L', 'ml', 'oz', 'u.']) {
        expect(
          formatoCantidadUnidad(3, abreviatura),
          '3 $abreviatura',
          reason: abreviatura,
        );
      }
    });

    test('lo que ya termina en s y las unidades de varias palabras no se '
        'tocan', () {
      expect(pluralUnidad('fundas'), 'fundas');
      expect(pluralUnidad('bolsa grande'), 'bolsa grande');
    });
  });

  group('formatoCantidad', () {
    test('enteros sin decimales y fracciones recortadas', () {
      expect(formatoCantidad(3), '3');
      expect(formatoCantidad(0.5), '0.5');
      expect(formatoCantidad(2.25), '2.25');
    });
  });
}
