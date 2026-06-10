import 'package:app_gestion/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('aritmética en centavos sin punto flotante', () {
      const a = Money(125050); // RD$ 1,250.50
      const b = Money(74950); // RD$ 749.50

      expect((a + b).cents, 200000);
      expect((a - b).cents, 50100);
      expect((b * 3).cents, 224850);
      expect((-b).cents, -74950);
    });

    test('parse desde texto del usuario', () {
      expect(Money.parse('1250.50').cents, 125050);
      expect(Money.parse('1,250.50').cents, 125050);
      expect(Money.parse('0.01').cents, 1);
      expect(Money.parse('100').cents, 10000);
    });

    test('fromPesos redondea al centavo', () {
      expect(Money.fromPesos(10.999).cents, 1100);
      expect(Money.fromPesos(0.005).cents, 1);
    });

    test('formato RD\$', () {
      expect(const Money(125000).format(), 'RD\$ 1,250.00');
      expect(const Money(5).format(), 'RD\$ 0.05');
      expect(const Money(-150075).format(), 'RD\$ -1,500.75');
      expect(const Money(125000).format(symbol: false), '1,250.00');
    });

    test('comparación e igualdad', () {
      expect(const Money(100) > const Money(99), isTrue);
      expect(const Money(100), const Money(100));
      expect(Money.zero.isZero, isTrue);
      expect(const Money(-1).isNegative, isTrue);
    });
  });
}
