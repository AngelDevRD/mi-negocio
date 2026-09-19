import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:app_gestion/features/products/domain/entities/producto.dart';
import 'package:app_gestion/features/products/presentation/providers/products_providers.dart';
import 'package:app_gestion/features/products/presentation/screens/product_detail_screen.dart';
import 'package:app_gestion/features/products/presentation/screens/products_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'repos_falsos.dart';

class _AuthFalso extends AuthController {
  _AuthFalso(this._rol);

  final RolUsuario _rol;

  @override
  Future<EstadoSesion> build() async => SesionActiva(
    Usuario(
      id: 'u-${_rol.name}',
      negocioId: 'n1',
      nombre: 'Usuario',
      username: 'usuario',
      rol: _rol,
      activo: true,
    ),
  );
}

GoRoute _destino(String path) => GoRoute(
  path: path,
  builder: (_, e) =>
      Scaffold(body: Center(child: Text('destino:${e.uri.path}'))),
);

Future<void> _montar(
  WidgetTester tester, {
  required Widget home,
  List<Producto> productos = const [],
  List<HistorialPrecio> historial = const [],
  RepoInventarioFalso? inventario,
  RolUsuario rol = RolUsuario.administrador,
  List<GoRoute> destinos = const [],
  RepoProductosFalso? repo,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('base')),
      ),
      GoRoute(path: '/pantalla', builder: (_, _) => home),
      ...destinos,
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productsRepositoryProvider.overrideWithValue(
          repo ?? RepoProductosFalso(productos, historial: historial),
        ),
        inventoryRepositoryProvider.overrideWithValue(
          inventario ?? RepoInventarioFalso(),
        ),
        authControllerProvider.overrideWith(() => _AuthFalso(rol)),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  unawaited(router.push('/pantalla'));
  await tester.pumpAndSettle();
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
}

Finder _fila(String nombre) =>
    find.descendant(of: find.byType(Card), matching: find.text(nombre));

void main() {
  group('lista de productos (precio y stock juntos)', () {
    final catalogo = [
      producto(
        'Arroz',
        unidad: 'libra',
        venta: 3500,
        stock: 8.5,
        categoria: 'Granos',
      ),
      producto('Salami', venta: 21000, stock: 3, minimo: 5),
      producto('Agotado', stock: 0, minimo: 0),
      producto('Refresco', venta: 10000, stock: 55),
      producto('Descontinuado', activo: false, stock: 1),
    ];

    testWidgets('cada fila muestra categoría, precio y stock con unidad', (
      tester,
    ) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: catalogo,
      );

      expect(find.text('Granos'), findsOneWidget);
      expect(find.text('RD\$ 35.00'), findsOneWidget);
      expect(find.text('8.5 libras'), findsOneWidget);
      expect(find.text('RD\$ 210.00'), findsOneWidget);
      expect(find.text('3 unidades'), findsOneWidget);
      expect(find.text('55 unidades'), findsOneWidget);
    });

    testWidgets('etiquetas con texto: "Stock bajo" y "Sin stock"', (
      tester,
    ) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: catalogo,
      );

      expect(find.text('Stock bajo'), findsWidgets); // chip + fila(s)
      expect(find.text('Sin stock'), findsOneWidget);
    });

    testWidgets('"Todos" muestra solo activos', (tester) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: catalogo,
      );

      expect(_fila('Arroz'), findsOneWidget);
      expect(_fila('Descontinuado'), findsNothing);
    });

    testWidgets('el chip "Stock bajo" muestra SOLO los de stock <= mínimo', (
      tester,
    ) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: catalogo,
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Stock bajo'));
      await tester.pumpAndSettle();

      expect(_fila('Salami'), findsOneWidget); // 3 <= 5
      expect(_fila('Agotado'), findsOneWidget); // 0 <= 0
      expect(_fila('Arroz'), findsNothing); // 8.5 > 2
      expect(_fila('Refresco'), findsNothing);
      // Los inactivos no aparecen aunque tengan stock bajo.
      expect(_fila('Descontinuado'), findsNothing);
    });

    testWidgets('el chip "Sin costo" (solo Administrador) muestra SOLO los '
        'activos con costo 0', (tester) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: [
          producto('Yuca', compra: 0),
          producto('Plátano', compra: 0),
          producto('Arroz', compra: 2800),
          producto('Viejo', compra: 0, activo: false),
        ],
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Sin costo'));
      await tester.pumpAndSettle();

      expect(_fila('Yuca'), findsOneWidget);
      expect(_fila('Plátano'), findsOneWidget);
      expect(_fila('Arroz'), findsNothing);
      expect(_fila('Viejo'), findsNothing); // inactivo
    });

    testWidgets('el Cajero NO tiene el chip "Sin costo" (no ve costos)', (
      tester,
    ) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: [producto('Yuca', compra: 0)],
        rol: RolUsuario.cajero,
      );

      expect(find.widgetWithText(ChoiceChip, 'Sin costo'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Stock bajo'), findsOneWidget);
    });

    testWidgets('el chip "Inactivos" muestra solo los inactivos', (
      tester,
    ) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: catalogo,
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Inactivos'));
      await tester.pumpAndSettle();

      expect(_fila('Descontinuado'), findsOneWidget);
      expect(find.text('Descontinuado'), findsOneWidget);
      expect(_fila('Arroz'), findsNothing);
      expect(find.textContaining('Inactivo'), findsWidgets);
    });

    testWidgets('volver a "Todos" restablece la lista', (tester) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: catalogo,
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'Stock bajo'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Todos'));
      await tester.pumpAndSettle();

      expect(_fila('Arroz'), findsOneWidget);
      expect(_fila('Refresco'), findsOneWidget);
    });

    testWidgets('sin productos: "Aún no tienes productos" con "Agregar '
        'producto" e "Importar desde Excel" solo para el admin', (
      tester,
    ) async {
      await _montar(tester, home: const ProductsListScreen());

      expect(find.text('Aún no tienes productos'), findsOneWidget);
      expect(find.text('Agregar producto'), findsOneWidget);
      expect(find.text('Importar desde Excel'), findsOneWidget);
      expect(find.text('Sin resultados para este filtro'), findsNothing);
    });

    testWidgets('el cajero no ve "Importar desde Excel"', (tester) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        rol: RolUsuario.cajero,
      );

      expect(find.text('Aún no tienes productos'), findsOneWidget);
      expect(find.text('Importar desde Excel'), findsNothing);
    });

    testWidgets('con productos pero sin coincidencias: "Sin resultados para '
        'este filtro" (texto distinto)', (tester) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: catalogo,
      );

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('Sin resultados para este filtro'), findsOneWidget);
      expect(find.text('Aún no tienes productos'), findsNothing);
    });

    testWidgets('un filtro sin coincidencias (Stock bajo) también dice '
        '"Sin resultados"', (tester) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: [producto('Refresco', stock: 55)],
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Stock bajo'));
      await tester.pumpAndSettle();

      expect(find.text('Sin resultados para este filtro'), findsOneWidget);
    });

    testWidgets('el menú de la barra dice "Gestionar categorías"', (
      tester,
    ) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: catalogo,
        destinos: [_destino('/productos/categorias')],
      );

      await tester.tap(find.byTooltip('Más opciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gestionar categorías'));
      await tester.pumpAndSettle();

      expect(find.text('destino:/productos/categorias'), findsOneWidget);
    });

    testWidgets('tocar un producto abre su detalle', (tester) async {
      await _montar(
        tester,
        home: const ProductsListScreen(),
        productos: catalogo,
        destinos: [_destino('/productos/:id')],
      );

      await tester.tap(_fila('Arroz'));
      await tester.pumpAndSettle();

      expect(find.text('destino:/productos/Arroz'), findsOneWidget);
    });
  });

  group('detalle de producto (inventario y kárdex integrados)', () {
    final salami = producto(
      'Salami',
      id: 'p1',
      categoria: 'Embutidos',
      unidad: 'libra',
      venta: 21000,
      compra: 12000,
      stock: 3,
      minimo: 5,
    );

    RepoInventarioFalso kardex() => RepoInventarioFalso([
      movimiento('m2', TipoMovimientoInventario.venta, -2, 3),
      movimiento('m1', TipoMovimientoInventario.stockInicial, 5, 5),
    ]);

    List<HistorialPrecio> precios() => [
      HistorialPrecio(
        id: 'h1',
        tipo: TipoPrecio.venta,
        precioAnterior: const Money(20000),
        precioNuevo: const Money(21000),
        fecha: DateTime(2026, 1, 10, 9),
        usuarioNombre: 'Ana Admin',
      ),
    ];

    testWidgets('cabecera: precio, stock con unidad, mínimo y estado', (
      tester,
    ) async {
      await _montar(
        tester,
        home: const ProductDetailScreen(productId: 'p1'),
        productos: [salami],
        inventario: kardex(),
        historial: precios(),
      );

      expect(find.text('Embutidos'), findsOneWidget);
      expect(find.text('RD\$ 210.00'), findsOneWidget);
      expect(find.text('3 libras'), findsOneWidget);
      expect(find.text('5 libras'), findsOneWidget); // stock mínimo
      expect(find.text('Stock bajo'), findsOneWidget);
    });

    testWidgets('muestra los movimientos de stock y, en la otra pestaña, el '
        'historial de precios', (tester) async {
      await _montar(
        tester,
        home: const ProductDetailScreen(productId: 'p1'),
        productos: [salami],
        inventario: kardex(),
        historial: precios(),
      );

      // Pestaña por defecto: movimientos de stock.
      expect(find.text('Venta'), findsOneWidget);
      expect(find.text('Stock inicial'), findsOneWidget);
      expect(find.text('-2'), findsOneWidget);
      expect(find.text('+5'), findsOneWidget);
      expect(find.text('Stock: 3'), findsOneWidget);

      await tester.tap(find.text('Historial de precios'));
      await tester.pumpAndSettle();

      expect(find.text('Precio de venta'), findsWidgets);
      expect(find.textContaining('RD\$ 200.00 → RD\$ 210.00'), findsOneWidget);
    });

    testWidgets('sin movimientos: estado vacío', (tester) async {
      await _montar(
        tester,
        home: const ProductDetailScreen(productId: 'p1'),
        productos: [salami],
      );

      expect(find.text('Aún no hay movimientos registrados'), findsOneWidget);
    });

    testWidgets('el administrador ve costo, margen y "Ajustar stock"', (
      tester,
    ) async {
      await _montar(
        tester,
        home: const ProductDetailScreen(productId: 'p1'),
        productos: [salami],
        destinos: [_destino('/inventario/:id/ajuste')],
      );

      expect(find.text('Costo'), findsOneWidget);
      expect(find.text('RD\$ 120.00'), findsOneWidget);
      // (210 - 120) / 210 = 43 %
      expect(find.text('Margen (43%)'), findsOneWidget);
      expect(find.text('RD\$ 90.00'), findsOneWidget);
      expect(find.text('Ajustar stock'), findsOneWidget);

      await tester.tap(find.text('Ajustar stock'));
      await tester.pumpAndSettle();
      expect(find.text('destino:/inventario/p1/ajuste'), findsOneWidget);
    });

    testWidgets('el cajero NO ve costo, margen ni "Ajustar stock"', (
      tester,
    ) async {
      await _montar(
        tester,
        home: const ProductDetailScreen(productId: 'p1'),
        productos: [salami],
        rol: RolUsuario.cajero,
      );

      expect(find.text('Costo'), findsNothing);
      expect(find.textContaining('Margen'), findsNothing);
      expect(find.text('RD\$ 120.00'), findsNothing);
      expect(find.text('Ajustar stock'), findsNothing);
      // Precio y stock sí.
      expect(find.text('RD\$ 210.00'), findsOneWidget);
      expect(find.text('3 libras'), findsOneWidget);
    });

    testWidgets('"Editar" sigue disponible', (tester) async {
      await _montar(
        tester,
        home: const ProductDetailScreen(productId: 'p1'),
        productos: [salami],
        destinos: [_destino('/productos/:id/editar')],
      );

      await tester.tap(find.byTooltip('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('destino:/productos/p1/editar'), findsOneWidget);
    });

    testWidgets('desactivar desde el menú', (tester) async {
      final repo = RepoProductosFalso([salami]);
      await _montar(
        tester,
        home: const ProductDetailScreen(productId: 'p1'),
        repo: repo,
      );

      await tester.tap(find.byTooltip('Más opciones'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Desactivar'));
      await tester.pumpAndSettle();

      expect(repo.activaciones, [(id: 'p1', activo: false)]);
    });

    testWidgets('producto inexistente: estado vacío', (tester) async {
      await _montar(tester, home: const ProductDetailScreen(productId: 'nada'));

      expect(find.text('Producto no encontrado'), findsOneWidget);
    });
  });
}
