import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'AppSnackbar.error reemplaza el snackbar anterior en vez de encolarlo',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AppSnackbar.info(context, 'primero');
                  AppSnackbar.error(context, 'segundo');
                },
                child: const Text('disparar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('disparar'));
      await tester.pump();

      // Si encolara, "primero" seguiría esperando su turno. Solo debe
      // quedar el snackbar más reciente.
      expect(find.text('primero'), findsNothing);
      expect(find.text('segundo'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );
}
