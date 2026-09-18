import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/core/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'monto grande en contenedor angosto con textScaler alto no produce '
    'overflow ni elipsis',
    (tester) async {
      // RD$ 1,250,000.00
      const monto = Money(125000000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0),
              ),
              child: const Center(
                child: SizedBox(width: 80, child: MoneyText(monto)),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);

      final texto = tester.widget<Text>(find.byType(Text));
      expect(texto.data, 'RD\$ 1,250,000.00');
      expect(texto.data, isNot(contains('…')));
      expect(texto.overflow, isNot(TextOverflow.ellipsis));
      expect(find.byType(FittedBox), findsOneWidget);
    },
  );

  testWidgets('sin textAlign se alinea al INICIO, no al centro', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            child: MoneyText(Money(50000)),
          ),
        ),
      ),
    );
    await tester.pump();

    final fittedBox = tester.widget<FittedBox>(find.byType(FittedBox));
    expect(fittedBox.alignment, Alignment.centerLeft);
  });
}
