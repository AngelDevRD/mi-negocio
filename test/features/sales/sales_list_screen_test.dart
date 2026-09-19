import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/core/widgets/encabezado_dia.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/sales/domain/entities/venta.dart';
import 'package:app_gestion/features/sales/domain/repositories/sales_repository.dart';
import 'package:app_gestion/features/sales/presentation/providers/sales_providers.dart';
import 'package:app_gestion/features/sales/presentation/screens/sales_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class _AuthFalso extends AuthController {
  _AuthFalso(this._nombre);

  final String _nombre;

  @override
  Future<EstadoSesion> build() async => SesionActiva(
    Usuario(
      id: 'u1',
      negocioId: 'n1',
      nombre: _nombre,
      username: 'usuario',
      rol: RolUsuario.administrador,
      activo: true,
    ),
  );
}

/// Ventas en memoria que respetan los filtros como lo haría el datasource.
class RepoVentasFalso implements SalesRepository {
  RepoVentasFalso(this.ventas);

  final List<Venta> ventas;

  /// Con `true`, `watchVentas` emite un error.
  bool fallar = false;

  @override
  Stream<List<Venta>> watchVentas({
    EstadoVenta? estado,
    DateTime? desde,
    DateTime? hasta,
  }) {
    if (fallar) return Stream.error(StateError('boom'));
    return Stream.value([
      for (final v in ventas)
        if ((estado == null || v.estado == estado) &&
            (desde == null || !v.fecha.isBefore(desde)) &&
            (hasta == null || !v.fecha.isAfter(hasta)))
          v,
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DateTime _hoy(int hora, [int minuto = 0]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day, hora, minuto);
}

Venta _venta(
  String id,
  int cents,
  DateTime fecha, {
  EstadoVenta estado = EstadoVenta.completada,
  TipoVenta tipo = TipoVenta.rapida,
  String usuario = 'Luis',
  String? nota,
}) => Venta(
  id: id,
  tipo: tipo,
  total: Money(cents),
  ganancia: Money.zero,
  estado: estado,
  nota: nota,
  usuarioNombre: usuario,
  fecha: fecha.toUtc(),
);

Future<void> _montar(
  WidgetTester tester,
  RepoVentasFalso repo, {
  String usuarioActual = 'Luis',
}) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SalesListScreen()),
      GoRoute(
        path: '/ventas/rapida',
        builder: (_, _) => const Scaffold(body: Text('pos')),
      ),
      GoRoute(
        path: '/ventas/:id',
        builder: (_, e) => Scaffold(
          body: Center(child: Text('detalle:${e.pathParameters['id']}')),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        salesRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(() => _AuthFalso(usuarioActual)),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  await tester.pumpAndSettle();
}

/// Total del encabezado de un día ("Hoy", "Ayer"...).
Money _totalDelDia(WidgetTester tester, String titulo) => tester
    .widget<EncabezadoDia>(
      find.byWidgetPredicate((w) => w is EncabezadoDia && w.titulo == titulo),
    )
    .total;

void main() {
  final ayer = _hoy(12).subtract(const Duration(days: 1));

  group('agrupado por día', () {
    final ventas = [
      _venta('h1', 30000, _hoy(11, 30)),
      _venta('h2', 15000, _hoy(9, 15), tipo: TipoVenta.detallada),
      _venta('h3', 99900, _hoy(8), estado: EstadoVenta.anulada),
      _venta('a1', 20000, ayer),
    ];

    testWidgets('encabezados "Hoy" y "Ayer" con el total del día SIN las '
        'anuladas', (tester) async {
      await _montar(tester, RepoVentasFalso(ventas));

      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('Ayer'), findsOneWidget);
      // Hoy: 300 + 150 (la anulada de 999 no cuenta). Ayer: 200.
      expect(_totalDelDia(tester, 'Hoy'), const Money(45000));
      expect(_totalDelDia(tester, 'Ayer'), const Money(20000));
    });

    testWidgets('resumen del período: total vendido y cuántas ventas', (
      tester,
    ) async {
      await _montar(tester, RepoVentasFalso(ventas));

      expect(find.text('Total vendido'), findsOneWidget);
      expect(find.text('3 ventas completadas'), findsOneWidget);
      expect(find.text('RD\$ 650.00'), findsOneWidget);
    });

    testWidgets('la fila muestra la hora local y el tipo de venta', (
      tester,
    ) async {
      await _montar(tester, RepoVentasFalso(ventas));

      expect(find.text('11:30 · Venta rápida'), findsOneWidget);
      expect(find.text('09:15 · Venta detallada'), findsOneWidget);
    });

    testWidgets('las filas de tipo distinto llevan un ícono distinto', (
      tester,
    ) async {
      await _montar(tester, RepoVentasFalso(ventas));

      expect(find.byIcon(Icons.point_of_sale), findsWidgets);
      expect(find.byIcon(Icons.receipt_long_outlined), findsWidgets);
    });

    testWidgets('tocar una venta abre su detalle', (tester) async {
      await _montar(tester, RepoVentasFalso(ventas));

      await tester.tap(find.text('11:30 · Venta rápida'));
      await tester.pumpAndSettle();

      expect(find.text('detalle:h1'), findsOneWidget);
    });
  });

  group('venta anulada', () {
    testWidgets('lleva la etiqueta "Anulada" (ícono + texto) y el total '
        'tachado', (tester) async {
      await _montar(
        tester,
        RepoVentasFalso([
          _venta('ok', 30000, _hoy(11)),
          _venta('x', 99900, _hoy(10), estado: EstadoVenta.anulada),
        ]),
      );

      expect(find.text('Anulada'), findsOneWidget);
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);
      final anulada = tester.widget<Text>(find.text('RD\$ 999.00'));
      expect(anulada.style?.decoration, TextDecoration.lineThrough);
      final normal = tester.widget<Text>(find.text('RD\$ 300.00').last);
      expect(normal.style?.decoration, isNot(TextDecoration.lineThrough));
    });
  });

  group('vendedor', () {
    testWidgets('solo se nombra si NO es el usuario actual', (tester) async {
      await _montar(
        tester,
        RepoVentasFalso([
          _venta('mia', 10000, _hoy(11), usuario: 'Luis'),
          _venta('otra', 20000, _hoy(10), usuario: 'Ana'),
        ]),
        usuarioActual: 'Luis',
      );

      expect(find.text('Vendió Ana'), findsOneWidget);
      expect(find.textContaining('Vendió Luis'), findsNothing);
    });

    testWidgets('muestra la nota de la venta si la tiene', (tester) async {
      await _montar(
        tester,
        RepoVentasFalso([
          _venta('n', 10000, _hoy(11), nota: 'Pedido para fiesta'),
        ]),
      );

      expect(find.text('Pedido para fiesta'), findsOneWidget);
    });
  });

  group('filtros', () {
    final ventas = [
      _venta('ok', 30000, _hoy(11)),
      _venta('x', 99900, _hoy(10), estado: EstadoVenta.anulada),
      _venta('vieja', 50000, _hoy(12).subtract(const Duration(days: 40))),
    ];

    testWidgets('chips de estado: Anuladas deja solo las anuladas (sin '
        'totales) y Completadas las quita', (tester) async {
      await _montar(tester, RepoVentasFalso(ventas));
      expect(find.text('Anulada'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Anuladas'));
      await tester.pumpAndSettle();
      expect(find.text('RD\$ 999.00'), findsOneWidget);
      expect(find.text('RD\$ 300.00'), findsNothing);
      // Con "Anuladas" el total vendido no aplica.
      expect(find.text('Total vendido'), findsNothing);
      expect(find.byType(EncabezadoDia), findsNothing);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Completadas'));
      await tester.pumpAndSettle();
      expect(find.text('Anulada'), findsNothing);
      expect(find.text('RD\$ 300.00'), findsWidgets);
      expect(find.text('Total vendido'), findsOneWidget);
    });

    testWidgets('el chip de fecha tiene TEXTO y "Hoy" filtra al día', (
      tester,
    ) async {
      await _montar(tester, RepoVentasFalso(ventas));
      // Sin filtro: las tres ventas (una de hace 40 días).
      expect(find.text('Todas las fechas'), findsOneWidget);
      expect(find.text('RD\$ 500.00'), findsWidgets);

      await tester.tap(find.text('Todas las fechas'));
      await tester.pumpAndSettle();
      for (final opcion in [
        'Hoy',
        'Esta semana',
        'Este mes',
        'Personalizado...',
      ]) {
        expect(find.text(opcion), findsWidgets);
      }
      await tester.tap(find.text('Hoy').last);
      await tester.pumpAndSettle();

      expect(find.text('RD\$ 500.00'), findsNothing); // la de hace 40 días
      expect(find.text('RD\$ 300.00'), findsWidgets);
      // El chip ahora dice el período elegido.
      expect(find.widgetWithText(Chip, 'Hoy'), findsOneWidget);
    });

    testWidgets('"Este mes" también deja fuera la venta de hace 40 días', (
      tester,
    ) async {
      await _montar(tester, RepoVentasFalso(ventas));

      await tester.tap(find.text('Todas las fechas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Este mes').last);
      await tester.pumpAndSettle();

      expect(find.text('RD\$ 500.00'), findsNothing);
      expect(find.text('RD\$ 300.00'), findsWidgets);
    });

    testWidgets('"Personalizado..." abre el selector de rango de fechas', (
      tester,
    ) async {
      await _montar(tester, RepoVentasFalso(ventas));
      // El selector de rango del sistema necesita más ancho que un teléfono
      // en el entorno de pruebas (su encabezado desborda con la fuente Ahem).
      tester.view.physicalSize = const Size(900, 1200);

      await tester.tap(find.text('Todas las fechas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personalizado...'));
      await tester.pumpAndSettle();

      expect(find.byType(DateRangePickerDialog), findsOneWidget);

      // Cancelar no cambia el filtro.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Todas las fechas'), findsOneWidget);
    });
  });

  group('estados', () {
    testWidgets('sin ventas: "Aún no hay ventas" con la acción "Nueva venta"', (
      tester,
    ) async {
      await _montar(tester, RepoVentasFalso([]));

      expect(find.text('Aún no hay ventas'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Nueva venta'), findsOneWidget);
      expect(find.text('Sin resultados para este filtro'), findsNothing);
    });

    testWidgets('el botón del estado vacío abre el POS', (tester) async {
      await _montar(tester, RepoVentasFalso([]));

      await tester.tap(find.widgetWithText(FilledButton, 'Nueva venta'));
      await tester.pumpAndSettle();

      expect(find.text('pos'), findsOneWidget);
    });

    testWidgets('con filtro y sin coincidencias: "Sin resultados" es distinto '
        'del vacío y "Quitar filtros" lo limpia', (tester) async {
      await _montar(tester, RepoVentasFalso([_venta('ok', 30000, _hoy(11))]));

      await tester.tap(find.widgetWithText(ChoiceChip, 'Anuladas'));
      await tester.pumpAndSettle();

      expect(find.text('Sin resultados para este filtro'), findsOneWidget);
      expect(find.text('Aún no hay ventas'), findsNothing);

      await tester.tap(find.text('Quitar filtros'));
      await tester.pumpAndSettle();

      expect(find.text('RD\$ 300.00'), findsWidgets);
      expect(find.text('Sin resultados para este filtro'), findsNothing);
    });

    testWidgets('error: mensaje humano y "Reintentar" recarga', (tester) async {
      final repo = RepoVentasFalso([_venta('ok', 30000, _hoy(11))])
        ..fallar = true;
      await _montar(tester, repo);

      expect(find.text('No se pudieron cargar las ventas.'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);

      repo.fallar = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('RD\$ 300.00'), findsWidgets);
    });

    testWidgets('el FAB "Nueva venta" sigue en la pantalla', (tester) async {
      await _montar(tester, RepoVentasFalso([_venta('ok', 30000, _hoy(11))]));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .heroTag,
        isNull,
      );
    });
  });

  test('la hora se formatea en 24 h local', () {
    expect(DateFormat('HH:mm').format(DateTime(2025, 1, 1, 9, 5)), '09:05');
  });
}
