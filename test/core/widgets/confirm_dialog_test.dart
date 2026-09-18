import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildApp(Future<bool> Function(BuildContext context) accion) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => accion(context),
          child: const Text('abrir'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('confirmar devuelve true', (tester) async {
    bool? resultado;
    await tester.pumpWidget(
      _buildApp((context) async {
        resultado = await mostrarConfirmacion(
          context,
          titulo: 'Eliminar producto',
          mensaje: '¿Seguro que deseas eliminarlo?',
          confirmarLabel: 'Eliminar',
        );
        return resultado!;
      }),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(resultado, isTrue);
  });

  testWidgets('cancelar devuelve false', (tester) async {
    bool? resultado;
    await tester.pumpWidget(
      _buildApp((context) async {
        resultado = await mostrarConfirmacion(
          context,
          titulo: 'Eliminar producto',
          mensaje: '¿Seguro que deseas eliminarlo?',
          confirmarLabel: 'Eliminar',
        );
        return resultado!;
      }),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(resultado, isFalse);
  });

  testWidgets('descartar el diálogo (tap fuera) devuelve false', (
    tester,
  ) async {
    bool? resultado;
    await tester.pumpWidget(
      _buildApp((context) async {
        resultado = await mostrarConfirmacion(
          context,
          titulo: 'Eliminar producto',
          mensaje: '¿Seguro que deseas eliminarlo?',
          confirmarLabel: 'Eliminar',
        );
        return resultado!;
      }),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    // Tap en la barrera (fuera del cuadro de diálogo) para descartarlo.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(resultado, isFalse);
  });

  testWidgets('destructivo=true usa colorScheme.error en el botón confirmar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp((context) async {
        return mostrarConfirmacion(
          context,
          titulo: 'Eliminar producto',
          mensaje: '¿Seguro que deseas eliminarlo?',
          confirmarLabel: 'Eliminar',
          destructivo: true,
        );
      }),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Eliminar producto'));
    final scheme = Theme.of(context).colorScheme;

    final boton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Eliminar'),
    );
    final fondo = boton.style?.backgroundColor?.resolve(<WidgetState>{});
    expect(fondo, scheme.error);
  });
}
