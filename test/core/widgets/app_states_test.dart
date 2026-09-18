import 'dart:math';

import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/widgets/app_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _luminanciaRelativa(Color color) {
  double canal(double c) {
    return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * canal(color.r) +
      0.7152 * canal(color.g) +
      0.0722 * canal(color.b);
}

double _contraste(Color a, Color b) {
  final la = _luminanciaRelativa(a);
  final lb = _luminanciaRelativa(b);
  final claro = max(la, lb);
  final oscuro = min(la, lb);
  return (claro + 0.05) / (oscuro + 0.05);
}

void main() {
  test(
    'la descripción de EmptyState (onSurfaceVariant) tiene contraste '
    '>= 4.5:1 sobre el fondo de la app',
    () {
      final scheme = AppTheme.light().colorScheme;
      final fondo = AppTheme.light().scaffoldBackgroundColor;
      expect(
        _contraste(scheme.onSurfaceVariant, fondo),
        greaterThanOrEqualTo(4.5),
      );
    },
  );

  group('EmptyState', () {
    testWidgets('muestra título, descripción y ejecuta onAccion', (
      tester,
    ) async {
      var tocado = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icono: Icons.inventory_2_outlined,
              titulo: 'Sin productos',
              descripcion: 'Agrega tu primer producto para empezar.',
              accionLabel: 'Agregar producto',
              onAccion: () => tocado = true,
            ),
          ),
        ),
      );

      expect(find.text('Sin productos'), findsOneWidget);
      expect(
        find.text('Agrega tu primer producto para empezar.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Agregar producto'));
      await tester.pump();
      expect(tocado, isTrue);
    });

    testWidgets('sin accionLabel/onAccion no muestra botón', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icono: Icons.inbox_outlined,
              titulo: 'Sin datos',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets(
      'con acción y descripción larga en superficie chica y textScaler '
      'grande no produce overflow (hace scroll)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(640, 300));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                body: EmptyState(
                  icono: Icons.inventory_2_outlined,
                  titulo: 'Sin productos registrados todavía',
                  descripcion:
                      'Agrega tu primer producto para empezar a vender y '
                      'llevar el control de tu inventario desde esta '
                      'pantalla, sin necesidad de hojas de cálculo.',
                  accionLabel: 'Agregar producto',
                  onAccion: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // EmptyState no decide por ancho: lo que importa es el ALTO de las
        // restricciones (el LayoutBuilder/scroll), que setSurfaceSize sí fija.
        expect(tester.getSize(find.byType(Scaffold)), const Size(640, 300));
        expect(tester.takeException(), isNull);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      },
    );
  });

  group('ErrorState', () {
    testWidgets(
      'muestra el mensaje, NO muestra error.toString(), ejecuta onReintentar',
      (tester) async {
        var reintentado = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorState(
                mensaje: 'No se pudieron cargar las ventas.',
                error: Exception('detalle interno reservado 12345'),
                onReintentar: () => reintentado = true,
              ),
            ),
          ),
        );

        expect(
          find.text('No se pudieron cargar las ventas.'),
          findsOneWidget,
        );
        expect(
          find.textContaining('detalle interno reservado'),
          findsNothing,
        );
        expect(find.text('Reintentar'), findsOneWidget);

        await tester.tap(find.text('Reintentar'));
        await tester.pump();
        expect(reintentado, isTrue);
      },
    );

    testWidgets('sin onReintentar no muestra el botón', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorState(mensaje: 'Ocurrió un error.')),
        ),
      );

      expect(find.text('Reintentar'), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
