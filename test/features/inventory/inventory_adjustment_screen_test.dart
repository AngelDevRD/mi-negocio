import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:app_gestion/features/inventory/presentation/screens/inventory_adjustment_screen.dart';
import 'package:app_gestion/features/products/presentation/providers/products_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../products/repos_falsos.dart';

class _AuthFalso extends AuthController {
  @override
  Future<EstadoSesion> build() async => const SesionActiva(
    Usuario(
      id: 'u1',
      negocioId: 'n1',
      nombre: 'Ana',
      username: 'ana',
      rol: RolUsuario.administrador,
      activo: true,
    ),
  );
}

/// Kárdex en memoria que registra los ajustes.
class _RepoAjusteFalso extends RepoInventarioFalso {
  Completer<void>? bloqueo;
  Failure? fallo;
  final ajustes = <({double cantidad, String motivo})>[];

  @override
  Future<Result<void>> ajusteManual({
    required String productoId,
    required double cantidad,
    required String motivo,
    required String usuarioId,
  }) async {
    ajustes.add((cantidad: cantidad, motivo: motivo));
    await bloqueo?.future;
    if (fallo != null) return Result.fail(fallo!);
    return const Result.ok(null);
  }
}

class _RepoProductosFallido extends RepoProductosFalso {
  _RepoProductosFallido() : super(const []);

  @override
  Future<Never> obtenerProducto(String id) => throw StateError('boom');
}

Future<void> _montar(
  WidgetTester tester,
  _RepoAjusteFalso inventario, {
  RepoProductosFalso? productos,
}) async {
  tester.view.physicalSize = const Size(420, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/base',
    routes: [
      GoRoute(
        path: '/base',
        builder: (_, _) => const Scaffold(body: Center(child: Text('base'))),
      ),
      GoRoute(
        path: '/ajuste/:id',
        builder: (_, state) =>
            InventoryAdjustmentScreen(productId: state.pathParameters['id']!),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        inventoryRepositoryProvider.overrideWithValue(inventario),
        productsRepositoryProvider.overrideWithValue(
          productos ??
              RepoProductosFalso([producto('Salami', id: 'p1', stock: 20)]),
        ),
        authControllerProvider.overrideWith(_AuthFalso.new),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  await tester.pumpAndSettle();
  unawaited(router.push('/ajuste/p1'));
  await tester.pumpAndSettle();
}

Finder get _cantidad => find.widgetWithText(TextFormField, 'Cantidad');
Finder get _motivo => find.widgetWithText(TextFormField, 'Motivo del ajuste');

String _textoMotivo(WidgetTester tester) => tester
    .widget<EditableText>(
      find.descendant(of: _motivo, matching: find.byType(EditableText)),
    )
    .controller
    .text;

void main() {
  testWidgets('cargando el producto: indicador con mensaje', (tester) async {
    tester.view.physicalSize = const Size(420, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/ajuste/p1',
      routes: [
        GoRoute(
          path: '/ajuste/:id',
          builder: (_, state) =>
              InventoryAdjustmentScreen(productId: state.pathParameters['id']!),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          productoProvider(
            'p1',
          ).overrideWith((ref) => Completer<Never>().future),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Cargando producto...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error al cargar el producto: mensaje y "Reintentar"', (
    tester,
  ) async {
    await _montar(
      tester,
      _RepoAjusteFalso(),
      productos: _RepoProductosFallido(),
    );

    expect(find.text('No se pudo cargar el producto.'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('producto inexistente: estado vacío', (tester) async {
    await _montar(
      tester,
      _RepoAjusteFalso(),
      productos: RepoProductosFalso(const []),
    );

    expect(find.text('Producto no encontrado'), findsOneWidget);
  });

  group('stock resultante en vivo', () {
    testWidgets('Salida: "Stock actual X · quedará Y" con la unidad', (
      tester,
    ) async {
      await _montar(tester, _RepoAjusteFalso());

      expect(find.text('Stock actual 20 unidades'), findsOneWidget);

      await tester.tap(find.text('Salida'));
      await tester.pump();
      await tester.enterText(_cantidad, '5');
      await tester.pump();

      expect(
        find.text('Stock actual 20 unidades · quedará 15 unidades'),
        findsOneWidget,
      );
    });

    testWidgets('cambiar a Entrada recalcula; la unidad se ve junto al '
        'campo', (tester) async {
      await _montar(
        tester,
        _RepoAjusteFalso(),
        productos: RepoProductosFalso([
          producto('Arroz', id: 'p1', unidad: 'libra', stock: 8.5),
        ]),
      );

      await tester.enterText(_cantidad, '1.5');
      await tester.pump();
      expect(
        find.text('Stock actual 8.5 libras · quedará 10 libras'),
        findsOneWidget,
      );
      // Unidad visible como sufijo del campo de cantidad.
      expect(find.text('libra'), findsOneWidget);

      await tester.tap(find.text('Salida'));
      await tester.pump();
      expect(
        find.text('Stock actual 8.5 libras · quedará 7 libras'),
        findsOneWidget,
      );
    });

    testWidgets('una salida mayor que el stock avisa que quedará negativo', (
      tester,
    ) async {
      await _montar(tester, _RepoAjusteFalso());

      await tester.tap(find.text('Salida'));
      await tester.pump();
      await tester.enterText(_cantidad, '30');
      await tester.pump();

      expect(
        find.text('Stock actual 20 unidades · quedará -10 unidades'),
        findsOneWidget,
      );
      expect(find.text('El stock quedará en negativo'), findsOneWidget);
    });

    testWidgets('Entrada/Salida es un SegmentedButton con texto', (
      tester,
    ) async {
      await _montar(tester, _RepoAjusteFalso());

      expect(find.byType(SegmentedButton<bool>), findsOneWidget);
      expect(find.text('Entrada'), findsOneWidget);
      expect(find.text('Salida'), findsOneWidget);
    });
  });

  group('motivo', () {
    testWidgets('es obligatorio: sin motivo no guarda y lo dice', (
      tester,
    ) async {
      final repo = _RepoAjusteFalso();
      await _montar(tester, repo);

      await tester.enterText(_cantidad, '5');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar ajuste'));
      await tester.pump();

      expect(find.text('El motivo es obligatorio'), findsOneWidget);
      expect(repo.ajustes, isEmpty);
    });

    testWidgets('los chips rellenan el motivo; "Otro" lo deja vacío para '
        'escribir', (tester) async {
      await _montar(tester, _RepoAjusteFalso());

      for (final chip in [
        'Merma',
        'Vencido',
        'Conteo físico',
        'Regalo',
        'Otro',
      ]) {
        expect(find.widgetWithText(ChoiceChip, chip), findsOneWidget);
      }

      await tester.tap(find.widgetWithText(ChoiceChip, 'Vencido'));
      await tester.pump();
      expect(_textoMotivo(tester), 'Vencido');
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Vencido'))
            .selected,
        isTrue,
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Otro'));
      await tester.pump();
      expect(_textoMotivo(tester), '');
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Otro'))
            .selected,
        isTrue,
      );

      await tester.enterText(_motivo, 'Se cayó del estante');
      await tester.pump();
      expect(_textoMotivo(tester), 'Se cayó del estante');
    });
  });

  group('guardar', () {
    testWidgets('una salida con motivo llega al repositorio con la cantidad '
        'NEGATIVA y se sale con aviso', (tester) async {
      final repo = _RepoAjusteFalso();
      await _montar(tester, repo);

      await tester.tap(find.text('Salida'));
      await tester.pump();
      await tester.enterText(_cantidad, '5');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Merma'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar ajuste'));
      await tester.pumpAndSettle();

      expect(repo.ajustes, [(cantidad: -5.0, motivo: 'Merma')]);
      expect(find.text('Ajuste registrado.'), findsOneWidget);
      expect(find.text('base'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('doble toque = UN solo ajuste', (tester) async {
      final repo = _RepoAjusteFalso()..bloqueo = Completer<void>();
      await _montar(tester, repo);

      await tester.enterText(_cantidad, '5');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Regalo'));
      await tester.pump();
      final guardar = find.widgetWithText(FilledButton, 'Guardar ajuste');
      await tester.tap(guardar);
      await tester.tap(guardar);
      await tester.pump();

      expect(repo.ajustes.length, 1);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
        isNull,
      );

      repo.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(repo.ajustes.length, 1);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('PermissionFailure del repositorio: snackbar de error con su '
        'mensaje y el formulario sigue', (tester) async {
      final repo = _RepoAjusteFalso()
        ..fallo = const PermissionFailure(
          'Solo el administrador puede ajustar el inventario.',
        );
      await _montar(tester, repo);

      await tester.enterText(_cantidad, '5');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Merma'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar ajuste'));
      await tester.pumpAndSettle();

      expect(
        find.text('Solo el administrador puede ajustar el inventario.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Ajuste de inventario'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('cantidad inválida: mensaje y NO guarda', (tester) async {
      final repo = _RepoAjusteFalso();
      await _montar(tester, repo);

      await tester.enterText(_cantidad, '.');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Merma'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar ajuste'));
      await tester.pump();

      expect(find.text('Cantidad inválida'), findsOneWidget);
      expect(repo.ajustes, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });
}
