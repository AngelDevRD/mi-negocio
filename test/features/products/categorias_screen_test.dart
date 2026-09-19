import 'dart:async';

import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/products/domain/entities/producto.dart';
import 'package:app_gestion/features/products/presentation/providers/products_providers.dart';
import 'package:app_gestion/features/products/presentation/screens/categorias_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'repos_falsos.dart';

enum _Modo { datos, carga, error }

/// Categorías en memoria; `eliminarCategoria` puede fallar o lanzar.
class _RepoCategoriasFalso extends RepoProductosFalso {
  _RepoCategoriasFalso(this.categorias, {this.modo = _Modo.datos})
    : super(const []);

  List<Categoria> categorias;
  final _Modo modo;

  Failure? falloAlEliminar;
  bool lanzarAlEliminar = false;
  int consultas = 0;
  final eliminadas = <String>[];

  @override
  Stream<List<Categoria>> watchCategorias() {
    consultas++;
    switch (modo) {
      case _Modo.carga:
        return StreamController<List<Categoria>>().stream;
      case _Modo.error:
        return Stream.error(StateError('boom'));
      case _Modo.datos:
        return Stream.value(categorias);
    }
  }

  @override
  Future<Result<void>> eliminarCategoria(String id) async {
    if (lanzarAlEliminar) throw StateError('disco lleno');
    if (falloAlEliminar != null) return Result.fail(falloAlEliminar!);
    eliminadas.add(id);
    categorias = [
      for (final c in categorias)
        if (c.id != id) c,
    ];
    return const Result.ok(null);
  }

  @override
  Future<Result<Categoria>> crearCategoria(String nombre) async {
    final nueva = Categoria(id: nombre, nombre: nombre.trim());
    categorias = [...categorias, nueva];
    return Result.ok(nueva);
  }
}

Future<void> _montar(
  WidgetTester tester,
  _RepoCategoriasFalso repo, {
  bool asentar = true,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[productsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const CategoriasManagementScreen(),
      ),
    ),
  );
  asentar ? await tester.pumpAndSettle() : await tester.pump();
}

const _bebidas = Categoria(id: 'c1', nombre: 'Bebidas');
const _granos = Categoria(id: 'c2', nombre: 'Granos');

Future<void> _pedirEliminar(WidgetTester tester, String nombre) async {
  await tester.tap(find.byTooltip('Acciones de $nombre'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Eliminar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cargando: indicador con mensaje', (tester) async {
    await _montar(
      tester,
      _RepoCategoriasFalso([], modo: _Modo.carga),
      asentar: false,
    );

    expect(find.text('Cargando categorías...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error: mensaje humano y "Reintentar" vuelve a consultar', (
    tester,
  ) async {
    final repo = _RepoCategoriasFalso([], modo: _Modo.error);
    await _montar(tester, repo);

    expect(find.text('No se pudieron cargar las categorías.'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
    final antes = repo.consultas;

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repo.consultas, greaterThan(antes));
  });

  testWidgets('vacío: dice por qué y ofrece UNA acción (sin FAB)', (
    tester,
  ) async {
    await _montar(tester, _RepoCategoriasFalso([]));

    expect(find.text('Aún no hay categorías'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Crear categoría'),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('con datos: lista, FAB sin hero y menú con tooltip', (
    tester,
  ) async {
    await _montar(tester, _RepoCategoriasFalso([_bebidas, _granos]));

    expect(find.text('Bebidas'), findsOneWidget);
    expect(find.text('Granos'), findsOneWidget);
    expect(find.byTooltip('Acciones de Bebidas'), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .heroTag,
      isNull,
    );
  });

  testWidgets('eliminar pide confirmación DESTRUCTIVA (botón rojo, no el '
      'verde primario)', (tester) async {
    final repo = _RepoCategoriasFalso([_bebidas, _granos]);
    await _montar(tester, repo);

    await _pedirEliminar(tester, 'Bebidas');

    expect(find.text('¿Eliminar la categoría "Bebidas"?'), findsOneWidget);
    final scheme = Theme.of(
      tester.element(find.byType(AlertDialog)),
    ).colorScheme;
    final confirmar = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Eliminar'),
    );
    expect(confirmar.style?.backgroundColor?.resolve({}), scheme.error);
    expect(repo.eliminadas, isEmpty);
  });

  testWidgets('cancelar la confirmación NO elimina', (tester) async {
    final repo = _RepoCategoriasFalso([_bebidas]);
    await _montar(tester, repo);

    await _pedirEliminar(tester, 'Bebidas');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repo.eliminadas, isEmpty);
    expect(find.text('Bebidas'), findsOneWidget);
  });

  testWidgets('eliminar con éxito: avisa con un snackbar de éxito', (
    tester,
  ) async {
    final repo = _RepoCategoriasFalso([_bebidas, _granos]);
    await _montar(tester, repo);

    await _pedirEliminar(tester, 'Bebidas');
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(repo.eliminadas, ['c1']);
    expect(find.text('Categoría "Bebidas" eliminada.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('eliminar con fallo del repositorio: snackbar de error', (
    tester,
  ) async {
    final repo = _RepoCategoriasFalso(
      [_bebidas],
    )..falloAlEliminar = const BusinessRuleFailure('La categoría está en uso.');
    await _montar(tester, repo);

    await _pedirEliminar(tester, 'Bebidas');
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('La categoría está en uso.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Bebidas'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('eliminar cuando la base lanza: snackbar de error, sin '
      'excepción', (tester) async {
    final repo = _RepoCategoriasFalso([_bebidas])..lanzarAlEliminar = true;
    await _montar(tester, repo);

    await _pedirEliminar(tester, 'Bebidas');
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo eliminar la categoría. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.textContaining('disco lleno'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('crear: valida el nombre y avisa con éxito', (tester) async {
    final repo = _RepoCategoriasFalso([_bebidas]);
    await _montar(tester, repo);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Categoría'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pump();
    expect(find.text('Escribe el nombre de la categoría'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Lácteos');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Categoría creada.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });
}
