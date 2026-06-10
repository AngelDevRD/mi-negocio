import 'package:app_gestion/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la app monta y muestra la pantalla placeholder', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AppGestion()));
    await tester.pumpAndSettle();

    expect(find.text('App Gestión Negocios'), findsOneWidget);
  });
}
