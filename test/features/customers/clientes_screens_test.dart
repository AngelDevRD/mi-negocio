import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/customers/domain/entities/cliente.dart';
import 'package:app_gestion/features/customers/presentation/providers/customers_providers.dart';
import 'package:app_gestion/features/customers/presentation/screens/cliente_detail_screen.dart';
import 'package:app_gestion/features/customers/presentation/screens/cliente_form_screen.dart';
import 'package:app_gestion/features/customers/presentation/screens/clientes_list_screen.dart';
import 'package:app_gestion/features/profile/presentation/providers/profile_providers.dart';
import 'package:app_gestion/features/sales/presentation/widgets/selector_metodo_pago.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'repo_clientes_falso.dart';

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

Cliente _cliente(
  String id,
  String nombre, {
  int saldo = 0,
  String? telefono,
  Money? limite,
  bool activo = true,
}) => Cliente(
  id: id,
  nombre: nombre,
  telefono: telefono,
  limiteCredito: limite,
  activo: activo,
  saldo: Money(saldo),
);

/// Ruta destino de prueba: muestra su ubicación para poder comprobarla.
GoRoute _destino(String path) => GoRoute(
  path: path,
  builder: (_, estado) =>
      Scaffold(body: Center(child: Text('destino:${estado.uri.path}'))),
);

Future<void> _montar(
  WidgetTester tester, {
  required RepoClientesFalso repo,
  required Widget home,
  RolUsuario rol = RolUsuario.administrador,
  List<GoRoute> destinos = const [],
  List<String>? compartidos,
}) async {
  addTearDown(repo.cerrar);
  // La pantalla se EMPUJA sobre una base: así `context.pop()` (al guardar o
  // eliminar) tiene a dónde volver, como en la app.
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
  final List<Override> overrides = [
    customersRepositoryProvider.overrideWithValue(repo),
    authControllerProvider.overrideWith(() => _AuthFalso(rol)),
    negocioProvider.overrideWith((ref) => Stream.value(null)),
    if (compartidos != null)
      compartirTextoProvider.overrideWithValue((texto) async {
        compartidos.add(texto);
      }),
  ];
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
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

/// Botón "Registrar abono" DEL DIÁLOGO (la pantalla tiene otro con el mismo
/// texto).
final _botonAbono = find.descendant(
  of: find.byType(AlertDialog),
  matching: find.widgetWithText(FilledButton, 'Registrar abono'),
);

Finder _fila(String nombre) => find.widgetWithText(ListTile, nombre);

void main() {
  group('lista de clientes', () {
    RepoClientesFalso repoConDatos() => RepoClientesFalso([
      _cliente('c1', 'Doña Rosa', saldo: 30000, telefono: '809-111-2222'),
      _cliente('c2', 'Juan Pérez'),
      _cliente('c3', 'Ana Gómez', saldo: -5000),
      _cliente('c4', 'Pedro Díaz', saldo: 15000, telefono: '829-333-4444'),
    ]);

    testWidgets('por defecto filtra "Con deuda" y muestra el total por '
        'cobrar (suma de saldos positivos)', (tester) async {
      await _montar(
        tester,
        repo: repoConDatos(),
        home: const ClientesListScreen(),
      );

      expect(_fila('Doña Rosa'), findsOneWidget);
      expect(_fila('Pedro Díaz'), findsOneWidget);
      expect(_fila('Juan Pérez'), findsNothing);
      expect(_fila('Ana Gómez'), findsNothing);
      expect(find.text('Total por cobrar'), findsOneWidget);
      // 300 + 150; el saldo a favor de Ana NO se resta.
      expect(find.text('RD\$ 450.00'), findsOneWidget);
    });

    testWidgets('"Todos" muestra Debe / A favor / Al día con texto', (
      tester,
    ) async {
      await _montar(
        tester,
        repo: repoConDatos(),
        home: const ClientesListScreen(),
      );

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      expect(find.text('Debe'), findsNWidgets(2));
      expect(find.text('A favor'), findsOneWidget);
      expect(find.text('Al día'), findsOneWidget);
      // El saldo a favor se muestra en positivo junto a su texto.
      expect(find.text('RD\$ 50.00'), findsOneWidget);
    });

    testWidgets('busca por nombre y por teléfono', (tester) async {
      await _montar(
        tester,
        repo: repoConDatos(),
        home: const ClientesListScreen(),
      );
      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'juan');
      await tester.pumpAndSettle();
      expect(_fila('Juan Pérez'), findsOneWidget);
      expect(_fila('Doña Rosa'), findsNothing);

      await tester.enterText(find.byType(TextField), '829-333');
      await tester.pumpAndSettle();
      expect(_fila('Pedro Díaz'), findsOneWidget);
      expect(_fila('Juan Pérez'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('Sin resultados'), findsOneWidget);
    });

    testWidgets('sin clientes: estado vacío con "Agregar cliente"', (
      tester,
    ) async {
      await _montar(
        tester,
        repo: RepoClientesFalso(),
        home: const ClientesListScreen(),
        destinos: [_destino('/clientes/nuevo')],
      );

      expect(find.text('Aún no tienes clientes'), findsOneWidget);
      // Una sola acción: el botón del estado vacío, sin FAB que la repita.
      expect(find.byType(FloatingActionButton), findsNothing);
      await tester.tap(find.text('Agregar cliente'));
      await tester.pumpAndSettle();
      expect(find.text('destino:/clientes/nuevo'), findsOneWidget);
    });

    testWidgets('con clientes pero sin deudas: "Nadie te debe"', (
      tester,
    ) async {
      await _montar(
        tester,
        repo: RepoClientesFalso([_cliente('c1', 'Juan Pérez')]),
        home: const ClientesListScreen(),
      );

      expect(find.text('Nadie te debe'), findsOneWidget);
      expect(find.text('RD\$ 0.00'), findsOneWidget); // total por cobrar
    });

    testWidgets('el FAB "Nuevo cliente" y tocar una fila navegan', (
      tester,
    ) async {
      await _montar(
        tester,
        repo: repoConDatos(),
        home: const ClientesListScreen(),
        destinos: [_destino('/clientes/nuevo'), _destino('/clientes/:id')],
      );

      await tester.tap(_fila('Doña Rosa'));
      await tester.pumpAndSettle();
      expect(find.text('destino:/clientes/c1'), findsOneWidget);
    });

    testWidgets('el FAB abre el formulario de cliente nuevo', (tester) async {
      await _montar(
        tester,
        repo: repoConDatos(),
        home: const ClientesListScreen(),
        destinos: [_destino('/clientes/nuevo')],
      );

      await tester.tap(find.text('Nuevo cliente'));
      await tester.pumpAndSettle();
      expect(find.text('destino:/clientes/nuevo'), findsOneWidget);
    });
  });

  group('formulario de cliente', () {
    testWidgets('el cajero NO ve el límite de crédito', (tester) async {
      await _montar(
        tester,
        repo: RepoClientesFalso(),
        home: const ClienteFormScreen(),
        rol: RolUsuario.cajero,
      );

      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Teléfono (opcional)'), findsOneWidget);
      expect(find.text('Límite de crédito (opcional)'), findsNothing);
    });

    testWidgets('el administrador SÍ ve el límite y lo guarda', (tester) async {
      final repo = RepoClientesFalso();
      await _montar(tester, repo: repo, home: const ClienteFormScreen());

      expect(find.text('Límite de crédito (opcional)'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Doña Rosa',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Límite de crédito (opcional)'),
        '500',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(repo.creados.single.nombre, 'Doña Rosa');
      expect(repo.creados.single.limite, const Money(50000));
    });

    testWidgets('el cajero crea al cliente SIN límite', (tester) async {
      final repo = RepoClientesFalso();
      await _montar(
        tester,
        repo: repo,
        home: const ClienteFormScreen(),
        rol: RolUsuario.cajero,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Juan Pérez',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(repo.creados.single.nombre, 'Juan Pérez');
      expect(repo.creados.single.limite, isNull);
    });

    testWidgets('nombre vacío muestra el error y no crea nada', (tester) async {
      final repo = RepoClientesFalso();
      await _montar(tester, repo: repo, home: const ClienteFormScreen());

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('El nombre es obligatorio.'), findsOneWidget);
      expect(repo.creados, isEmpty);
    });

    testWidgets('editar: el cajero conserva el límite que ya tenía', (
      tester,
    ) async {
      final repo = RepoClientesFalso([
        _cliente('c1', 'Doña Rosa', limite: const Money(50000)),
      ]);
      await _montar(
        tester,
        repo: repo,
        home: const ClienteFormScreen(clienteId: 'c1'),
        rol: RolUsuario.cajero,
      );

      expect(find.text('Límite de crédito (opcional)'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Rosa Pérez',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(repo.actualizados.single.limite, const Money(50000));
      expect(repo.clientes.single.nombre, 'Rosa Pérez');
    });
  });

  group('detalle de cliente', () {
    RepoClientesFalso repoRosaDebe() {
      final repo = RepoClientesFalso([
        _cliente(
          'c1',
          'Doña Rosa',
          telefono: '809-111-2222',
          limite: const Money(100000),
        ),
      ]);
      repo.cargo('c1', 30000);
      return repo;
    }

    testWidgets('muestra el saldo grande, el límite y el historial', (
      tester,
    ) async {
      final repo = repoRosaDebe();
      repo.movimiento(
        'c1',
        MovimientoCliente(
          id: 'ma',
          tipo: TipoMovimientoCliente.abono,
          monto: const Money(-10000),
          metodoPago: MetodoPago.tarjeta,
          fecha: DateTime(2026, 1, 16, 9),
          usuarioNombre: 'Ana Admin',
        ),
      );
      repo.movimiento(
        'c1',
        MovimientoCliente(
          id: 'mx',
          tipo: TipoMovimientoCliente.anulacion,
          monto: const Money(-5000),
          ventaId: 'venta-x',
          fecha: DateTime(2026, 1, 17, 9),
          usuarioNombre: 'Ana Admin',
        ),
      );
      await _montar(
        tester,
        repo: repo,
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );

      expect(find.text('Debe'), findsOneWidget);
      expect(find.text('RD\$ 150.00'), findsOneWidget); // 300 - 100 - 50
      expect(
        find.textContaining('Límite de crédito RD\$ 1,000.00'),
        findsOneWidget,
      );
      expect(find.text('Historial'), findsOneWidget);
      expect(find.text('Venta fiada'), findsOneWidget);
      expect(find.text('Abono (Tarjeta)'), findsOneWidget);
      expect(find.text('Venta anulada'), findsOneWidget);
      expect(find.text('Registrar abono'), findsOneWidget);
    });

    testWidgets('sin deuda oculta "Registrar abono" y "Compartir saldo"', (
      tester,
    ) async {
      await _montar(
        tester,
        repo: RepoClientesFalso([_cliente('c1', 'Juan Pérez')]),
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );

      expect(find.text('Al día'), findsOneWidget);
      expect(find.text('Registrar abono'), findsNothing);
      expect(find.text('Compartir saldo'), findsNothing);
      expect(find.text('Sin movimientos'), findsOneWidget);
    });

    testWidgets('con saldo a favor: texto "Saldo a favor" y sin abono', (
      tester,
    ) async {
      await _montar(
        tester,
        repo: RepoClientesFalso([_cliente('c1', 'Ana', saldo: -5000)]),
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );

      expect(find.text('Saldo a favor'), findsOneWidget);
      expect(find.text('RD\$ 50.00'), findsOneWidget);
      expect(find.text('Registrar abono'), findsNothing);
    });

    testWidgets('abono en efectivo: registra, avisa y actualiza el saldo', (
      tester,
    ) async {
      final repo = repoRosaDebe();
      await _montar(
        tester,
        repo: repo,
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );

      await tester.tap(find.text('Registrar abono'));
      await tester.pumpAndSettle();
      // Precargado con el saldo (todo el texto seleccionado).
      final campo = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Monto del abono'),
      );
      expect(campo.controller!.text, '300.00');
      expect(campo.controller!.selection.end, campo.controller!.text.length);

      await tester.enterText(
        find.widgetWithText(TextField, 'Monto del abono'),
        '100',
      );
      await tester.tap(_botonAbono);
      await tester.pumpAndSettle();

      expect(repo.abonos.single.monto, const Money(10000));
      expect(repo.abonos.single.metodo, MetodoPago.efectivo);
      expect(find.text('Abono registrado · Saldo RD\$ 200.00'), findsOneWidget);
      expect(find.text('RD\$ 200.00'), findsWidgets);
      expect(find.text('Abono (Efectivo)'), findsOneWidget);
    });

    testWidgets('el chip "Todo el saldo" repone el monto completo', (
      tester,
    ) async {
      await _montar(
        tester,
        repo: repoRosaDebe(),
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );
      await tester.tap(find.text('Registrar abono'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Monto del abono'),
        '5',
      );

      await tester.tap(find.text('Todo el saldo'));
      await tester.pump();

      final campo = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Monto del abono'),
      );
      expect(campo.controller!.text, '300.00');
    });

    testWidgets('abono mayor que el saldo: muestra el error y CONSERVA el '
        'diálogo', (tester) async {
      final repo = repoRosaDebe();
      await _montar(
        tester,
        repo: repo,
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );
      await tester.tap(find.text('Registrar abono'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Monto del abono'),
        '500',
      );
      await tester.tap(_botonAbono);
      await tester.pumpAndSettle();

      expect(find.textContaining('supera el saldo pendiente'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(repo.abonos, isEmpty);
    });

    testWidgets('abono en efectivo con la caja cerrada: error y diálogo '
        'abierto; con tarjeta sí pasa', (tester) async {
      final repo = repoRosaDebe()..cajaAbierta = false;
      await _montar(
        tester,
        repo: repo,
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );
      await tester.tap(find.text('Registrar abono'));
      await tester.pumpAndSettle();

      await tester.tap(_botonAbono);
      await tester.pumpAndSettle();
      expect(find.textContaining('Debe abrir una caja'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(SelectorMetodoPago),
          matching: find.text('Tarjeta'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(_botonAbono);
      await tester.pumpAndSettle();

      expect(repo.abonos.single.metodo, MetodoPago.tarjeta);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('doble toque en "Registrar abono" registra UN solo abono', (
      tester,
    ) async {
      final repo = repoRosaDebe();
      await _montar(
        tester,
        repo: repo,
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );
      await tester.tap(find.text('Registrar abono'));
      await tester.pumpAndSettle();

      final boton = _botonAbono;
      await tester.tap(boton);
      await tester.tap(boton);
      await tester.pumpAndSettle();

      expect(repo.llamadasAbono, 1);
    });

    testWidgets('el abono no ofrece "Fiado" como método', (tester) async {
      await _montar(
        tester,
        repo: repoRosaDebe(),
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );
      await tester.tap(find.text('Registrar abono'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SelectorMetodoPago),
          matching: find.text('Fiado'),
        ),
        findsNothing,
      );
    });

    testWidgets('"Compartir saldo" comparte el texto con nombre, negocio y '
        'saldo', (tester) async {
      final compartidos = <String>[];
      await _montar(
        tester,
        repo: repoRosaDebe(),
        home: const ClienteDetailScreen(clienteId: 'c1'),
        compartidos: compartidos,
      );

      await tester.tap(find.text('Compartir saldo'));
      await tester.pumpAndSettle();

      expect(compartidos, [
        'Hola Doña Rosa, tu saldo pendiente en el negocio es RD\$ 300.00.',
      ]);
    });

    testWidgets('tocar un cargo abre el detalle de esa venta', (tester) async {
      await _montar(
        tester,
        repo: repoRosaDebe(),
        home: const ClienteDetailScreen(clienteId: 'c1'),
        destinos: [_destino('/ventas/:id')],
      );

      await tester.tap(find.text('Venta fiada'));
      await tester.pumpAndSettle();

      expect(find.text('destino:/ventas/venta-c1'), findsOneWidget);
    });

    Future<void> abrirMenu(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Más opciones'));
      await tester.pumpAndSettle();
    }

    testWidgets('el cajero solo ve "Editar" en el menú', (tester) async {
      await _montar(
        tester,
        repo: repoRosaDebe(),
        home: const ClienteDetailScreen(clienteId: 'c1'),
        rol: RolUsuario.cajero,
      );

      await abrirMenu(tester);

      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Desactivar'), findsNothing);
      expect(find.text('Eliminar'), findsNothing);
    });

    testWidgets('el administrador puede desactivar y activar', (tester) async {
      final repo = repoRosaDebe();
      await _montar(
        tester,
        repo: repo,
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );

      await abrirMenu(tester);
      expect(find.text('Eliminar'), findsOneWidget);
      await tester.tap(find.text('Desactivar'));
      await tester.pumpAndSettle();

      expect(repo.clientes.single.activo, isFalse);
      expect(find.text('Cliente desactivado'), findsOneWidget);
      expect(
        find.textContaining('Cliente inactivo: no se le puede fiar'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 6));
      await abrirMenu(tester);
      expect(find.text('Activar'), findsOneWidget);
    });

    testWidgets('eliminar con movimientos muestra el mensaje del repositorio '
        'y no elimina', (tester) async {
      final repo = repoRosaDebe();
      await _montar(
        tester,
        repo: repo,
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );

      await abrirMenu(tester);
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      expect(find.text('Eliminar cliente'), findsOneWidget); // confirmación
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('desactívalo'), findsOneWidget);
      expect(repo.clientes, hasLength(1));
    });

    testWidgets('eliminar un cliente sin movimientos lo elimina y vuelve', (
      tester,
    ) async {
      final repo = RepoClientesFalso([_cliente('c1', 'Juan Pérez')]);
      await _montar(
        tester,
        repo: repo,
        home: const ClienteDetailScreen(clienteId: 'c1'),
      );

      await abrirMenu(tester);
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(repo.clientes, isEmpty);
      expect(find.text('base'), findsOneWidget);
    });
  });
}
