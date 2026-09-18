import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/sales/presentation/widgets/pos_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resultado devuelto por el diálogo (null = cancelado / aún abierto).
ResultadoCobro? _resultado;

Future<void> _abrir(WidgetTester tester, Money total) async {
  _resultado = null;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async =>
                  _resultado = await showDialog<ResultadoCobro>(
                    context: context,
                    builder: (_) => CobroDialog(total: total),
                  ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

TextEditingController _campo(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!;

Finder get _chips => find.byType(ChoiceChip);

void main() {
  const total260 = Money(26000);

  testWidgets('abre con el total precargado y TODO el texto seleccionado', (
    tester,
  ) async {
    await _abrir(tester, total260);

    final campo = _campo(tester);
    expect(campo.text, '260.00');
    expect(campo.selection.start, 0);
    expect(campo.selection.end, campo.text.length);
  });

  testWidgets('escribir el billete reemplaza el total y muestra el cambio', (
    tester,
  ) async {
    await _abrir(tester, total260);

    await tester.enterText(find.byType(TextField), '500');
    await tester.pump();

    expect(_campo(tester).text, '500');
    expect(find.text('RD\$ 240.00'), findsOneWidget);
  });

  testWidgets('Enter (hecho del teclado) confirma con el monto escrito', (
    tester,
  ) async {
    await _abrir(tester, total260);

    await tester.enterText(find.byType(TextField), '500');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(CobroDialog), findsNothing);
    expect(_resultado?.recibido, const Money(50000));
    expect(_resultado?.metodo, MetodoPago.efectivo);
  });

  testWidgets('Enter con monto insuficiente NO confirma', (tester) async {
    await _abrir(tester, total260);

    await tester.enterText(find.byType(TextField), '100');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(CobroDialog), findsOneWidget);
    expect(find.text('Monto insuficiente'), findsOneWidget);
    expect(_resultado, isNull);
  });

  testWidgets('total 260: chips Exacto, 500, 1000 y 2000; el 500 fija el '
      'monto y muestra el cambio 240', (tester) async {
    await _abrir(tester, total260);

    expect(_chips, findsNWidgets(4));
    for (final texto in ['Exacto', '500', '1000', '2000']) {
      expect(find.widgetWithText(ChoiceChip, texto), findsOneWidget);
    }
    // Billetes menores al total no se ofrecen.
    for (final texto in ['50', '100', '200']) {
      expect(find.widgetWithText(ChoiceChip, texto), findsNothing);
    }

    await tester.tap(find.widgetWithText(ChoiceChip, '500'));
    await tester.pump();

    expect(_campo(tester).text, '500.00');
    expect(find.text('RD\$ 240.00'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(_chips.at(1)).selected, isTrue);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(_resultado?.recibido, const Money(50000));
    expect(_resultado?.metodo, MetodoPago.efectivo);
  });

  testWidgets('"Exacto" vuelve al total (cambio 0)', (tester) async {
    await _abrir(tester, total260);

    await tester.enterText(find.byType(TextField), '500');
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Exacto'));
    await tester.pump();

    expect(_campo(tester).text, '260.00');
    expect(find.text('RD\$ 0.00'), findsOneWidget);
  });

  testWidgets('con total 2500 solo aparece "Exacto"', (tester) async {
    await _abrir(tester, const Money(250000));

    expect(_chips, findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Exacto'), findsOneWidget);
  });

  testWidgets('un total igual a un billete no duplica "Exacto"', (
    tester,
  ) async {
    await _abrir(tester, const Money(50000));

    expect(find.widgetWithText(ChoiceChip, 'Exacto'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '500'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, '1000'), findsOneWidget);
  });

  testWidgets('monto insuficiente muestra "Faltan RD\$ X" en lugar de "--"', (
    tester,
  ) async {
    await _abrir(tester, total260);

    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();

    expect(find.text('Faltan RD\$ 160.00'), findsOneWidget);
    expect(find.text('--'), findsNothing);
  });

  group('método de pago', () {
    Finder segmento(String texto) => find.descendant(
      of: find.byType(SegmentedButton<MetodoPago>),
      matching: find.text(texto),
    );

    testWidgets('abre con Efectivo seleccionado y los tres métodos', (
      tester,
    ) async {
      await _abrir(tester, total260);

      for (final texto in ['Efectivo', 'Tarjeta', 'Transferencia']) {
        expect(segmento(texto), findsOneWidget, reason: texto);
      }
      final selector = tester.widget<SegmentedButton<MetodoPago>>(
        find.byType(SegmentedButton<MetodoPago>),
      );
      expect(selector.selected, {MetodoPago.efectivo});
      expect(find.text('Monto recibido'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Confirmar'), findsOneWidget);
    });

    testWidgets('tarjeta oculta monto recibido, chips y cambio; el botón dice '
        '"Confirmar pago" y devuelve método tarjeta por el total', (
      tester,
    ) async {
      await _abrir(tester, total260);

      await tester.tap(segmento('Tarjeta'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.text('Cambio'), findsNothing);
      expect(find.text('Monto recibido'), findsNothing);
      expect(
        find.widgetWithText(FilledButton, 'Confirmar pago'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Confirmar'), findsNothing);

      await tester.tap(find.text('Confirmar pago'));
      await tester.pumpAndSettle();

      expect(_resultado?.metodo, MetodoPago.tarjeta);
      expect(_resultado?.recibido, total260);
    });

    testWidgets('transferencia: mismo cobro exacto', (tester) async {
      await _abrir(tester, total260);

      await tester.tap(segmento('Transferencia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar pago'));
      await tester.pumpAndSettle();

      expect(_resultado?.metodo, MetodoPago.transferencia);
      expect(_resultado?.recibido, total260);
    });

    testWidgets('volver a Efectivo restablece monto, chips y cambio', (
      tester,
    ) async {
      await _abrir(tester, total260);
      await tester.tap(segmento('Tarjeta'));
      await tester.pumpAndSettle();

      await tester.tap(segmento('Efectivo'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(4));
      expect(find.text('Cambio'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Confirmar'), findsOneWidget);
    });
  });

  test('montosRapidos: 3 billetes menores que superan el total', () {
    expect(montosRapidos(total260), [
      const Money(50000),
      const Money(100000),
      const Money(200000),
    ]);
    expect(montosRapidos(const Money(4000)), [
      const Money(5000),
      const Money(10000),
      const Money(20000),
    ]);
    expect(montosRapidos(const Money(250000)), isEmpty);
  });
}
