import 'dart:async';

import 'package:app_gestion/core/database/app_database.dart' show Negocio;
import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:app_gestion/features/license/presentation/providers/license_providers.dart';
import 'package:app_gestion/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:app_gestion/features/profile/presentation/providers/profile_providers.dart';
import 'package:app_gestion/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

class _AuthFalso extends AuthController {
  @override
  Future<EstadoSesion> build() async => const SesionActiva(
    Usuario(
      id: 'u1',
      negocioId: 'n1',
      nombre: 'Ana',
      username: 'ana',
      rol: RolUsuario.administrador,
      activo: true,
    ),
  );
}

class _LicenciaFalsa extends LicenseController {
  _LicenciaFalsa(this.estado);

  final EstadoLicencia estado;
  Completer<void>? bloqueo;
  Failure? fallo;
  Object? lanzar;
  int claves = 0;
  int renovaciones = 0;

  @override
  Future<LicenseCheck> build() async {
    final licencia = Licencia(
      tipo: TipoLicencia.local,
      estado: estado,
      deviceId: 'd',
      fechaActivacion: DateTime(2026, 1, 10, 12),
      ultimaValidacion: DateTime(2026, 9, 1),
      fechaVencimiento: DateTime(2027, 1, 10, 12),
    );
    return estado == EstadoLicencia.activa
        ? LicenciaActiva(licencia)
        : LicenciaBloqueada('Suspendida.', licencia: licencia);
  }

  @override
  Future<Failure?> activarConClave(String clave) async {
    claves++;
    await bloqueo?.future;
    if (lanzar != null) throw lanzar!;
    return fallo;
  }

  @override
  Future<(String?, Failure?)> renovar() async {
    renovaciones++;
    await bloqueo?.future;
    if (lanzar != null) throw lanzar!;
    return fallo == null
        ? ('Solicitud de renovación enviada.', null)
        : (null, fallo);
  }
}

class _PerfilFalso implements ProfileLocalDatasource {
  Completer<void>? bloqueo;
  Object? lanzar;
  final guardados = <({String nombre, String? email, String? telefono})>[];

  @override
  Future<void> actualizarPerfil({
    required Negocio actual,
    required String nombre,
    String? identificacion,
    String? direccion,
    String? telefono,
    String? email,
    String? logoPath,
    required String actorId,
  }) async {
    guardados.add((nombre: nombre, email: email, telefono: telefono));
    await bloqueo?.future;
    if (lanzar != null) throw lanzar!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Negocio _negocio() => Negocio(
  id: 'n1',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  nombre: 'Colmado Doña Carmen',
  moneda: 'DOP',
  telefono: '809-555-0142',
);

enum _Modo { datos, carga, error, vacio }

class _Entorno {
  _Entorno({
    this.modo = _Modo.datos,
    EstadoLicencia estado = EstadoLicencia.activa,
  }) : licencia = _LicenciaFalsa(estado);

  final _Modo modo;
  final _LicenciaFalsa licencia;
  final perfil = _PerfilFalso();
  int consultas = 0;
}

Future<_Entorno> _montar(
  WidgetTester tester, {
  _Entorno? entorno,
  Size tamano = const Size(420, 2000),
}) async {
  final e = entorno ?? _Entorno();
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        authControllerProvider.overrideWith(_AuthFalso.new),
        licenseControllerProvider.overrideWith(() => e.licencia),
        profileLocalDatasourceProvider.overrideWithValue(e.perfil),
        negocioProvider.overrideWith((ref) {
          e.consultas++;
          return switch (e.modo) {
            _Modo.datos => Stream.value(_negocio()),
            _Modo.vacio => Stream<Negocio?>.value(null),
            _Modo.carga => StreamController<Negocio?>().stream,
            _Modo.error => Stream<Negocio?>.error(StateError('boom')),
          };
        }),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const ProfileScreen()),
    ),
  );
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  e.modo == _Modo.carga ? await tester.pump() : await tester.pumpAndSettle();
  return e;
}

Finder _campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

void main() {
  testWidgets('cargando: indicador con mensaje', (tester) async {
    await _montar(tester, entorno: _Entorno(modo: _Modo.carga));

    expect(find.text('Cargando perfil...'), findsOneWidget);
  });

  testWidgets('error: mensaje humano y "Reintentar" vuelve a consultar', (
    tester,
  ) async {
    final e = await _montar(tester, entorno: _Entorno(modo: _Modo.error));

    expect(
      find.text('No se pudo cargar el perfil del negocio.'),
      findsOneWidget,
    );
    expect(find.textContaining('boom'), findsNothing);
    final antes = e.consultas;

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(e.consultas, greaterThan(antes));
  });

  testWidgets('sin negocio: estado vacío que explica qué hacer', (
    tester,
  ) async {
    await _montar(tester, entorno: _Entorno(modo: _Modo.vacio));

    expect(find.text('Negocio no configurado'), findsOneWidget);
  });

  group('datos del negocio', () {
    testWidgets('carga el negocio y guarda con un solo envío + snackbar', (
      tester,
    ) async {
      final e = await _montar(tester);
      e.perfil.bloqueo = Completer<void>();

      expect(find.text('Colmado Doña Carmen'), findsOneWidget);
      await tester.enterText(_campo('Nombre del negocio'), 'Colmado Nuevo');
      final guardar = find.widgetWithText(FilledButton, 'Guardar');
      await tester.ensureVisible(guardar);
      await tester.tap(guardar);
      await tester.tap(guardar, warnIfMissed: false);
      await tester.pump();

      expect(e.perfil.guardados.length, 1);
      e.perfil.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(e.perfil.guardados.length, 1);
      expect(e.perfil.guardados.single.nombre, 'Colmado Nuevo');
      expect(find.text('Perfil actualizado.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('nombre vacío y email inválido: mensajes claros, no guarda', (
      tester,
    ) async {
      final e = await _montar(tester);

      await tester.enterText(_campo('Nombre del negocio'), '  ');
      await tester.enterText(_campo('Email (opcional)'), 'sin-arroba');
      final guardar = find.widgetWithText(FilledButton, 'Guardar');
      await tester.ensureVisible(guardar);
      await tester.tap(guardar);
      await tester.pump();

      expect(find.text('Escribe el nombre de tu negocio'), findsOneWidget);
      expect(find.text('Escribe un email válido'), findsOneWidget);
      expect(e.perfil.guardados, isEmpty);
    });

    testWidgets('si la base falla: mensaje genérico, sin detalles', (
      tester,
    ) async {
      final e = await _montar(tester);
      e.perfil.lanzar = StateError('SqliteException(5): database is locked');

      final guardar = find.widgetWithText(FilledButton, 'Guardar');
      await tester.ensureVisible(guardar);
      await tester.tap(guardar);
      await tester.pumpAndSettle();

      expect(
        find.text('No se pudo guardar el perfil. Inténtalo de nuevo.'),
        findsOneWidget,
      );
      expect(find.textContaining('Sqlite'), findsNothing);
      expect(find.textContaining('locked'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('suscripción', () {
    testWidgets('el estado sale con ícono + texto y las fechas en local', (
      tester,
    ) async {
      await _montar(tester);

      expect(find.text('Activa'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
      expect(find.text('10/01/2026'), findsOneWidget);
      expect(find.text('10/01/2027'), findsOneWidget);
    });

    testWidgets('una licencia suspendida se marca con ícono + texto', (
      tester,
    ) async {
      await _montar(
        tester,
        entorno: _Entorno(estado: EstadoLicencia.suspendida),
      );

      expect(find.text('Suspendida'), findsOneWidget);
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);
    });

    testWidgets('activar clave: Enter envía, un solo envío, fallo en '
        'snackbar de error', (tester) async {
      final e = await _montar(tester);
      e.licencia.fallo = const LicenseFailure('La clave no es válida.');

      final clave = find.widgetWithText(TextField, 'Clave de licencia');
      await tester.ensureVisible(clave);
      await tester.enterText(clave, 'agn-1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(e.licencia.claves, 1);
      expect(find.text('La clave no es válida.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('activar sin escribir la clave: aviso, no llama', (
      tester,
    ) async {
      final e = await _montar(tester);

      final boton = find.widgetWithText(
        FilledButton,
        'Activar / cambiar licencia',
      );
      await tester.ensureVisible(boton);
      await tester.tap(boton);
      await tester.pump();

      expect(find.text('Escribe la clave de licencia.'), findsOneWidget);
      expect(e.licencia.claves, 0);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('renovar: doble toque = UNA solicitud y avisa', (tester) async {
      final e = await _montar(tester);
      e.licencia.bloqueo = Completer<void>();

      final renovar = find.widgetWithText(FilledButton, 'Renovar');
      await tester.ensureVisible(renovar);
      await tester.tap(renovar);
      await tester.tap(renovar, warnIfMissed: false);
      await tester.pump();
      expect(e.licencia.renovaciones, 1);

      e.licencia.bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(e.licencia.renovaciones, 1);
      expect(find.text('Solicitud de renovación enviada.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('renovar con una excepción: mensaje genérico', (tester) async {
      final e = await _montar(tester);
      e.licencia.lanzar = StateError('Connection reset 10.0.0.9');

      final renovar = find.widgetWithText(FilledButton, 'Renovar');
      await tester.ensureVisible(renovar);
      await tester.tap(renovar);
      await tester.pumpAndSettle();

      expect(
        find.text('No se pudo enviar la solicitud. Inténtalo de nuevo.'),
        findsOneWidget,
      );
      expect(find.textContaining('10.0.0.9'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
    });
  });

  testWidgets('teléfono angosto: sin desbordes', (tester) async {
    await _montar(tester, tamano: const Size(320, 900));
    expect(tester.takeException(), isNull);
  });
}
