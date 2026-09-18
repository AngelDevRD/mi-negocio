import 'package:app_gestion/core/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _rutas = ['/', '/ventas', '/caja', '/productos', '/mas'];
const _etiquetas = ['Inicio', 'Ventas', 'Caja', 'Productos', 'Más'];

GoRouter _crearRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          for (final ruta in _rutas)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: ruta,
                  builder: (context, state) =>
                      Center(child: Text('Pantalla $ruta')),
                  routes: [
                    if (ruta == '/productos')
                      GoRoute(
                        path: 'detalle',
                        builder: (context, state) =>
                            const Center(child: Text('Detalle de producto')),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    ],
  );
}

Future<GoRouter> _montar(WidgetTester tester, {required double ancho}) async {
  await tester.binding.setSurfaceSize(Size(ancho, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = _crearRouter();
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  // AppShell decide por LayoutBuilder (constraints), no por MediaQuery:
  // setSurfaceSize sí cambia ese ancho. Se comprueba el que ve el widget.
  expect(tester.getSize(find.byType(AppShell)).width, ancho);
  return router;
}

String _ubicacion(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

void main() {
  testWidgets('ancho 400: NavigationBar inferior con las 5 etiquetas', (
    tester,
  ) async {
    await _montar(tester, ancho: 400);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    for (final etiqueta in _etiquetas) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(etiqueta),
        ),
        findsOneWidget,
        reason: 'falta la etiqueta "$etiqueta"',
      );
    }
  });

  testWidgets('ancho 800: NavigationRail lateral con etiquetas', (
    tester,
  ) async {
    await _montar(tester, ancho: 800);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
    for (final etiqueta in _etiquetas) {
      expect(find.text(etiqueta), findsOneWidget);
    }
  });

  testWidgets('ancho 1200: NavigationRail extendido', (tester) async {
    await _montar(tester, ancho: 1200);

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isTrue);
  });

  testWidgets('tocar un destino navega a su rama', (tester) async {
    final router = await _montar(tester, ancho: 400);

    await tester.tap(find.text('Ventas'));
    await tester.pumpAndSettle();

    expect(_ubicacion(router), '/ventas');
    expect(find.text('Pantalla /ventas'), findsOneWidget);
  });

  testWidgets('el botón atrás en una rama distinta de Inicio va a Inicio', (
    tester,
  ) async {
    final router = await _montar(tester, ancho: 400);

    await tester.tap(find.text('Caja'));
    await tester.pumpAndSettle();
    expect(_ubicacion(router), '/caja');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(_ubicacion(router), '/');
  });

  testWidgets('tocar el destino activo vuelve a la raíz de su rama', (
    tester,
  ) async {
    final router = await _montar(tester, ancho: 400);

    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
    router.go('/productos/detalle');
    await tester.pumpAndSettle();
    expect(find.text('Detalle de producto'), findsOneWidget);

    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();

    expect(_ubicacion(router), '/productos');
    expect(find.text('Pantalla /productos'), findsOneWidget);
    expect(find.text('Detalle de producto'), findsNothing);
  });
}
