import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/cash_register/domain/entities/caja_sesion.dart';
import 'package:app_gestion/features/cash_register/domain/entities/resumen_turno.dart';
import 'package:app_gestion/features/cash_register/domain/repositories/cash_register_repository.dart';
import 'package:app_gestion/features/cash_register/presentation/providers/cash_register_providers.dart';
import 'package:app_gestion/features/cash_register/presentation/screens/cash_register_close_screen.dart';
import 'package:app_gestion/features/cash_register/presentation/screens/cash_register_screen.dart';
import 'package:app_gestion/features/cash_register/presentation/screens/cash_register_session_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

CajaMovimiento _mov(
  String id,
  TipoCajaMovimiento tipo,
  int cents, {
  String? motivo,
}) => CajaMovimiento(
  id: id,
  tipo: tipo,
  monto: Money(cents),
  motivo: motivo,
  fecha: DateTime.now().toUtc(),
);

CajaSesion _sesion({
  int apertura = 100000,
  List<CajaMovimiento> movimientos = const [],
}) => CajaSesion(
  id: 'ses-1',
  fechaApertura: DateTime.now().toUtc(),
  montoApertura: Money(apertura),
  usuarioAperturaNombre: 'Ana Admin',
  estado: EstadoCajaSesion.abierta,
  movimientos: movimientos,
);

const _resumen = ResumenTurno(
  montoApertura: Money(100000),
  ventasEfectivo: Money(30000),
  ventasTarjeta: Money(15000),
  ventasTransferencia: Money(45000),
  ventasFiado: Money(60000),
  abonosEfectivo: Money(10000),
  abonosTarjeta: Money.zero,
  abonosTransferencia: Money(20000),
  entradasManuales: Money(5000),
  salidasManuales: Money(2000),
  gastos: Money(1200),
  compras: Money.zero,
  pagosEmpleados: Money.zero,
  efectivoEsperado: Money(142800),
);

typedef _Registro = ({bool entrada, Money monto, String motivo});

/// Caja en memoria (sin drift: sus streams dejan timers pendientes en tests de
/// widgets). Lo que registra se refleja en la sesión, como haría la base.
class RepoCajaFalso implements CashRegisterRepository {
  RepoCajaFalso({
    this.sesion,
    this.historial = const [],
    this.resumen = _resumen,
  });

  CajaSesion? sesion;
  final List<CajaSesion> historial;
  final ResumenTurno resumen;
  final registrados = <_Registro>[];

  /// Si no es `null`, `registrarMovimientoManual` espera a que se complete.
  Completer<void>? bloqueo;

  /// Resultado que devuelve `registrarMovimientoManual`.
  Result<void> resultado = const Result.ok(null);

  final _cambios = StreamController<CajaSesion?>.broadcast();

  @override
  Stream<CajaSesion?> watchSesionActual() async* {
    yield sesion;
    yield* _cambios.stream;
  }

  @override
  Stream<List<CajaSesion>> watchHistorial() => Stream.value(historial);

  @override
  Future<CajaSesion?> obtenerSesion(String id) async =>
      historial.where((s) => s.id == id).firstOrNull ?? sesion;

  @override
  Future<Money> obtenerMontoSugeridoApertura() async => Money.zero;

  @override
  Future<Result<void>> cerrarCaja({
    required Money montoContado,
    required Money montoDejarSiguiente,
    required String usuarioId,
  }) async => const Result.ok(null);

  @override
  Future<Result<void>> registrarMovimientoManual({
    required bool entrada,
    required Money monto,
    required String motivo,
    required String usuarioId,
  }) async {
    registrados.add((entrada: entrada, monto: monto, motivo: motivo));
    if (bloqueo != null) await bloqueo!.future;
    if (resultado.isOk && sesion != null) {
      sesion = sesion!.copyWith(
        movimientos: [
          _mov(
            'nuevo-${registrados.length}',
            entrada
                ? TipoCajaMovimiento.entradaManual
                : TipoCajaMovimiento.salidaManual,
            entrada ? monto.cents : -monto.cents,
            motivo: motivo,
          ),
          ...sesion!.movimientos,
        ],
      );
      _cambios.add(sesion);
    }
    return resultado;
  }

  @override
  Future<ResumenTurno?> obtenerResumenTurno(String sesionId) async => resumen;
}

Future<void> _montar(
  WidgetTester tester,
  Widget home,
  RepoCajaFalso repo, {
  RolUsuario rol = RolUsuario.administrador,
}) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cashRegisterRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(() => _AuthFalso(rol)),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: home),
    ),
  );
  await tester.pumpAndSettle();
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  await tester.pumpAndSettle();
}

/// Deja pasar el snackbar (un Timer pendiente al terminar rompe el test).
Future<void> _esperarSnackbar(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 6));

Finder _campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

void main() {
  group('pestaña Caja abierta', () {
    testWidgets('tarjeta neutra: etiqueta con texto, efectivo en caja, '
        'apertura y quién abrió', (tester) async {
      final repo = RepoCajaFalso(
        sesion: _sesion(
          apertura: 100000,
          movimientos: [_mov('v1', TipoCajaMovimiento.venta, 30000)],
        ),
      );
      await _montar(tester, const CashRegisterScreen(), repo);

      expect(find.text('Caja abierta'), findsOneWidget);
      expect(find.text('Efectivo en caja'), findsOneWidget);
      expect(find.text('RD\$ 1,300.00'), findsOneWidget);
      expect(find.text('Abierta por Ana Admin'), findsOneWidget);
      expect(find.text('RD\$ 1,000.00'), findsOneWidget); // apertura
    });

    testWidgets('movimientos con signo y color: "+" en éxito, "-" en error, '
        'con motivo', (tester) async {
      final repo = RepoCajaFalso(
        sesion: _sesion(
          movimientos: [
            _mov(
              's',
              TipoCajaMovimiento.salidaManual,
              -3000,
              motivo: 'Delivery',
            ),
            _mov('e', TipoCajaMovimiento.entradaManual, 5000, motivo: 'Cambio'),
            _mov('v', TipoCajaMovimiento.venta, 30000),
          ],
        ),
      );
      await _montar(tester, const CashRegisterScreen(), repo);

      final contexto = tester.element(find.byType(Scaffold).first);
      final exito = contexto.appColors.exito;
      final error = Theme.of(contexto).colorScheme.error;

      Color? colorDe(String texto) =>
          tester.widget<Text>(find.text(texto)).style?.color;

      expect(colorDe('-RD\$ 30.00'), error);
      expect(colorDe('+RD\$ 50.00'), exito);
      expect(colorDe('+RD\$ 300.00'), exito);
      expect(find.text('Delivery'), findsOneWidget);
      expect(find.text('Cambio'), findsOneWidget);
      expect(find.text('Salida manual'), findsOneWidget);
      expect(find.text('Entrada manual'), findsOneWidget);
    });

    testWidgets('sin movimientos muestra un estado vacío con texto', (
      tester,
    ) async {
      await _montar(
        tester,
        const CashRegisterScreen(),
        RepoCajaFalso(sesion: _sesion()),
      );

      expect(
        find.text('Aún no hay movimientos en esta sesión'),
        findsOneWidget,
      );
    });

    testWidgets('el administrador ve Cerrar caja, Entrada y Salida', (
      tester,
    ) async {
      await _montar(
        tester,
        const CashRegisterScreen(),
        RepoCajaFalso(sesion: _sesion()),
      );

      expect(find.widgetWithText(FilledButton, 'Cerrar caja'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Entrada'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Salida'), findsOneWidget);
    });

    testWidgets('el cajero NO ve Cerrar caja pero sí Entrada y Salida', (
      tester,
    ) async {
      await _montar(
        tester,
        const CashRegisterScreen(),
        RepoCajaFalso(sesion: _sesion()),
        rol: RolUsuario.cajero,
      );

      expect(find.text('Cerrar caja'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Entrada'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Salida'), findsOneWidget);
    });

    testWidgets('el historial está en una pestaña con texto, no en un '
        'ícono suelto', (tester) async {
      final cerrada = CajaSesion(
        id: 'vieja',
        fechaApertura: DateTime.utc(2026, 1, 1, 12),
        fechaCierre: DateTime.utc(2026, 1, 1, 22),
        montoApertura: const Money(100000),
        diferencia: const Money(-500),
        usuarioAperturaNombre: 'Ana Admin',
        usuarioCierreNombre: 'Ana Admin',
        estado: EstadoCajaSesion.cerrada,
      );
      await _montar(
        tester,
        const CashRegisterScreen(),
        RepoCajaFalso(sesion: _sesion(), historial: [cerrada]),
      );

      expect(find.widgetWithText(Tab, 'Hoy'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Historial'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsNothing);

      await tester.tap(find.widgetWithText(Tab, 'Historial'));
      await tester.pumpAndSettle();

      expect(find.text('Faltante'), findsOneWidget);
      expect(find.textContaining('Cerrada por Ana Admin'), findsOneWidget);
    });

    testWidgets('historial vacío explica qué aparecerá ahí', (tester) async {
      await _montar(
        tester,
        const CashRegisterScreen(),
        RepoCajaFalso(sesion: _sesion()),
      );

      await tester.tap(find.widgetWithText(Tab, 'Historial'));
      await tester.pumpAndSettle();

      expect(find.text('Aún no hay cierres de caja'), findsOneWidget);
    });
  });

  group('pestaña Caja cerrada', () {
    testWidgets('muestra "La caja está cerrada" con el botón primario '
        '"Abrir caja" y sin Entrada/Salida', (tester) async {
      await _montar(tester, const CashRegisterScreen(), RepoCajaFalso());

      expect(find.text('La caja está cerrada'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Abrir caja'), findsOneWidget);
      expect(find.text('Entrada'), findsNothing);
      expect(find.text('Salida'), findsNothing);
    });

    testWidgets('"Abrir caja" reutiliza el diálogo de apertura', (
      tester,
    ) async {
      await _montar(tester, const CashRegisterScreen(), RepoCajaFalso());

      await tester.tap(find.widgetWithText(FilledButton, 'Abrir caja'));
      await tester.pumpAndSettle();

      expect(find.text('Monto de apertura'), findsOneWidget);
    });
  });

  group('diálogo de entrada y salida', () {
    testWidgets('registrar una salida con el motivo de un chip', (
      tester,
    ) async {
      final repo = RepoCajaFalso(sesion: _sesion());
      await _montar(tester, const CashRegisterScreen(), repo);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Salida'));
      await tester.pumpAndSettle();
      expect(find.text('Salida de efectivo'), findsOneWidget);
      for (final chip in ['Delivery', 'Servicio', 'Compra menor']) {
        expect(find.widgetWithText(ActionChip, chip), findsOneWidget);
      }

      await tester.enterText(_campo('Monto'), '30');
      await tester.tap(find.widgetWithText(ActionChip, 'Delivery'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Registrar salida'));
      await tester.pumpAndSettle();

      expect(repo.registrados, hasLength(1));
      expect(repo.registrados.single.entrada, isFalse);
      expect(repo.registrados.single.monto, const Money(3000));
      expect(repo.registrados.single.motivo, 'Delivery');
      // Se cerró el diálogo, avisó y la lista muestra la salida con su signo.
      expect(find.text('Salida de efectivo'), findsNothing);
      expect(find.text('Salida registrada.'), findsOneWidget);
      expect(find.text('-RD\$ 30.00'), findsOneWidget);
      await _esperarSnackbar(tester);
    });

    testWidgets('una entrada ofrece los chips Cambio y Otro', (tester) async {
      final repo = RepoCajaFalso(sesion: _sesion());
      await _montar(tester, const CashRegisterScreen(), repo);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Entrada'));
      await tester.pumpAndSettle();

      expect(find.text('Entrada de efectivo'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Cambio'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Otro'), findsOneWidget);

      await tester.enterText(_campo('Monto'), '50');
      await tester.tap(find.widgetWithText(ActionChip, 'Cambio'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Registrar entrada'));
      await tester.pumpAndSettle();

      expect(repo.registrados.single.entrada, isTrue);
      expect(repo.registrados.single.monto, const Money(5000));
      expect(repo.registrados.single.motivo, 'Cambio');
      expect(find.text('+RD\$ 50.00'), findsOneWidget);
      await _esperarSnackbar(tester);
    });

    testWidgets('el chip "Otro" deja el motivo vacío para escribirlo', (
      tester,
    ) async {
      final repo = RepoCajaFalso(sesion: _sesion());
      await _montar(tester, const CashRegisterScreen(), repo);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Entrada'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ActionChip, 'Cambio'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ActionChip, 'Otro'));
      await tester.pump();

      final motivo = tester.widget<TextFormField>(_campo('Motivo'));
      expect(motivo.controller!.text, isEmpty);
    });

    testWidgets('exige monto mayor que cero y motivo', (tester) async {
      final repo = RepoCajaFalso(sesion: _sesion());
      await _montar(tester, const CashRegisterScreen(), repo);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Salida'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Registrar salida'));
      await tester.pump();

      expect(find.text('El monto debe ser mayor que cero.'), findsOneWidget);
      expect(find.text('Indica el motivo.'), findsOneWidget);
      expect(repo.registrados, isEmpty);
    });

    testWidgets('el error del repositorio sale en un snackbar y el diálogo '
        'sigue abierto', (tester) async {
      final repo = RepoCajaFalso(sesion: _sesion())
        ..resultado = const Result.fail(
          BusinessRuleFailure('No hay suficiente efectivo en la caja.'),
        );
      await _montar(tester, const CashRegisterScreen(), repo);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Salida'));
      await tester.pumpAndSettle();

      await tester.enterText(_campo('Monto'), '99999');
      await tester.enterText(_campo('Motivo'), 'Servicio');
      await tester.tap(find.widgetWithText(FilledButton, 'Registrar salida'));
      await tester.pumpAndSettle();

      expect(
        find.text('No hay suficiente efectivo en la caja.'),
        findsOneWidget,
      );
      expect(find.text('Salida de efectivo'), findsOneWidget);
      await _esperarSnackbar(tester);
    });

    testWidgets('guard contra doble envío: dos toques registran UNA vez', (
      tester,
    ) async {
      final repo = RepoCajaFalso(sesion: _sesion())
        ..bloqueo = Completer<void>();
      await _montar(tester, const CashRegisterScreen(), repo);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Salida'));
      await tester.pumpAndSettle();
      await tester.enterText(_campo('Monto'), '10');
      await tester.enterText(_campo('Motivo'), 'Servicio');

      final boton = find.widgetWithText(FilledButton, 'Registrar salida');
      await tester.tap(boton);
      await tester.pump();
      // Ya está enviando: el botón se deshabilita (muestra el progreso).
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
        isNull,
      );
      await tester.tap(find.byType(FilledButton).last, warnIfMissed: false);
      await tester.pump();

      repo.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(repo.registrados, hasLength(1));
      await _esperarSnackbar(tester);
    });
  });

  group('cierre de caja', () {
    testWidgets('muestra el "Resumen del turno" por método de pago', (
      tester,
    ) async {
      final repo = RepoCajaFalso(sesion: _sesion());
      await _montar(tester, const CashRegisterCloseScreen(), repo);

      expect(find.text('Resumen del turno'), findsOneWidget);
      expect(find.text('Ventas del turno'), findsOneWidget);
      expect(find.text('Tarjeta'), findsWidgets);
      expect(find.text('Transferencia'), findsWidgets);
      expect(find.text('Fiado (no entra a la caja)'), findsOneWidget);
      expect(find.text('RD\$ 600.00'), findsOneWidget); // fiado
      expect(find.text('RD\$ 1,500.00'), findsOneWidget); // total vendido
      expect(find.text('Abonos de clientes'), findsOneWidget);
      expect(find.text('+RD\$ 50.00'), findsOneWidget); // entradas manuales
      expect(find.text('-RD\$ 20.00'), findsOneWidget); // salidas manuales
      expect(find.text('-RD\$ 12.00'), findsOneWidget); // gastos
      expect(find.text('Efectivo esperado'), findsOneWidget);
      expect(find.text('RD\$ 1,428.00'), findsWidgets);
    });

    testWidgets('sin abonos, entradas ni salidas no muestra esas líneas', (
      tester,
    ) async {
      const soloVentas = ResumenTurno(
        montoApertura: Money(100000),
        ventasEfectivo: Money(30000),
        ventasTarjeta: Money.zero,
        ventasTransferencia: Money.zero,
        ventasFiado: Money.zero,
        abonosEfectivo: Money.zero,
        abonosTarjeta: Money.zero,
        abonosTransferencia: Money.zero,
        entradasManuales: Money.zero,
        salidasManuales: Money.zero,
        gastos: Money.zero,
        compras: Money.zero,
        pagosEmpleados: Money.zero,
        efectivoEsperado: Money(130000),
      );
      await _montar(
        tester,
        const CashRegisterCloseScreen(),
        RepoCajaFalso(sesion: _sesion(), resumen: soloVentas),
      );

      expect(find.text('Resumen del turno'), findsOneWidget);
      expect(find.text('Abonos de clientes'), findsNothing);
      expect(find.text('Entradas manuales'), findsNothing);
      expect(find.text('Salidas manuales'), findsNothing);
      expect(find.text('Gastos pagados de caja'), findsNothing);
    });
  });

  group('detalle de un cierre del historial', () {
    testWidgets('muestra el resumen del turno y los movimientos con signo', (
      tester,
    ) async {
      final cerrada = CajaSesion(
        id: 'vieja',
        fechaApertura: DateTime.utc(2026, 1, 1, 12),
        fechaCierre: DateTime.utc(2026, 1, 1, 22),
        montoApertura: const Money(100000),
        montoEsperado: const Money(142800),
        montoContado: const Money(142300),
        diferencia: const Money(-500),
        montoDejadoSiguiente: const Money(20000),
        usuarioAperturaNombre: 'Ana Admin',
        usuarioCierreNombre: 'Ana Admin',
        estado: EstadoCajaSesion.cerrada,
        movimientos: [
          _mov('s', TipoCajaMovimiento.salidaManual, -2000, motivo: 'Servicio'),
        ],
      );
      await _montar(
        tester,
        const CashRegisterSessionDetailScreen(sesionId: 'vieja'),
        RepoCajaFalso(historial: [cerrada]),
      );

      expect(find.text('Resumen del turno'), findsOneWidget);
      expect(find.text('Ventas del turno'), findsOneWidget);
      expect(find.textContaining('Faltante'), findsOneWidget);
      // Los movimientos van al final de una lista larga: hay que llegar a ellos.
      await tester.scrollUntilVisible(
        find.text('Servicio'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Servicio'), findsOneWidget);
      expect(find.text('-RD\$ 20.00'), findsWidgets);
    });
  });

  group('estados', () {
    testWidgets('error al cargar la caja: mensaje humano y Reintentar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(420, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var intentos = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => _AuthFalso(RolUsuario.administrador),
            ),
            sesionActualProvider.overrideWith((ref) {
              intentos++;
              return intentos == 1
                  ? Stream<CajaSesion?>.error(StateError('boom'))
                  : Stream.value(_sesion());
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const CashRegisterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No se pudo cargar el estado de caja.'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Caja abierta'), findsOneWidget);
    });
  });
}
