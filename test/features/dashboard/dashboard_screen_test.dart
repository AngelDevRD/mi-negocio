import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/router/app_router.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:app_gestion/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:app_gestion/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:app_gestion/features/license/presentation/providers/license_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _AuthFalso extends AuthController {
  _AuthFalso(this._estado);

  final EstadoSesion _estado;

  @override
  Future<EstadoSesion> build() async => _estado;
}

class _LicenciaFalsa extends LicenseController {
  @override
  Future<LicenseCheck> build() async => const SinLicencia();
}

Usuario _usuario(RolUsuario rol) => Usuario(
  id: 'u1',
  negocioId: 'n1',
  nombre: rol == RolUsuario.administrador ? 'Ana Admin' : 'Carlos Cajero',
  username: 'usuario',
  rol: rol,
  activo: true,
);

final _caja = CajaActual(
  sesionId: 'sesion',
  fechaApertura: DateTime(2026, 1, 1, 9, 30),
  montoApertura: const Money(100000),
  montoActual: const Money(250000),
);

List<Override> _overrides({
  required RolUsuario rol,
  bool cajaAbierta = true,
  bool hayProductos = true,
}) => [
  authControllerProvider.overrideWith(
    () => _AuthFalso(SesionActiva(_usuario(rol))),
  ),
  licenseControllerProvider.overrideWith(_LicenciaFalsa.new),
  negocioTieneProductosProvider.overrideWith(
    (ref) => Stream.value(hayProductos),
  ),
  cajaActualProvider.overrideWith(
    (ref) => Stream.value(cajaAbierta ? _caja : null),
  ),
  ventasDelDiaProvider.overrideWith((ref) => Stream.value(const Money(50000))),
  ventasDelMesProvider.overrideWith((ref) => Stream.value(const Money(900000))),
  comprasDelMesProvider.overrideWith(
    (ref) => Stream.value(const Money(400000)),
  ),
  gastosDelMesProvider.overrideWith((ref) => Stream.value(const Money(70000))),
  gananciaDelMesProvider.overrideWith(
    (ref) => Stream.value(const Money(300000)),
  ),
  productosBajoStockProvider.overrideWith((ref) => Stream.value(const [])),
  movimientosRecientesProvider.overrideWith((ref) => Stream.value(const [])),
];

Future<void> _montar(WidgetTester tester, List<Override> overrides) async {
  await tester.binding.setSurfaceSize(const Size(500, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  Widget destino(String texto) => Scaffold(body: Center(child: Text(texto)));
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const DashboardScreen()),
      for (final ruta in [
        AppRoutes.ventaRapida,
        AppRoutes.comprasNueva,
        AppRoutes.productosNuevo,
        AppRoutes.importar,
      ])
        GoRoute(path: ruta, builder: (_, _) => destino('destino:$ruta')),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

/// Etiquetas de los botones SÓLIDOS (FilledButton no tonal): la acción
/// principal de la pantalla. Debe haber exactamente uno por estado. Se
/// distingue sólido de tonal por el color real del Material del botón
/// (primary vs. secondaryContainer).
List<String> _botonesPrimarios(WidgetTester tester) {
  final resultado = <String>[];
  for (final boton
      in find.byWidgetPredicate((w) => w is FilledButton).evaluate()) {
    final elemento = find.byElementPredicate((e) => e == boton);
    final material = tester.widget<Material>(
      find.descendant(of: elemento, matching: find.byType(Material)).first,
    );
    final esquema = Theme.of(boton).colorScheme;
    if (material.color == esquema.primary) {
      resultado.add(
        tester
            .widgetList<Text>(
              find.descendant(of: elemento, matching: find.byType(Text)),
            )
            .map((t) => t.data)
            .join(),
      );
    }
  }
  return resultado;
}

void main() {
  testWidgets('"Nueva venta" lleva a la venta rápida', (tester) async {
    await _montar(tester, _overrides(rol: RolUsuario.cajero));

    await tester.tap(find.text('Nueva venta'));
    await tester.pumpAndSettle();

    expect(find.text('destino:${AppRoutes.ventaRapida}'), findsOneWidget);
  });

  testWidgets('"Registrar compra" lleva a la compra nueva', (tester) async {
    await _montar(tester, _overrides(rol: RolUsuario.administrador));

    await tester.tap(find.text('Registrar compra'));
    await tester.pumpAndSettle();

    expect(find.text('destino:${AppRoutes.comprasNueva}'), findsOneWidget);
  });

  group('caja', () {
    testWidgets('con la caja cerrada se ofrece "Abrir caja"', (tester) async {
      await _montar(
        tester,
        _overrides(rol: RolUsuario.cajero, cajaAbierta: false),
      );

      expect(
        find.text('La caja está cerrada. Ábrela para poder vender.'),
        findsOneWidget,
      );
      expect(find.text('Abrir caja'), findsOneWidget);
      expect(find.text('Caja abierta'), findsNothing);

      // El botón abre el diálogo de apertura.
      await tester.tap(find.text('Abrir caja'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('con la caja abierta se muestra el monto actual', (
      tester,
    ) async {
      await _montar(tester, _overrides(rol: RolUsuario.cajero));

      expect(find.text('Caja abierta'), findsOneWidget);
      expect(find.text(const Money(250000).format()), findsOneWidget);
      expect(find.text('Abrir caja'), findsNothing);
    });
  });

  group('ganancia bruta (RN-15)', () {
    testWidgets('el cajero NO ve "Ganancia bruta del mes"', (tester) async {
      await _montar(tester, _overrides(rol: RolUsuario.cajero));

      expect(find.text('Ventas del mes'), findsOneWidget);
      expect(find.text('Ganancia bruta del mes'), findsNothing);
      expect(find.text(const Money(300000).format()), findsNothing);
    });

    testWidgets('el administrador SÍ ve "Ganancia bruta del mes"', (
      tester,
    ) async {
      await _montar(tester, _overrides(rol: RolUsuario.administrador));

      expect(find.text('Ganancia bruta del mes'), findsOneWidget);
      expect(find.text(const Money(300000).format()), findsOneWidget);
    });
  });

  group('sin productos', () {
    testWidgets('muestra la bienvenida en lugar de los indicadores', (
      tester,
    ) async {
      await _montar(
        tester,
        _overrides(rol: RolUsuario.cajero, hayProductos: false),
      );

      expect(find.text('Empieza agregando tus productos'), findsOneWidget);
      expect(find.text('Agregar producto'), findsOneWidget);
      expect(find.text('Ventas del mes'), findsNothing);
      // Importar desde Excel es solo del Administrador.
      expect(find.text('Importar desde Excel'), findsNothing);
    });

    testWidgets('el administrador además puede importar desde Excel', (
      tester,
    ) async {
      await _montar(
        tester,
        _overrides(rol: RolUsuario.administrador, hayProductos: false),
      );

      expect(find.text('Importar desde Excel'), findsOneWidget);

      await tester.tap(find.text('Agregar producto'));
      await tester.pumpAndSettle();
      expect(find.text('destino:${AppRoutes.productosNuevo}'), findsOneWidget);
    });

    testWidgets('con productos NO se muestra la bienvenida', (tester) async {
      await _montar(tester, _overrides(rol: RolUsuario.cajero));

      expect(find.text('Empieza agregando tus productos'), findsNothing);
      expect(find.text('Ventas del mes'), findsOneWidget);
    });
  });

  group('una sola acción principal por estado', () {
    testWidgets('con productos y caja abierta: "Nueva venta" es la primaria', (
      tester,
    ) async {
      await _montar(tester, _overrides(rol: RolUsuario.administrador));

      expect(_botonesPrimarios(tester), ['Nueva venta']);
    });

    testWidgets('con productos y caja cerrada: "Abrir caja" es la primaria y '
        '"Nueva venta" baja a secundaria (sigue funcionando)', (tester) async {
      await _montar(
        tester,
        _overrides(rol: RolUsuario.administrador, cajaAbierta: false),
      );

      expect(_botonesPrimarios(tester), ['Abrir caja']);
      expect(find.text('Nueva venta'), findsOneWidget);

      await tester.tap(find.text('Nueva venta'));
      await tester.pumpAndSettle();
      expect(find.text('destino:${AppRoutes.ventaRapida}'), findsOneWidget);
    });

    testWidgets('sin productos (caja abierta): "Agregar producto" es la '
        'primaria y no hay Nueva venta ni Registrar compra', (tester) async {
      await _montar(
        tester,
        _overrides(rol: RolUsuario.administrador, hayProductos: false),
      );

      expect(_botonesPrimarios(tester), ['Agregar producto']);
      expect(find.text('Nueva venta'), findsNothing);
      expect(find.text('Registrar compra'), findsNothing);
    });

    testWidgets('sin productos y caja cerrada: sigue habiendo un único '
        'primario ("Agregar producto"); "Abrir caja" baja a secundaria', (
      tester,
    ) async {
      await _montar(
        tester,
        _overrides(
          rol: RolUsuario.administrador,
          hayProductos: false,
          cajaAbierta: false,
        ),
      );

      expect(_botonesPrimarios(tester), ['Agregar producto']);
      expect(find.text('Abrir caja'), findsOneWidget);
      expect(find.text('Nueva venta'), findsNothing);
    });
  });
}
