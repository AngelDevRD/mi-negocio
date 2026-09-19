import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/cash_register/presentation/providers/cash_register_providers.dart';
import 'package:app_gestion/features/employees/domain/entities/empleado.dart';
import 'package:app_gestion/features/employees/domain/entities/pago_empleado.dart';
import 'package:app_gestion/features/employees/domain/repositories/employees_repository.dart';
import 'package:app_gestion/features/employees/presentation/providers/employees_providers.dart';
import 'package:app_gestion/features/employees/presentation/screens/employee_detail_screen.dart';
import 'package:app_gestion/features/employees/presentation/screens/employee_form_screen.dart';
import 'package:app_gestion/features/employees/presentation/screens/employees_list_screen.dart';
import 'package:app_gestion/features/employees/presentation/screens/payment_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

enum _Modo { datos, carga, error }

/// Empleados y pagos en memoria (sin drift: sus streams dejan timers).
class _RepoEmpleadosFalso implements EmployeesRepository {
  _RepoEmpleadosFalso({
    this.empleados = const [],
    this.pagos = const [],
    this.modo = _Modo.datos,
    this.modoPagos = _Modo.datos,
  });

  final List<Empleado> empleados;
  final List<PagoEmpleado> pagos;
  final _Modo modo;
  final _Modo modoPagos;

  /// Si se da, los guardados esperan a que se complete.
  Completer<void>? bloqueo;

  /// Si se da, los guardados fallan con este error.
  Failure? fallo;

  int consultas = 0;
  int guardados = 0;
  int pagosRegistrados = 0;
  final activaciones = <bool>[];

  @override
  Stream<List<Empleado>> watchEmpleados({TipoEmpleado? tipo, bool? activo}) {
    consultas++;
    switch (modo) {
      case _Modo.carga:
        return StreamController<List<Empleado>>().stream;
      case _Modo.error:
        return Stream.error(StateError('boom'));
      case _Modo.datos:
        return Stream.value([
          for (final e in empleados)
            if (tipo == null || e.tipo == tipo) e,
        ]);
    }
  }

  @override
  Future<Empleado?> obtenerEmpleado(String id) async {
    if (modo == _Modo.carga) return Completer<Empleado?>().future;
    if (modo == _Modo.error) throw StateError('boom');
    for (final e in empleados) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<Result<String>> crearEmpleado({
    required TipoEmpleado tipo,
    String? fotoPath,
    required String nombre,
    String? cedula,
    String? direccion,
    String? telefono,
    required DateTime fechaIngreso,
    Money? salario,
    String? frecuenciaPago,
    required String usuarioId,
  }) async {
    guardados++;
    await bloqueo?.future;
    if (fallo != null) return Result.fail(fallo!);
    return const Result.ok('nuevo');
  }

  @override
  Future<Result<void>> actualizarEmpleado({
    required String id,
    required TipoEmpleado tipo,
    String? fotoPath,
    required String nombre,
    String? cedula,
    String? direccion,
    String? telefono,
    required DateTime fechaIngreso,
    Money? salario,
    String? frecuenciaPago,
    required String usuarioId,
  }) async {
    guardados++;
    await bloqueo?.future;
    if (fallo != null) return Result.fail(fallo!);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  }) async {
    activaciones.add(activo);
    return const Result.ok(null);
  }

  @override
  Stream<List<PagoEmpleado>> watchPagos(String empleadoId) {
    switch (modoPagos) {
      case _Modo.carga:
        return StreamController<List<PagoEmpleado>>().stream;
      case _Modo.error:
        return Stream.error(StateError('boom'));
      case _Modo.datos:
        return Stream.value(pagos);
    }
  }

  @override
  Stream<Money> watchTotalPagado(String empleadoId) =>
      Stream.value(pagos.fold<Money>(Money.zero, (suma, p) => suma + p.monto));

  @override
  Future<Result<String>> registrarPago({
    required String empleadoId,
    required DateTime fecha,
    required Money monto,
    String? periodo,
    required bool saleDeCaja,
    required String usuarioId,
  }) async {
    pagosRegistrados++;
    await bloqueo?.future;
    if (fallo != null) return Result.fail(fallo!);
    return const Result.ok('pago');
  }
}

Empleado _empleado({
  String id = 'e1',
  String nombre = 'Ana Pérez',
  TipoEmpleado tipo = TipoEmpleado.ventas,
  bool activo = true,
  Money? salario = const Money(1500000),
  String? frecuencia = 'Quincenal',
}) => Empleado(
  id: id,
  tipo: tipo,
  nombre: nombre,
  fechaIngreso: DateTime(2024, 1, 15, 12).toUtc(),
  activo: activo,
  salario: salario,
  frecuenciaPago: frecuencia,
  cedula: '001-1234567-8',
);

PagoEmpleado _pago(String id, {bool deCaja = false, String? periodo}) =>
    PagoEmpleado(
      id: id,
      fecha: DateTime(2026, 2, 1, 12).toUtc(),
      monto: const Money(1500000),
      periodo: periodo,
      saleDeCaja: deCaja,
      usuarioNombre: 'Ana Admin',
    );

Future<GoRouter> _montar(
  WidgetTester tester,
  _RepoEmpleadosFalso repo, {
  String inicial = '/',
  bool asentar = true,
}) async {
  tester.view.physicalSize = const Size(420, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: inicial,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const EmployeesListScreen()),
      GoRoute(
        path: '/base',
        builder: (_, _) => const Scaffold(body: Center(child: Text('base'))),
      ),
      GoRoute(
        path: '/empleados/nuevo',
        builder: (_, _) => const EmployeeFormScreen(),
      ),
      GoRoute(
        path: '/empleados/:id',
        builder: (_, state) =>
            EmployeeDetailScreen(employeeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/empleados/:id/editar',
        builder: (_, state) =>
            EmployeeFormScreen(employeeId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/empleados/:id/pago',
        builder: (_, state) =>
            PaymentFormScreen(employeeId: state.pathParameters['id']!),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        employeesRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(_AuthFalso.new),
        sesionActualProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  // El controlador de sesión es asíncrono: se carga ya, para que las
  // pantallas (que lo leen con `ref.read`) encuentren la sesión.
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  // Con un indicador de carga eterno pumpAndSettle no termina nunca.
  asentar ? await tester.pumpAndSettle() : await tester.pump();
  return router;
}

/// Monta la pantalla [ruta] encima de una página base (así se puede salir).
Future<void> _montarEncima(
  WidgetTester tester,
  _RepoEmpleadosFalso repo,
  String ruta,
) async {
  final router = await _montar(tester, repo, inicial: '/base');
  unawaited(router.push(ruta));
  await tester.pumpAndSettle();
}

void main() {
  group('lista de empleados', () {
    testWidgets('cargando: indicador con mensaje', (tester) async {
      await _montar(
        tester,
        _RepoEmpleadosFalso(modo: _Modo.carga),
        asentar: false,
      );
      await tester.pump();

      expect(find.text('Cargando empleados...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error: mensaje humano y "Reintentar" vuelve a consultar', (
      tester,
    ) async {
      final repo = _RepoEmpleadosFalso(modo: _Modo.error);
      await _montar(tester, repo);

      expect(find.text('No se pudieron cargar los empleados.'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);
      final antes = repo.consultas;

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(repo.consultas, greaterThan(antes));
    });

    testWidgets('vacío: dice por qué, ofrece UNA acción y oculta el FAB', (
      tester,
    ) async {
      await _montar(tester, _RepoEmpleadosFalso());

      expect(find.text('Aún no hay empleados de ventas'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Agregar empleado'),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('con datos: tipo, salario, frecuencia y antigüedad; FAB sin '
        'hero', (tester) async {
      await _montar(
        tester,
        _RepoEmpleadosFalso(
          empleados: [
            _empleado(),
            _empleado(id: 'e2', nombre: 'Luis Gómez', activo: false),
          ],
        ),
      );

      expect(find.text('Ana Pérez'), findsOneWidget);
      // Etiqueta con ícono + texto (además de la pestaña "Ventas").
      expect(find.text('Ventas'), findsNWidgets(3));
      expect(find.byIcon(Icons.storefront_outlined), findsNWidgets(2));
      expect(find.text('RD\$ 15,000.00'), findsNWidgets(2));
      expect(find.text(' · Quincenal'), findsNWidgets(2));
      expect(find.textContaining('Antigüedad:'), findsNWidgets(2));
      expect(find.text('Inactivo'), findsOneWidget);

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.heroTag, isNull);
    });

    testWidgets('la pestaña Delivery vacía tiene su propio mensaje', (
      tester,
    ) async {
      await _montar(tester, _RepoEmpleadosFalso(empleados: [_empleado()]));

      await tester.tap(find.widgetWithText(Tab, 'Delivery'));
      await tester.pumpAndSettle();

      expect(find.text('Aún no hay empleados de delivery'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Agregar empleado'),
        findsOneWidget,
      );
    });
  });

  group('detalle del empleado', () {
    testWidgets('cargando y error con reintento', (tester) async {
      await _montar(
        tester,
        _RepoEmpleadosFalso(modo: _Modo.error),
        inicial: '/empleados/e1',
      );
      expect(find.text('No se pudo cargar el empleado.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('empleado inexistente: estado vacío', (tester) async {
      await _montar(tester, _RepoEmpleadosFalso(), inicial: '/empleados/e1');
      expect(find.text('Empleado no encontrado'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('datos: antigüedad, salario con formato, estado y la acción '
        'primaria "Registrar pago"', (tester) async {
      final ana = _empleado();
      await _montar(
        tester,
        _RepoEmpleadosFalso(empleados: [ana]),
        inicial: '/empleados/e1',
      );

      expect(find.text('Ana Pérez'), findsOneWidget);
      expect(find.text('Antigüedad'), findsOneWidget);
      expect(find.text(ana.tiempoTrabajado), findsOneWidget);
      expect(find.text('15/01/2024'), findsOneWidget);
      expect(find.text('RD\$ 15,000.00'), findsOneWidget);
      expect(find.text('Quincenal'), findsOneWidget);
      expect(find.text('Activo'), findsOneWidget);

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.heroTag, isNull);
      expect(find.text('Registrar pago'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.edit_outlined),
            )
            .tooltip,
        'Editar',
      );
    });

    testWidgets('pestaña Pagos: total y pagos con MoneyText y fecha local', (
      tester,
    ) async {
      await _montar(
        tester,
        _RepoEmpleadosFalso(
          empleados: [_empleado()],
          pagos: [
            _pago('p1', deCaja: true, periodo: '1-15 enero'),
            _pago('p2'),
          ],
        ),
        inicial: '/empleados/e1',
      );

      await tester.tap(find.widgetWithText(Tab, 'Pagos'));
      await tester.pumpAndSettle();

      expect(find.text('Total pagado'), findsOneWidget);
      expect(find.text('RD\$ 30,000.00'), findsOneWidget);
      expect(find.text('RD\$ 15,000.00'), findsNWidgets(2));
      expect(find.textContaining('01/02/2026'), findsNWidgets(2));
      expect(find.text('1-15 enero'), findsOneWidget);
      expect(find.text('Salió de caja'), findsOneWidget);
    });

    testWidgets('pestaña Pagos: vacía, con error y cargando', (tester) async {
      await _montar(
        tester,
        _RepoEmpleadosFalso(empleados: [_empleado()]),
        inicial: '/empleados/e1',
      );
      await tester.tap(find.widgetWithText(Tab, 'Pagos'));
      await tester.pumpAndSettle();
      expect(find.text('Aún no hay pagos registrados'), findsOneWidget);
    });

    testWidgets('pestaña Pagos con error: reintento', (tester) async {
      await _montar(
        tester,
        _RepoEmpleadosFalso(empleados: [_empleado()], modoPagos: _Modo.error),
        inicial: '/empleados/e1',
      );
      await tester.tap(find.widgetWithText(Tab, 'Pagos'));
      await tester.pumpAndSettle();
      expect(
        find.text('No se pudo cargar el historial de pagos.'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('pestaña Pagos cargando', (tester) async {
      await _montar(
        tester,
        _RepoEmpleadosFalso(empleados: [_empleado()], modoPagos: _Modo.carga),
        inicial: '/empleados/e1',
      );
      await tester.tap(find.widgetWithText(Tab, 'Pagos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Cargando pagos...'), findsOneWidget);
    });

    testWidgets('desactivar pide confirmación y luego avisa', (tester) async {
      final repo = _RepoEmpleadosFalso(empleados: [_empleado()]);
      await _montar(tester, repo, inicial: '/empleados/e1');

      await tester.scrollUntilVisible(
        find.text('Desactivar'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Desactivar'));
      await tester.pumpAndSettle();
      expect(find.text('¿Desactivar a Ana Pérez?'), findsOneWidget);
      expect(repo.activaciones, isEmpty);

      await tester.tap(find.widgetWithText(FilledButton, 'Desactivar'));
      await tester.pumpAndSettle();

      expect(repo.activaciones, [false]);
      expect(find.text('Empleado desactivado.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('formulario de empleado', () {
    testWidgets('sin cambios: salir NO pide confirmación', (tester) async {
      await _montarEncima(tester, _RepoEmpleadosFalso(), '/empleados/nuevo');
      expect(find.text('Nuevo empleado'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('¿Descartar cambios?'), findsNothing);
      expect(find.text('base'), findsOneWidget);
    });

    testWidgets('con cambios: pide confirmar; "Seguir editando" se queda y '
        '"Descartar" sale', (tester) async {
      await _montarEncima(tester, _RepoEmpleadosFalso(), '/empleados/nuevo');

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan');
      await tester.pump();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar cambios?'), findsOneWidget);

      await tester.tap(find.text('Seguir editando'));
      await tester.pumpAndSettle();
      expect(find.text('Nuevo empleado'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(find.text('base'), findsOneWidget);
    });

    testWidgets('doble toque en Guardar = UN solo guardado y sale sin '
        'preguntar', (tester) async {
      final repo = _RepoEmpleadosFalso()..bloqueo = Completer<void>();
      await _montarEncima(tester, repo, '/empleados/nuevo');

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan Pérez');
      final guardar = find.widgetWithText(FilledButton, 'Guardar');
      await tester.tap(guardar);
      await tester.tap(guardar);
      await tester.pump();

      expect(repo.guardados, 1);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
        isNull,
      );

      repo.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(repo.guardados, 1);
      expect(find.text('¿Descartar cambios?'), findsNothing);
      expect(find.text('base'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('error del repositorio: snackbar y el formulario sigue', (
      tester,
    ) async {
      final repo = _RepoEmpleadosFalso()
        ..fallo = const ValidationFailure('Ya existe un empleado así.');
      await _montarEncima(tester, repo, '/empleados/nuevo');

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan Pérez');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Ya existe un empleado así.'), findsOneWidget);
      expect(find.text('Nuevo empleado'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('nombre vacío: mensaje claro y no guarda', (tester) async {
      final repo = _RepoEmpleadosFalso();
      await _montarEncima(tester, repo, '/empleados/nuevo');

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pump();

      expect(find.text('Escribe el nombre del empleado'), findsOneWidget);
      expect(repo.guardados, 0);
    });

    testWidgets('edición: carga con error muestra reintento', (tester) async {
      await _montarEncima(
        tester,
        _RepoEmpleadosFalso(modo: _Modo.error),
        '/empleados/e1/editar',
      );
      expect(find.text('No se pudo cargar el empleado.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('formulario de pago', () {
    testWidgets('muestra a quién se paga y precarga el salario', (
      tester,
    ) async {
      await _montarEncima(
        tester,
        _RepoEmpleadosFalso(empleados: [_empleado()]),
        '/empleados/e1/pago',
      );

      expect(find.text('Pago a Ana Pérez'), findsOneWidget);
      expect(find.text('15,000.00'), findsOneWidget);
    });

    testWidgets('doble toque en Guardar = UN solo pago', (tester) async {
      final repo = _RepoEmpleadosFalso(empleados: [_empleado()])
        ..bloqueo = Completer<void>();
      await _montarEncima(tester, repo, '/empleados/e1/pago');

      final guardar = find.widgetWithText(FilledButton, 'Guardar');
      await tester.tap(guardar);
      await tester.tap(guardar);
      await tester.pump();

      expect(repo.pagosRegistrados, 1);

      repo.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(repo.pagosRegistrados, 1);
      expect(find.text('base'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('monto inválido: mensaje y NO guarda', (tester) async {
      final repo = _RepoEmpleadosFalso(empleados: [_empleado()]);
      await _montarEncima(tester, repo, '/empleados/e1/pago');

      await tester.enterText(find.byType(TextFormField).first, '1.2.3');
      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pump();

      expect(find.text('Monto inválido'), findsOneWidget);
      expect(repo.pagosRegistrados, 0);
      expect(tester.takeException(), isNull);
    });
  });
}
