import 'package:app_gestion/features/cash_register/presentation/providers/cash_register_providers.dart';
import 'package:app_gestion/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'RF-GAS-01: "1.2.3" en monto muestra "Monto inválido" en vez de lanzar',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Evita depender del stream de caja respaldado por drift (ver
            // cash_register_close_screen_test.dart: un stream real dentro de
            // un widget test deja un Timer pendiente ajeno al bug probado).
            sesionActualProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: ExpenseFormScreen()),
        ),
      );
      await tester.pump();

      // Orden de campos: Concepto, Monto (la categoría es un dropdown).
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Factura de luz');
      await tester.enterText(campos.at(1), '1.2.3');

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pump();

      expect(find.text('Monto inválido'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
