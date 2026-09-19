import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/core/widgets/encabezado_dia.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/purchases/domain/entities/compra.dart';
import 'package:app_gestion/features/purchases/domain/entities/proveedor.dart';
import 'package:app_gestion/features/purchases/domain/repositories/purchases_repository.dart';
import 'package:app_gestion/features/purchases/presentation/providers/purchases_providers.dart';
import 'package:app_gestion/features/purchases/presentation/screens/purchase_detail_screen.dart';
import 'package:app_gestion/features/purchases/presentation/screens/purchase_form_screen.dart';
import 'package:app_gestion/features/purchases/presentation/screens/purchases_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _AuthFalso extends AuthController {
  @override
  Future<EstadoSesion> build() async => SesionActiva(
    const Usuario(
      id: 'u1',
      negocioId: 'n1',
      nombre: 'Ana Admin',
      username: 'ana',
      rol: RolUsuario.administrador,
      activo: true,
    ),
  );
}

/// Compras en memoria que respetan los filtros como lo haría el datasource.
class RepoComprasFalso implements PurchasesRepository {
  RepoComprasFalso({
    this.compras = const [],
    this.proveedores = const [
      Proveedor(id: 'p1', nombre: 'Distribuidora Caribe'),
    ],
  });

  final List<Compra> compras;
  final List<Proveedor> proveedores;

  /// Con `true`, las consultas fallan.
  bool fallar = false;

  /// Si no es `null`, `registrarCompra` espera a que se complete.
  Completer<void>? bloqueo;
  Result<String> resultadoRegistro = const Result.ok('nueva');
  final registros = <List<ItemCompraInput>>[];

  @override
  Stream<List<Proveedor>> watchProveedores() => Stream.value(proveedores);

  @override
  Stream<List<Compra>> watchCompras({
    String? proveedorId,
    DateTime? desde,
    DateTime? hasta,
  }) {
    if (fallar) return Stream.error(StateError('boom'));
    return Stream.value([
      for (final c in compras)
        if ((proveedorId == null || c.proveedorId == proveedorId) &&
            (desde == null || !c.fecha.isBefore(desde)) &&
            (hasta == null || !c.fecha.isAfter(hasta)))
          c,
    ]);
  }

  @override
  Future<Compra?> obtenerCompra(String id) async {
    if (fallar) throw StateError('boom');
    return compras.where((c) => c.id == id).firstOrNull;
  }

  @override
  Future<Result<String>> registrarCompra({
    String? proveedorId,
    String? numeroFactura,
    String? fotoFacturaPath,
    required List<ItemCompraInput> items,
    required bool pagadaDeCaja,
    required String usuarioId,
  }) async {
    registros.add(items);
    if (bloqueo != null) await bloqueo!.future;
    return resultadoRegistro;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DateTime _hoy(int hora, [int minuto = 0]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day, hora, minuto);
}

Compra _compra(
  String id,
  int cents,
  DateTime fecha, {
  String? proveedor = 'Distribuidora Caribe',
  EstadoCompra estado = EstadoCompra.completada,
  String? factura,
  bool deCaja = false,
  List<CompraItem> items = const [],
}) => Compra(
  id: id,
  proveedorId: proveedor == null ? null : 'p1',
  proveedorNombre: proveedor,
  numeroFactura: factura,
  total: Money(cents),
  pagadaDeCaja: deCaja,
  estado: estado,
  usuarioNombre: 'Ana Admin',
  fecha: fecha.toUtc(),
  items: items,
);

const _itemArroz = ItemCompraInput(
  productoId: 'arroz',
  productoNombre: 'Arroz selecto',
  cantidad: 2,
  costoUnitario: Money(15000),
);

GoRouter _router(Widget pantalla) => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => pantalla),
    GoRoute(
      path: '/compras/nueva',
      builder: (_, _) => const Scaffold(body: Text('formulario')),
    ),
    GoRoute(
      path: '/compras/:id',
      builder: (_, e) => Scaffold(
        body: Center(child: Text('detalle:${e.pathParameters['id']}')),
      ),
    ),
  ],
);

Future<void> _montarPantalla(
  WidgetTester tester,
  Widget pantalla,
  RepoComprasFalso repo,
) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = _router(pantalla);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        purchasesRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(_AuthFalso.new),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

/// Monta el formulario ENCIMA de una ruta base (para poder "salir" de él).
Future<ProviderContainer> _montarFormulario(
  WidgetTester tester,
  RepoComprasFalso repo, {
  bool conBorrador = false,
}) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Center(child: Text('base'))),
      ),
      GoRoute(path: '/form', builder: (_, _) => const PurchaseFormScreen()),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        purchasesRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(_AuthFalso.new),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  await container.read(authControllerProvider.future);
  if (conBorrador) {
    container.read(nuevaCompraProvider.notifier).agregarItem(_itemArroz);
  }
  unawaited(router.push('/form'));
  await tester.pumpAndSettle();
  return container;
}

Money _totalDelDia(WidgetTester tester, String titulo) => tester
    .widget<EncabezadoDia>(
      find.byWidgetPredicate((w) => w is EncabezadoDia && w.titulo == titulo),
    )
    .total;

void main() {
  final ayer = _hoy(12).subtract(const Duration(days: 1));

  group('lista de compras', () {
    final compras = [
      _compra('c1', 100000, _hoy(11), factura: 'F-1042', deCaja: true),
      _compra('c2', 50000, _hoy(9), estado: EstadoCompra.anulada),
      _compra('c3', 25000, ayer, proveedor: null),
    ];

    testWidgets('agrupada por día con el total comprado SIN las anuladas', (
      tester,
    ) async {
      await _montarPantalla(
        tester,
        const PurchasesListScreen(),
        RepoComprasFalso(compras: compras),
      );

      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('Ayer'), findsOneWidget);
      expect(_totalDelDia(tester, 'Hoy'), const Money(100000));
      expect(_totalDelDia(tester, 'Ayer'), const Money(25000));
    });

    testWidgets('fila: proveedor, hora, factura y "Pagada de caja"', (
      tester,
    ) async {
      await _montarPantalla(
        tester,
        const PurchasesListScreen(),
        RepoComprasFalso(compras: compras),
      );

      expect(find.text('Sin proveedor'), findsOneWidget);
      expect(
        find.text('11:00 · Factura F-1042 · Pagada de caja'),
        findsOneWidget,
      );
    });

    testWidgets('la compra anulada lleva "Anulada" con ícono y el total '
        'tachado', (tester) async {
      await _montarPantalla(
        tester,
        const PurchasesListScreen(),
        RepoComprasFalso(compras: compras),
      );

      expect(find.text('Anulada'), findsOneWidget);
      final total = tester.widget<Text>(find.text('RD\$ 500.00'));
      expect(total.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('el chip de fecha tiene texto y filtra ("Hoy" quita las de '
        'ayer)', (tester) async {
      await _montarPantalla(
        tester,
        const PurchasesListScreen(),
        RepoComprasFalso(compras: compras),
      );
      expect(find.text('Todas las fechas'), findsOneWidget);

      await tester.tap(find.text('Todas las fechas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hoy').last);
      await tester.pumpAndSettle();

      expect(find.text('Ayer'), findsNothing);
      expect(find.text('Sin proveedor'), findsNothing);
    });

    testWidgets('tocar una compra abre su detalle', (tester) async {
      await _montarPantalla(
        tester,
        const PurchasesListScreen(),
        RepoComprasFalso(compras: compras),
      );

      await tester.tap(find.text('11:00 · Factura F-1042 · Pagada de caja'));
      await tester.pumpAndSettle();

      expect(find.text('detalle:c1'), findsOneWidget);
    });

    testWidgets('sin compras: "Aún no hay compras" con la acción "Nueva '
        'compra"', (tester) async {
      await _montarPantalla(
        tester,
        const PurchasesListScreen(),
        RepoComprasFalso(),
      );

      expect(find.text('Aún no hay compras'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Nueva compra'), findsOneWidget);
      expect(find.text('Sin resultados para este filtro'), findsNothing);
    });

    testWidgets('con filtro y sin coincidencias: "Sin resultados" y "Quitar '
        'filtros"', (tester) async {
      await _montarPantalla(
        tester,
        const PurchasesListScreen(),
        RepoComprasFalso(compras: [_compra('vieja', 10000, ayer)]),
      );

      await tester.tap(find.text('Todas las fechas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hoy').last);
      await tester.pumpAndSettle();

      expect(find.text('Sin resultados para este filtro'), findsOneWidget);
      expect(find.text('Aún no hay compras'), findsNothing);

      await tester.tap(find.text('Quitar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('Sin resultados para este filtro'), findsNothing);
      expect(find.text('Ayer'), findsOneWidget);
    });

    testWidgets('error: mensaje humano y "Reintentar" recarga', (tester) async {
      final repo = RepoComprasFalso(compras: compras)..fallar = true;
      await _montarPantalla(tester, const PurchasesListScreen(), repo);

      expect(find.text('No se pudieron cargar las compras.'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);

      repo.fallar = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Hoy'), findsOneWidget);
    });
  });

  group('detalle de compra', () {
    final detalle = _compra(
      'd1',
      37500,
      _hoy(10, 30),
      factura: 'F-77',
      items: const [
        CompraItem(
          productoId: 'a',
          productoNombre: 'Arroz selecto',
          cantidad: 2.5,
          costoUnitario: Money(15000),
        ),
      ],
    );

    testWidgets('proveedor, factura, fecha local, ítems y total', (
      tester,
    ) async {
      await _montarPantalla(
        tester,
        const PurchaseDetailScreen(compraId: 'd1'),
        RepoComprasFalso(compras: [detalle]),
      );

      expect(find.text('Distribuidora Caribe'), findsOneWidget);
      expect(find.text('F-77'), findsOneWidget);
      expect(find.textContaining('10:30'), findsOneWidget);
      expect(find.text('Arroz selecto'), findsOneWidget);
      expect(find.text('2.5 × '), findsOneWidget);
      expect(find.text('RD\$ 150.00'), findsOneWidget); // costo unitario
      // Subtotal del ítem y total de la compra.
      expect(find.text('RD\$ 375.00'), findsNWidgets(2));
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('una compra anulada lo dice con ícono y texto', (tester) async {
      await _montarPantalla(
        tester,
        const PurchaseDetailScreen(compraId: 'x'),
        RepoComprasFalso(
          compras: [_compra('x', 10000, _hoy(9), estado: EstadoCompra.anulada)],
        ),
      );

      expect(find.text('Anulada'), findsOneWidget);
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);
    });

    testWidgets('compra inexistente: estado vacío con texto', (tester) async {
      await _montarPantalla(
        tester,
        const PurchaseDetailScreen(compraId: 'no'),
        RepoComprasFalso(),
      );

      expect(find.text('Compra no encontrada'), findsOneWidget);
    });

    testWidgets('error: "Reintentar" vuelve a cargar', (tester) async {
      final repo = RepoComprasFalso(compras: [detalle])..fallar = true;
      await _montarPantalla(
        tester,
        const PurchaseDetailScreen(compraId: 'd1'),
        repo,
      );

      expect(find.text('No se pudo cargar la compra.'), findsOneWidget);

      repo.fallar = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Distribuidora Caribe'), findsOneWidget);
    });
  });

  group('formulario de compra', () {
    testWidgets('sin cambios: salir NO pide confirmación', (tester) async {
      await _montarFormulario(tester, RepoComprasFalso());
      expect(find.text('Nueva compra'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('¿Descartar compra?'), findsNothing);
      expect(find.text('base'), findsOneWidget);
    });

    testWidgets('con cambios: pide confirmar; "Seguir editando" se queda y '
        '"Descartar" sale y borra el borrador', (tester) async {
      final container = await _montarFormulario(
        tester,
        RepoComprasFalso(),
        conBorrador: true,
      );

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar compra?'), findsOneWidget);
      expect(find.text('Seguir editando'), findsOneWidget);

      await tester.tap(find.text('Seguir editando'));
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar compra?'), findsNothing);
      expect(find.text('Nueva compra'), findsOneWidget);
      expect(container.read(nuevaCompraProvider).items, isNotEmpty);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();

      expect(find.text('base'), findsOneWidget);
      expect(container.read(nuevaCompraProvider).items, isEmpty);
    });

    testWidgets('el gesto "atrás" del sistema también pide confirmar', (
      tester,
    ) async {
      await _montarFormulario(tester, RepoComprasFalso(), conBorrador: true);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('¿Descartar compra?'), findsOneWidget);
    });

    testWidgets('el total y "Guardar compra" están siempre a la vista', (
      tester,
    ) async {
      await _montarFormulario(tester, RepoComprasFalso(), conBorrador: true);

      expect(find.text('Total'), findsOneWidget);
      // 2 x RD$ 150.00 = RD$ 300.00 (en el ítem y en el total).
      expect(find.text('RD\$ 300.00'), findsNWidgets(2));
      expect(
        find.widgetWithText(FilledButton, 'Guardar compra'),
        findsOneWidget,
      );
    });

    testWidgets('doble toque en guardar = UN solo guardado y sale sin '
        'preguntar', (tester) async {
      final repo = RepoComprasFalso()..bloqueo = Completer<void>();
      await _montarFormulario(tester, repo, conBorrador: true);

      final guardar = find.widgetWithText(FilledButton, 'Guardar compra');
      await tester.tap(guardar);
      await tester.pump();
      // Ya está guardando: el botón se deshabilita.
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
        isNull,
      );
      await tester.tap(find.byType(FilledButton).last, warnIfMissed: false);
      await tester.pump();

      repo.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(repo.registros, hasLength(1));
      expect(find.text('¿Descartar compra?'), findsNothing);
      expect(find.text('base'), findsOneWidget);
    });

    testWidgets('guardar sin productos avisa y no registra', (tester) async {
      final repo = RepoComprasFalso();
      await _montarFormulario(tester, repo);

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar compra'));
      await tester.pump();

      expect(
        find.text('Agrega al menos un producto a la compra.'),
        findsOneWidget,
      );
      expect(repo.registros, isEmpty);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('si el guardado falla se avisa y se conserva el borrador', (
      tester,
    ) async {
      final repo = RepoComprasFalso()
        ..resultadoRegistro = const Result.fail(
          BusinessRuleFailure('Debe abrir una caja.'),
        );
      final container = await _montarFormulario(
        tester,
        repo,
        conBorrador: true,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar compra'));
      await tester.pumpAndSettle();

      expect(find.text('Debe abrir una caja.'), findsOneWidget);
      expect(find.text('Nueva compra'), findsOneWidget);
      expect(container.read(nuevaCompraProvider).items, isNotEmpty);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('sin productos: estado vacío con texto y los IconButton '
        'tienen tooltip', (tester) async {
      await _montarFormulario(tester, RepoComprasFalso());

      expect(find.text('Aún no has agregado productos'), findsOneWidget);
      expect(find.byTooltip('Nuevo proveedor'), findsOneWidget);
    });

    testWidgets('el ítem se puede quitar con su botón (tooltip)', (
      tester,
    ) async {
      final container = await _montarFormulario(
        tester,
        RepoComprasFalso(),
        conBorrador: true,
      );

      await tester.tap(find.byTooltip('Quitar producto'));
      await tester.pumpAndSettle();

      expect(container.read(nuevaCompraProvider).items, isEmpty);
    });
  });
}
