import 'package:intl/intl.dart';

/// Monto monetario almacenado en centavos (DOP).
///
/// Regla RNF-07: prohibido punto flotante en montos. Toda cifra de dinero
/// del sistema viaja como [Money] (o `int` centavos en la base de datos).
class Money implements Comparable<Money> {
  const Money(this.cents);

  /// Crea desde un valor decimal escrito por el usuario (ej. "1250.50").
  /// Redondea al centavo más cercano.
  factory Money.parse(String input) {
    final normalized = input.replaceAll(',', '').trim();
    final value = double.parse(normalized);
    return Money((value * 100).round());
  }

  factory Money.fromPesos(num pesos) => Money((pesos * 100).round());

  static const Money zero = Money(0);

  /// Centavos (puede ser negativo: faltantes de caja, reversas).
  final int cents;

  bool get isNegative => cents < 0;
  bool get isZero => cents == 0;

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator *(int factor) => Money(cents * factor);
  Money operator -() => Money(-cents);
  bool operator >(Money other) => cents > other.cents;
  bool operator >=(Money other) => cents >= other.cents;
  bool operator <(Money other) => cents < other.cents;
  bool operator <=(Money other) => cents <= other.cents;

  static final NumberFormat _formatter = NumberFormat('#,##0.00', 'en_US');

  /// Formato de presentación: `RD$ 1,250.00`.
  String format({bool symbol = true}) {
    final text = _formatter.format(cents / 100);
    return symbol ? 'RD\$ $text' : text;
  }

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => format();
}
