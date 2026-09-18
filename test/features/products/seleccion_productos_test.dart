import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:app_gestion/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:app_gestion/features/products/domain/entities/producto.dart';
import 'package:app_gestion/features/products/domain/repositories/products_repository.dart';
import 'package:app_gestion/features/products/presentation/providers/products_providers.dart';
import 'package:app_gestion/features/products/presentation/screens/products_list_screen.dart';
import 'package:app_gestion/features/sales/presentation/screens/pos_screen.dart';
import 'package:app_gestion/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Repositorio en memoria (sin drift: sus streams dejan timers pendientes en
/// los widget tests). Solo implementa lo que usan estas pantallas.
class _RepoFalso implements ProductsRepository {
  _RepoFalso(this.productos);

  final List<Producto> productos;

  @override
  Stream<List<Categoria>> watchCategorias() => Stream.value(const []);

  @override
  Stream<List<Producto>> watchProductos({
    String busqueda = '',
    String? categoriaId,
    bool? activo,
  }) {
    final texto = busqueda.trim().toLowerCase();
    return Stream.value([
      for (final p in productos)
        if ((activo == null || p.activo == activo) &&
            (categoriaId == null || p.categoriaId == categoriaId) &&
            p.nombre.toLowerCase().contains(texto))
          p,
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AuthFalso extends AuthController {
  @override
  Future<EstadoSesion> build() async => const SesionActiva(
    Usuario(
      id: 'u1',
      negocioId: 'n1',
      nombre: 'Ana Admin',
      username: 'ana',
      rol: RolUsuario.administrador,
      activo: true,
    ),
  );
}

Producto _producto(String nombre, {bool activo = true}) => Producto(
  id: nombre,
  nombre: nombre,
  unidad: 'unidad',
  precioCompra: const Money(1000),
  precioVenta: const Money(1500),
  stockActual: 10,
  stockMinimo: 2,
  activo: activo,
);

final _caja = CajaActual(
  sesionId: 'sesion',
  fechaApertura: DateTime(2026),
  montoApertura: const Money(0),
  montoActual: const Money(0),
);

List<Override> _overrides() => [
  productsRepositoryProvider.overrideWithValue(
    _RepoFalso([
      _producto('Arroz'),
      _producto('Salami'),
      _producto('Aceite'),
      _producto('Producto inactivo', activo: false),
    ]),
  ),
  cajaActualProvider.overrideWith((ref) => Stream.value(_caja)),
  authControllerProvider.overrideWith(_AuthFalso.new),
  permitirStockNegativoProvider.overrideWith((ref) => Stream.value(true)),
];

/// PosScreen decide por MediaQuery.sizeOf: setSurfaceSize NO lo cambia (seguía
/// en 800x600 y el test corría con la disposición de teléfono), así que se fija
/// la vista con DPR 1.
void _superficieAncha(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1400, 900);
  addTearDown(tester.view.reset);
}

Finder _en(Type pantalla, Finder buscado) =>
    find.descendant(of: find.byType(pantalla), matching: buscado);

void main() {
  testWidgets(
    'buscar en la selección de venta rápida NO filtra la lista de Productos '
    'ni cambia productosFiltroProvider',
    (tester) async {
      _superficieAncha(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const MaterialApp(
            home: Row(
              children: [
                Expanded(child: ProductsListScreen()),
                Expanded(child: PosScreen()),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // PosScreen ve realmente el ancho de escritorio (decide por MediaQuery).
      expect(
        MediaQuery.sizeOf(tester.element(find.byType(PosScreen))).width,
        1400,
      );

      // Ambas pantallas muestran los productos activos.
      expect(_en(ProductsListScreen, find.text('Salami')), findsOneWidget);
      expect(_en(PosScreen, find.text('Salami')), findsOneWidget);

      await tester.enterText(
        _en(PosScreen, find.widgetWithText(TextField, 'Buscar producto')),
        'arroz',
      );
      await tester.pump();
      await tester.pump();

      // La selección de venta sí se filtra...
      expect(_en(PosScreen, find.text('Arroz')), findsOneWidget);
      expect(_en(PosScreen, find.text('Salami')), findsNothing);

      // ...pero la pestaña Productos y su filtro quedan intactos.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProductsListScreen)),
      );
      expect(container.read(productosFiltroProvider).busqueda, isEmpty);
      expect(_en(ProductsListScreen, find.text('Salami')), findsOneWidget);
      expect(_en(ProductsListScreen, find.text('Arroz')), findsOneWidget);
    },
  );

  testWidgets(
    'la selección para vender NO muestra productos inactivos, aunque la '
    'pestaña Productos esté mostrando inactivos',
    (tester) async {
      _superficieAncha(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const MaterialApp(home: PosScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PosScreen)),
      );
      // La pestaña Productos pasa a ver "todos" (activos e inactivos).
      container
          .read(productosFiltroProvider.notifier)
          .actualizar((f) => f.copyWith(soloActivos: null));
      await tester.pump();
      await tester.pump();

      expect(find.text('Arroz'), findsOneWidget);
      expect(find.text('Producto inactivo'), findsNothing);
    },
  );

  group('abrir y cerrar no produce excepciones', () {
    Future<void> abrirYCerrar(
      WidgetTester tester,
      Widget pantalla, {
      Future<void> Function()? interactuar,
    }) async {
      _superficieAncha(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute<void>(builder: (_) => pantalla)),
                    child: const Text('abrir'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await interactuar?.call();

      // Volver: aquí se ejecuta dispose() de la pantalla.
      final navegador = tester.state<NavigatorState>(find.byType(Navigator));
      navegador.pop();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('abrir'), findsOneWidget);
    }

    testWidgets('punto de venta', (tester) async {
      await abrirYCerrar(tester, const PosScreen());
    });

    testWidgets('venta (y su diálogo de cantidad o monto)', (tester) async {
      await abrirYCerrar(
        tester,
        const PosScreen(),
        interactuar: () async {
          await tester.tap(find.text('Salami'));
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsOneWidget);
          await tester.tap(find.text('Cancelar'));
          await tester.pumpAndSettle();
        },
      );
    });
  });
}
