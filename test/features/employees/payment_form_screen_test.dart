import 'package:app_gestion/features/cash_register/presentation/providers/cash_register_providers.dart';
import 'package:app_gestion/features/employees/presentation/providers/employees_providers.dart';
import 'package:app_gestion/features/employees/presentation/screens/payment_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'RF-EMP-03: "1.2.3" en monto muestra "Monto inválido" en vez de lanzar',
    (tester) async {
      const employeeId = 'empleado-1';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Sin empleado real: solo interesa el validator del monto, no
            // el precargado del salario.
            empleadoProvider(
              employeeId,
            ).overrideWith((ref) async => null),
            // Evita depender del stream de caja respaldado por drift (ver
            // cash_register_close_screen_test.dart: un stream real dentro de
            // un widget test deja un Timer pendiente ajeno al bug probado).
            sesionActualProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            home: PaymentFormScreen(employeeId: employeeId),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, '1.2.3');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pump();

      expect(find.text('Monto inválido'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
