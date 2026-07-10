import 'package:app_gestion/app.dart';
import 'package:app_gestion/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sin licencia, la app arranca en la pantalla de activación', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final db = AppDatabase.forTesting(NativeDatabase.memory());
            ref.onDispose(db.close);
            return db;
          }),
        ],
        child: const AppGestion(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App Gestión Negocios'), findsOneWidget);
    expect(find.text('Comenzar prueba gratis'), findsOneWidget);
  });

  testWidgets(
    'activar la demo sin negocio registrado lleva a la configuración inicial',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              final db = AppDatabase.forTesting(NativeDatabase.memory());
              ref.onDispose(db.close);
              return db;
            }),
          ],
          child: const AppGestion(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Comenzar prueba gratis'));
      await tester.pumpAndSettle();

      expect(find.text('Configuración inicial'), findsOneWidget);
    },
  );
}
