import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/fechas.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/cash_register/presentation/providers/cash_register_providers.dart';
import 'package:app_gestion/features/expenses/domain/entities/gasto.dart';
import 'package:app_gestion/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:app_gestion/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:app_gestion/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:app_gestion/features/expenses/presentation/screens/expenses_list_screen.dart';
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

typedef _Registro = ({String categoria, String concepto, Money monto});

/// Gastos en memoria que respetan mes y categoría como el datasource.
class RepoGastosFalso implements ExpensesRepository {
  RepoGastosFalso([this.gastos = const []]);

  final List<Gasto> gastos;
  bool fallar = false;
  Completer<void>? bloqueo;
  Result<String> resultado = const Result.ok('g');
  final registros = <_Registro>[];

  @override
  Stream<List<Gasto>> watchGastos({
    DateTime? desde,
    DateTime? hasta,
    String? categoria,
  }) {
    if (fallar) return Stream.error(StateError('boom'));
    return Stream.value([
      for (final g in gastos)
        if ((categoria == null || g.categoria == categoria) &&
            (desde == null || !g.fecha.isBefore(desde)) &&
            (hasta == null || !g.fecha.isAfter(hasta)))
          g,
    ]);
  }

  @override
  Future<Result<String>> registrarGasto({
    required String categoria,
    required String concepto,
    required DateTime fecha,
    required Money monto,
    required bool saleDeCaja,
    required String usuarioId,
  }) async {
    registros.add((categoria: categoria, concepto: concepto, monto: monto));
    if (bloqueo != null) await bloqueo!.future;
    return resultado;
  }
}

Gasto _gasto(
  String concepto,
  String categoria,
  int cents, {
  DateTime? fecha,
  bool deCaja = false,
}) => Gasto(
  id: concepto,
  categoria: categoria,
  concepto: concepto,
  fecha: (fecha ?? DateTime.now()).toUtc(),
  monto: Money(cents),
  saleDeCaja: deCaja,
  usuarioNombre: 'Ana Admin',
);

Future<void> _montarLista(WidgetTester tester, RepoGastosFalso repo) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const ExpensesListScreen()),
      GoRoute(
        path: '/gastos/nuevo',
        builder: (_, _) => const Scaffold(body: Text('formulario')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [expensesRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

/// Monta el formulario encima de una pantalla base (lo cierra con `pop`).
Future<void> _montarFormulario(
  WidgetTester tester,
  RepoGastosFalso repo,
) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        expensesRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(_AuthFalso.new),
        sesionActualProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: Text('base')),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  unawaited(
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute<void>(builder: (_) => const ExpenseFormScreen()),
        ),
  );
  await tester.pumpAndSettle();
}

Finder _campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

void main() {
  final mesActual = nombreDelMes(DateTime.now());

  group('lista de gastos', () {
    final gastos = [
      _gasto('Factura de luz', 'Luz', 385000),
      _gasto('Recibo del agua', 'Agua', 50000, deCaja: true),
    ];

    testWidgets('total del mes arriba (con cuántos gastos) y el mes con su '
        'nombre', (tester) async {
      await _montarLista(tester, RepoGastosFalso(gastos));

      expect(find.text(mesActual), findsOneWidget);
      expect(find.text('Total del mes'), findsOneWidget);
      expect(find.text('2 gastos'), findsOneWidget);
      expect(find.text('RD\$ 4,350.00'), findsOneWidget);
    });

    testWidgets('cada fila lleva la categoría con ícono y texto, y avisa si '
        'salió de caja', (tester) async {
      await _montarLista(tester, RepoGastosFalso(gastos));

      expect(find.textContaining('Luz · '), findsOneWidget);
      expect(find.textContaining('Agua · '), findsOneWidget);
      expect(find.byIcon(Icons.bolt_outlined), findsWidgets);
      expect(find.byIcon(Icons.water_drop_outlined), findsWidgets);
      expect(find.text('Salió de caja'), findsOneWidget);
      expect(find.text('RD\$ 3,850.00'), findsOneWidget);
      expect(find.text('RD\$ 500.00'), findsOneWidget);
    });

    testWidgets('los chips de categoría filtran y el total se ajusta', (
      tester,
    ) async {
      await _montarLista(tester, RepoGastosFalso(gastos));

      await tester.tap(find.widgetWithText(ChoiceChip, 'Luz'));
      await tester.pumpAndSettle();

      expect(find.text('Factura de luz'), findsOneWidget);
      expect(find.text('Recibo del agua'), findsNothing);
      expect(find.text('1 gasto'), findsOneWidget);
      expect(find.text('RD\$ 3,850.00'), findsNWidgets(2)); // total y fila

      await tester.tap(find.widgetWithText(ChoiceChip, 'Todas'));
      await tester.pumpAndSettle();
      expect(find.text('Recibo del agua'), findsOneWidget);
    });

    testWidgets('las flechas de mes tienen tooltip y cambian el mes', (
      tester,
    ) async {
      await _montarLista(tester, RepoGastosFalso(gastos));
      final anterior = nombreDelMes(
        DateTime(DateTime.now().year, DateTime.now().month - 1),
      );

      await tester.tap(find.byTooltip('Mes anterior'));
      await tester.pumpAndSettle();

      expect(find.text(anterior), findsOneWidget);
      expect(find.byTooltip('Mes siguiente'), findsOneWidget);
      // Ese mes no tiene gastos: estado vacío que dice cuál mes.
      expect(find.text('Sin gastos en $anterior'), findsOneWidget);
    });

    testWidgets('mes sin gastos: explica por qué y ofrece "Nuevo gasto"', (
      tester,
    ) async {
      await _montarLista(tester, RepoGastosFalso());

      expect(find.text('Sin gastos en $mesActual'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Nuevo gasto'), findsOneWidget);
      expect(find.text('Sin resultados para este filtro'), findsNothing);
      // Una sola acción: el botón del estado vacío, sin FAB que la repita.
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('categoría sin gastos: "Sin resultados" y "Quitar filtro"', (
      tester,
    ) async {
      await _montarLista(tester, RepoGastosFalso(gastos));

      await tester.tap(find.widgetWithText(ChoiceChip, 'Alquiler'));
      await tester.pumpAndSettle();

      expect(find.text('Sin resultados para este filtro'), findsOneWidget);
      expect(find.text('Sin gastos en $mesActual'), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.text('Quitar filtro'));
      await tester.pumpAndSettle();
      expect(find.text('Factura de luz'), findsOneWidget);
    });

    testWidgets('error: mensaje humano y "Reintentar" recarga', (tester) async {
      final repo = RepoGastosFalso(gastos)..fallar = true;
      await _montarLista(tester, repo);

      expect(find.text('No se pudieron cargar los gastos.'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);

      repo.fallar = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Factura de luz'), findsOneWidget);
    });

    testWidgets('el FAB de Nuevo gasto abre el formulario', (tester) async {
      await _montarLista(tester, RepoGastosFalso(gastos));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('formulario'), findsOneWidget);
    });
  });

  group('formulario de gasto', () {
    Future<void> llenar(WidgetTester tester) async {
      await tester.enterText(_campo('Concepto'), 'Factura de luz');
      await tester.enterText(_campo('Monto'), '1500.50');
    }

    testWidgets('doble toque en guardar = UN solo guardado', (tester) async {
      final repo = RepoGastosFalso()..bloqueo = Completer<void>();
      await _montarFormulario(tester, repo);
      await llenar(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();

      repo.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(repo.registros, hasLength(1));
      expect(repo.registros.single.monto, const Money(150050));
      expect(repo.registros.single.concepto, 'Factura de luz');
      expect(find.text('base'), findsOneWidget); // volvió
    });

    testWidgets('el teclado: "Siguiente" en concepto y "Listo" en monto '
        'guarda', (tester) async {
      final repo = RepoGastosFalso();
      await _montarFormulario(tester, repo);
      await llenar(tester);

      await tester.tap(_campo('Monto'));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(repo.registros, hasLength(1));
    });

    testWidgets('las acciones de teclado de los campos', (tester) async {
      await _montarFormulario(tester, RepoGastosFalso());

      TextInputAction? accion(String etiqueta) => tester
          .widget<TextField>(
            find.descendant(
              of: _campo(etiqueta),
              matching: find.byType(TextField),
            ),
          )
          .textInputAction;

      expect(accion('Concepto'), TextInputAction.next);
      expect(accion('Monto'), TextInputAction.done);
    });

    testWidgets('un error del repositorio sale en un snackbar y el formulario '
        'queda abierto', (tester) async {
      final repo = RepoGastosFalso()
        ..resultado = const Result.fail(
          BusinessRuleFailure('Debe abrir una caja.'),
        );
      await _montarFormulario(tester, repo);
      await llenar(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Debe abrir una caja.'), findsOneWidget);
      expect(find.text('Nuevo gasto'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('monto vacío y concepto vacío se validan sin guardar', (
      tester,
    ) async {
      final repo = RepoGastosFalso();
      await _montarFormulario(tester, repo);

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pump();

      expect(find.text('Obligatorio'), findsNWidgets(2));
      expect(repo.registros, isEmpty);
    });
  });
}
