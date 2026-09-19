import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/products/domain/entities/producto.dart';
import 'package:app_gestion/features/products/presentation/providers/products_providers.dart';
import 'package:app_gestion/features/products/presentation/screens/product_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'repos_falsos.dart';

class _AuthFalso extends AuthController {
  _AuthFalso([this.rol = RolUsuario.administrador]);

  final RolUsuario rol;

  @override
  Future<EstadoSesion> build() async => SesionActiva(
    Usuario(
      id: 'u1',
      negocioId: 'n1',
      nombre: 'Ana',
      username: 'ana',
      rol: rol,
      activo: true,
    ),
  );
}

/// Productos en memoria que registra los guardados.
class _RepoFormularioFalso extends RepoProductosFalso {
  _RepoFormularioFalso(super.productos, {this.fallaAlCargar = false});

  final bool fallaAlCargar;
  Completer<void>? bloqueo;
  Failure? fallo;
  int creados = 0;
  int actualizados = 0;
  Money? ultimoPrecioCompra;
  Money? ultimoPrecioVenta;
  double? ultimoStockInicial;
  String? ultimaUnidad;

  @override
  Future<Producto?> obtenerProducto(String id) {
    if (fallaAlCargar) throw StateError('boom');
    return super.obtenerProducto(id);
  }

  @override
  Future<Result<Producto>> crearProducto({
    required String nombre,
    String? categoriaId,
    required String unidad,
    required Money precioCompra,
    required Money precioVenta,
    required double stockInicial,
    required double stockMinimo,
    required String usuarioId,
  }) async {
    creados++;
    ultimoPrecioCompra = precioCompra;
    ultimoPrecioVenta = precioVenta;
    ultimoStockInicial = stockInicial;
    ultimaUnidad = unidad;
    await bloqueo?.future;
    if (fallo != null) return Result.fail(fallo!);
    return Result.ok(producto(nombre));
  }

  @override
  Future<Result<Producto>> actualizarProducto({
    required String id,
    required String nombre,
    String? categoriaId,
    required String unidad,
    required Money precioCompra,
    required Money precioVenta,
    required double stockMinimo,
    required String usuarioId,
  }) async {
    actualizados++;
    ultimoPrecioCompra = precioCompra;
    ultimoPrecioVenta = precioVenta;
    await bloqueo?.future;
    if (fallo != null) return Result.fail(fallo!);
    return Result.ok(producto(nombre));
  }
}

Future<void> _montarEncima(
  WidgetTester tester,
  _RepoFormularioFalso repo,
  String ruta, {
  RolUsuario rol = RolUsuario.administrador,
}) async {
  tester.view.physicalSize = const Size(420, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/base',
    routes: [
      GoRoute(
        path: '/base',
        builder: (_, _) => const Scaffold(body: Center(child: Text('base'))),
      ),
      GoRoute(path: '/nuevo', builder: (_, _) => const ProductFormScreen()),
      GoRoute(
        path: '/editar/:id',
        builder: (_, state) =>
            ProductFormScreen(productId: state.pathParameters['id']),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        productsRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(() => _AuthFalso(rol)),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  await tester.pumpAndSettle();
  unawaited(router.push(ruta));
  await tester.pumpAndSettle();
}

Finder _campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

String _texto(WidgetTester tester, String etiqueta) => tester
    .widget<EditableText>(
      find.descendant(
        of: _campo(etiqueta),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

Future<void> _llenarValido(WidgetTester tester) async {
  await tester.enterText(_campo('Nombre'), 'Salami');
  await tester.enterText(_campo('Precio de compra'), '100');
  await tester.enterText(_campo('Precio de venta'), '150');
}

void main() {
  group('margen en vivo', () {
    testWidgets('el Administrador ve el margen y cambia mientras escribe', (
      tester,
    ) async {
      await _montarEncima(tester, _RepoFormularioFalso([]), '/nuevo');

      expect(
        find.text(
          'Escribe el precio de compra y el de venta para ver el margen.',
        ),
        findsOneWidget,
      );

      await tester.enterText(_campo('Precio de compra'), '100');
      await tester.enterText(_campo('Precio de venta'), '150');
      await tester.pump();

      expect(find.text('Margen'), findsOneWidget);
      expect(find.text('RD\$ 50.00'), findsOneWidget);
      expect(find.text('(33%)'), findsOneWidget);
      expect(find.text('Vendes por debajo del costo'), findsNothing);

      await tester.enterText(_campo('Precio de venta'), '80');
      await tester.pump();

      expect(find.text('RD\$ -20.00'), findsOneWidget);
      expect(find.text('(-25%)'), findsOneWidget);
      expect(find.text('Vendes por debajo del costo'), findsOneWidget);
    });

    testWidgets('el Cajero NO ve costo derivado: no hay margen', (
      tester,
    ) async {
      await _montarEncima(
        tester,
        _RepoFormularioFalso([]),
        '/nuevo',
        rol: RolUsuario.cajero,
      );

      await tester.enterText(_campo('Precio de venta'), '150');
      await tester.pump();

      expect(find.text('Margen'), findsNothing);
      expect(find.textContaining('ver el margen'), findsNothing);
    });
  });

  // Deuda de TASK-026: un Cajero SÍ puede abrir este formulario (ver el test
  // de rutas en app_router_test.dart), así que el costo no puede verse.
  group('costo oculto al Cajero', () {
    testWidgets('el Administrador ve el campo "Precio de compra"', (
      tester,
    ) async {
      await _montarEncima(tester, _RepoFormularioFalso([]), '/nuevo');

      expect(_campo('Precio de compra'), findsOneWidget);
      expect(find.textContaining('lo completa el administrador'), findsNothing);
    });

    testWidgets('el Cajero NO ve "Precio de compra" al crear y lo avisa', (
      tester,
    ) async {
      await _montarEncima(
        tester,
        _RepoFormularioFalso([]),
        '/nuevo',
        rol: RolUsuario.cajero,
      );

      expect(_campo('Precio de compra'), findsNothing);
      expect(_campo('Precio de venta'), findsOneWidget);
      expect(
        find.text('El costo del producto lo completa el administrador.'),
        findsOneWidget,
      );
    });

    testWidgets('Cajero CREA: el costo se guarda en 0 (sin pedirlo)', (
      tester,
    ) async {
      final repo = _RepoFormularioFalso([]);
      await _montarEncima(tester, repo, '/nuevo', rol: RolUsuario.cajero);

      await tester.enterText(_campo('Nombre'), 'Yuca');
      await tester.enterText(_campo('Precio de venta'), '35');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(repo.creados, 1);
      expect(repo.ultimoPrecioCompra, Money.zero);
      expect(repo.ultimoPrecioVenta, const Money(3500));
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('Cajero EDITA: no ve el costo y se CONSERVA el existente', (
      tester,
    ) async {
      final repo = _RepoFormularioFalso([
        producto('Salami', id: 'p1', compra: 12345, venta: 20000),
      ]);
      await _montarEncima(tester, repo, '/editar/p1', rol: RolUsuario.cajero);

      expect(_campo('Precio de compra'), findsNothing);
      expect(find.textContaining('lo completa el administrador'), findsNothing);
      expect(find.textContaining('12,345'), findsNothing);
      expect(find.textContaining('123.45'), findsNothing);

      await tester.enterText(_campo('Precio de venta'), '250');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(repo.actualizados, 1);
      expect(repo.ultimoPrecioCompra, const Money(12345));
      expect(repo.ultimoPrecioVenta, const Money(25000));
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('Administrador EDITA: ve el costo y puede cambiarlo', (
      tester,
    ) async {
      final repo = _RepoFormularioFalso([
        producto('Salami', id: 'p1', compra: 12345, venta: 20000),
      ]);
      await _montarEncima(tester, repo, '/editar/p1');

      expect(_texto(tester, 'Precio de compra'), '123.45');
      await tester.enterText(_campo('Precio de compra'), '130');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(repo.ultimoPrecioCompra, const Money(13000));
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('validación de montos', () {
    testWidgets('"." y "1.2.3" muestran "Precio inválido" sin lanzar ni '
        'guardar', (tester) async {
      final repo = _RepoFormularioFalso([]);
      await _montarEncima(tester, repo, '/nuevo');

      await tester.enterText(_campo('Nombre'), 'Salami');
      await tester.enterText(_campo('Precio de compra'), '.');
      await tester.enterText(_campo('Precio de venta'), '1.2.3');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pump();

      expect(find.text('Precio inválido'), findsNWidgets(2));
      expect(repo.creados, 0);
      expect(tester.takeException(), isNull);
      // Con montos que no se pueden leer, el margen no se inventa.
      expect(find.text('Margen'), findsNothing);
    });

    testWidgets('sin nombre ni precios: mensajes claros', (tester) async {
      final repo = _RepoFormularioFalso([]);
      await _montarEncima(tester, repo, '/nuevo');

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pump();

      expect(find.text('Escribe el nombre del producto'), findsOneWidget);
      expect(find.text('Obligatorio'), findsNWidgets(2));
      expect(repo.creados, 0);
    });
  });

  group('unidad', () {
    testWidgets('las sugerencias rellenan el campo y se puede escribir otra', (
      tester,
    ) async {
      await _montarEncima(tester, _RepoFormularioFalso([]), '/nuevo');

      expect(_texto(tester, 'Unidad'), 'unidad');
      for (final sugerida in [
        'unidad',
        'libra',
        'kg',
        'litro',
        'paquete',
        'caja',
      ]) {
        expect(find.widgetWithText(ChoiceChip, sugerida), findsOneWidget);
      }

      await tester.tap(find.widgetWithText(ChoiceChip, 'kg'));
      await tester.pump();
      expect(_texto(tester, 'Unidad'), 'kg');
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'kg'))
            .selected,
        isTrue,
      );

      await tester.enterText(_campo('Unidad'), 'galón');
      await tester.pump();
      expect(_texto(tester, 'Unidad'), 'galón');
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'kg'))
            .selected,
        isFalse,
      );
    });

    testWidgets('la unidad escrita a mano se guarda tal cual', (tester) async {
      final repo = _RepoFormularioFalso([]);
      await _montarEncima(tester, repo, '/nuevo');

      await _llenarValido(tester);
      await tester.enterText(_campo('Unidad'), 'galón');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(repo.ultimaUnidad, 'galón');
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('stock inicial', () {
    testWidgets('solo al CREAR', (tester) async {
      await _montarEncima(tester, _RepoFormularioFalso([]), '/nuevo');
      expect(_campo('Stock inicial'), findsOneWidget);
    });

    testWidgets('al EDITAR no existe', (tester) async {
      await _montarEncima(
        tester,
        _RepoFormularioFalso([producto('Salami', id: 'p1')]),
        '/editar/p1',
      );
      expect(find.text('Editar producto'), findsOneWidget);
      expect(_campo('Stock inicial'), findsNothing);
      expect(_campo('Stock mínimo'), findsOneWidget);
      expect(_texto(tester, 'Nombre'), 'Salami');
    });

    testWidgets('editar: error de carga con reintento', (tester) async {
      await _montarEncima(
        tester,
        _RepoFormularioFalso([], fallaAlCargar: true),
        '/editar/p1',
      );
      expect(find.text('No se pudo cargar el producto.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('editar: producto inexistente', (tester) async {
      await _montarEncima(tester, _RepoFormularioFalso([]), '/editar/nada');
      expect(find.text('Producto no encontrado'), findsOneWidget);
    });
  });

  group('salir y guardar', () {
    testWidgets('sin cambios: salir NO pide confirmación', (tester) async {
      await _montarEncima(tester, _RepoFormularioFalso([]), '/nuevo');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('¿Descartar cambios?'), findsNothing);
      expect(find.text('base'), findsOneWidget);
    });

    testWidgets('con cambios: pide confirmar; "Seguir editando" se queda y '
        '"Descartar" sale', (tester) async {
      await _montarEncima(tester, _RepoFormularioFalso([]), '/nuevo');

      await tester.enterText(_campo('Nombre'), 'Salami');
      await tester.pump();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar cambios?'), findsOneWidget);

      await tester.tap(find.text('Seguir editando'));
      await tester.pumpAndSettle();
      expect(find.text('Nuevo producto'), findsOneWidget);
      expect(_texto(tester, 'Nombre'), 'Salami');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('base'), findsOneWidget);
    });

    testWidgets('doble toque en Guardar = UN solo guardado, con los montos '
        'leídos con Money', (tester) async {
      final repo = _RepoFormularioFalso([])..bloqueo = Completer<void>();
      await _montarEncima(tester, repo, '/nuevo');

      await _llenarValido(tester);
      await tester.enterText(_campo('Precio de compra'), '1,250.50');
      final guardar = find.widgetWithText(FilledButton, 'Guardar');
      await tester.tap(guardar);
      await tester.tap(guardar);
      await tester.pump();

      expect(repo.creados, 1);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
        isNull,
      );

      repo.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(repo.creados, 1);
      expect(repo.ultimoPrecioCompra, const Money(125050));
      expect(repo.ultimoPrecioVenta, const Money(15000));
      expect(repo.ultimoStockInicial, 0);
      expect(find.text('¿Descartar cambios?'), findsNothing);
      expect(find.text('base'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('error del repositorio: snackbar y el formulario sigue', (
      tester,
    ) async {
      final repo = _RepoFormularioFalso([])
        ..fallo = const ValidationFailure(
          'Ya existe un producto con ese nombre.',
        );
      await _montarEncima(tester, repo, '/nuevo');

      await _llenarValido(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Ya existe un producto con ese nombre.'),
        findsOneWidget,
      );
      expect(find.text('Nuevo producto'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });
  });
}
