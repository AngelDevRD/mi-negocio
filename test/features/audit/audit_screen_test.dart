import 'dart:async';

import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/audit/domain/entities/registro_auditoria.dart';
import 'package:app_gestion/features/audit/domain/repositories/audit_repository.dart';
import 'package:app_gestion/features/audit/presentation/etiquetas_auditoria.dart';
import 'package:app_gestion/features/audit/presentation/providers/audit_providers.dart';
import 'package:app_gestion/features/audit/presentation/screens/audit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

enum _Modo { datos, carga, error }

/// Auditoría en memoria: aplica el filtro y el límite como la base real y
/// anota cada consulta.
class _RepoAuditoriaFalso implements AuditRepository {
  _RepoAuditoriaFalso(this.registros, {this.modo = _Modo.datos});

  final List<RegistroAuditoria> registros;
  final _Modo modo;

  final consultas = <({AuditoriaFiltro filtro, int limite})>[];

  @override
  Stream<List<RegistroAuditoria>> watchRegistros(
    AuditoriaFiltro filtro, {
    int limite = limitePorDefectoAuditoria,
  }) {
    consultas.add((filtro: filtro, limite: limite));
    switch (modo) {
      case _Modo.carga:
        return StreamController<List<RegistroAuditoria>>().stream;
      case _Modo.error:
        return Stream.error(StateError('boom'));
      case _Modo.datos:
        final filtrados = [
          for (final r in registros)
            if ((filtro.modulo == null || r.modulo == filtro.modulo) &&
                (filtro.accion == null || r.accion == filtro.accion) &&
                (filtro.usuarioId == null || r.usuarioId == filtro.usuarioId) &&
                (filtro.desde == null || !r.fecha.isBefore(filtro.desde!)) &&
                (filtro.hasta == null || !r.fecha.isAfter(filtro.hasta!)))
              r,
        ]..sort((a, b) => b.fecha.compareTo(a.fecha));
        return Stream.value(filtrados.take(limite).toList());
    }
  }

  @override
  Future<List<String>> listarModulos() async =>
      ({for (final r in registros) r.modulo}.toList()..sort());

  @override
  Future<List<String>> listarAcciones() async =>
      ({for (final r in registros) r.accion}.toList()..sort());

  @override
  Future<List<UsuarioFiltro>> listarUsuarios() async => [
    (id: 'u1', nombre: 'Ana Admin'),
    (id: 'u2', nombre: 'Carlos Cajero'),
  ];
}

RegistroAuditoria _registro(
  int n, {
  String usuarioId = 'u1',
  String usuario = 'Ana Admin',
  String accion = 'crear',
  String modulo = 'productos',
  DateTime? fecha,
  Map<String, Object?>? antes,
  Map<String, Object?>? despues,
}) => RegistroAuditoria(
  id: 'r$n',
  usuarioId: usuarioId,
  usuarioNombre: usuario,
  accion: accion,
  modulo: modulo,
  fecha: fecha ?? DateTime(2026, 1, 1).add(Duration(hours: n)).toUtc(),
  datosAntes: antes,
  datosDespues: despues,
);

Future<void> _montar(
  WidgetTester tester,
  _RepoAuditoriaFalso repo, {
  bool asentar = true,
}) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[auditRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: AppTheme.light(), home: const AuditScreen()),
    ),
  );
  asentar ? await tester.pumpAndSettle() : await tester.pump();
}

Future<void> _elegir(WidgetTester tester, String clave, String opcion) async {
  await tester.tap(find.byKey(ValueKey(clave)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(opcion).last);
  await tester.pumpAndSettle();
}

void main() {
  final mixtos = [
    _registro(
      1,
      accion: 'crear',
      modulo: 'productos',
      fecha: DateTime(2026, 3, 10, 9, 5),
      despues: {'nombre': 'Salami'},
    ),
    _registro(
      2,
      usuarioId: 'u2',
      usuario: 'Carlos Cajero',
      accion: 'anular',
      modulo: 'ventas',
      fecha: DateTime(2026, 3, 11, 14, 30),
    ),
    _registro(
      3,
      accion: 'resetear_password',
      modulo: 'usuarios',
      fecha: DateTime(2026, 3, 12, 8, 0),
    ),
    _registro(
      4,
      accion: 'editar',
      modulo: 'productos',
      fecha: DateTime(2026, 3, 13, 18, 45),
      antes: {'precio': 100},
      despues: {'precio': 120},
    ),
  ];

  testWidgets('cargando: indicador con mensaje', (tester) async {
    await _montar(
      tester,
      _RepoAuditoriaFalso(const [], modo: _Modo.carga),
      asentar: false,
    );

    expect(find.text('Cargando registros...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error: mensaje humano y "Reintentar" vuelve a consultar', (
    tester,
  ) async {
    final repo = _RepoAuditoriaFalso(const [], modo: _Modo.error);
    await _montar(tester, repo);

    expect(find.text('No se pudieron cargar los registros.'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
    final antes = repo.consultas.length;

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repo.consultas.length, greaterThan(antes));
  });

  testWidgets('sin registros: dice por qué', (tester) async {
    await _montar(tester, _RepoAuditoriaFalso(const []));

    expect(find.text('Aún no hay registros'), findsOneWidget);
    expect(find.textContaining('quedará anotado aquí'), findsOneWidget);
    expect(find.text('Quitar filtros'), findsNothing);
  });

  test('las acciones que registra la app tienen nombre legible (no el '
      'identificador interno)', () {
    const conocidas = {
      'crear': 'Crear',
      'editar': 'Editar',
      'actualizar': 'Editar',
      'anular': 'Anular',
      'eliminar': 'Eliminar',
      'abrir': 'Abrir',
      'cerrar': 'Cerrar',
      'importar': 'Importar',
      'abonar': 'Abonar',
      'activar': 'Activar',
      'desactivar': 'Desactivar',
      'entrada_manual': 'Entrada de efectivo',
      'salida_manual': 'Salida de efectivo',
      'resetear_password': 'Restablecer contraseña',
      'cambiar_password': 'Cambiar contraseña',
    };
    conocidas.forEach((accion, texto) {
      expect(etiquetaDeAccion(accion).texto, texto, reason: accion);
    });
    // Una acción nueva no rompe: se muestra legible igualmente.
    expect(etiquetaDeAccion('ajuste_raro').texto, 'Ajuste raro');
    expect(etiquetaDeModulo('configuracion'), 'Configuración');
  });

  group('lista', () {
    testWidgets('acción con icono + texto, módulo, usuario y fecha LOCAL', (
      tester,
    ) async {
      await _montar(tester, _RepoAuditoriaFalso(mixtos));

      // Más reciente primero.
      final editar = find.text('Editar');
      final anular = find.text('Anular');
      expect(editar, findsOneWidget);
      expect(
        tester.getTopLeft(editar).dy < tester.getTopLeft(anular).dy,
        isTrue,
      );
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);
      // Identificadores internos, legibles.
      expect(find.text('Restablecer contraseña'), findsWidgets);
      expect(find.text('resetear_password'), findsNothing);
      expect(find.text('Ventas'), findsWidgets);
      expect(find.text('Ana Admin · 13/03/2026 18:45'), findsOneWidget);
      expect(find.text('Carlos Cajero · 11/03/2026 14:30'), findsOneWidget);
      expect(find.text('Mostrando 4 registros'), findsOneWidget);
    });

    testWidgets('tocar un registro muestra antes y después', (tester) async {
      await _montar(tester, _RepoAuditoriaFalso(mixtos));

      await tester.tap(find.text('Ana Admin · 13/03/2026 18:45'));
      await tester.pumpAndSettle();

      expect(find.text('Productos · Editar'), findsOneWidget);
      expect(find.text('Antes'), findsOneWidget);
      expect(find.text('Después'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
    });
  });

  group('filtros', () {
    testWidgets('por módulo: se aplica y "Quitar filtros" lo deshace', (
      tester,
    ) async {
      final repo = _RepoAuditoriaFalso(mixtos);
      await _montar(tester, repo);

      await _elegir(tester, 'modulo-null', 'Ventas');

      expect(repo.consultas.last.filtro.modulo, 'ventas');
      expect(find.text('Anular'), findsWidgets);
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Mostrando 1 registro'), findsOneWidget);

      await tester.tap(find.text('Quitar filtros'));
      await tester.pumpAndSettle();

      expect(repo.consultas.last.filtro.modulo, isNull);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Mostrando 4 registros'), findsOneWidget);
      expect(find.text('Quitar filtros'), findsNothing);
    });

    testWidgets('por acción (con su nombre legible)', (tester) async {
      final repo = _RepoAuditoriaFalso(mixtos);
      await _montar(tester, repo);

      await _elegir(tester, 'accion-null', 'Crear');

      expect(repo.consultas.last.filtro.accion, 'crear');
      expect(find.text('Mostrando 1 registro'), findsOneWidget);
    });

    testWidgets('por usuario', (tester) async {
      final repo = _RepoAuditoriaFalso(mixtos);
      await _montar(tester, repo);

      await _elegir(tester, 'usuario-null', 'Carlos Cajero');

      expect(repo.consultas.last.filtro.usuarioId, 'u2');
      expect(find.text('Mostrando 1 registro'), findsOneWidget);
      expect(find.text('Carlos Cajero · 11/03/2026 14:30'), findsOneWidget);
    });

    testWidgets('por fecha con el chip: "Hoy" deja fuera lo antiguo', (
      tester,
    ) async {
      final repo = _RepoAuditoriaFalso(mixtos);
      await _montar(tester, repo);

      expect(find.text('Todas las fechas'), findsOneWidget);
      await tester.tap(find.text('Todas las fechas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hoy').last);
      await tester.pumpAndSettle();

      final filtro = repo.consultas.last.filtro;
      expect(filtro.desde, isNotNull);
      expect(filtro.hasta, isNotNull);
      final hoy = DateTime.now();
      expect(filtro.desde!.toLocal().day, hoy.day);
      // Los registros de marzo de 2026 quedan fuera (hoy no es marzo/2026).
      expect(find.text('Ningún registro coincide'), findsOneWidget);
      expect(find.text('Quitar filtros'), findsWidgets);
    });

    testWidgets('sin coincidencias con filtro: EmptyState con la acción de '
        'quitarlo', (tester) async {
      final repo = _RepoAuditoriaFalso(mixtos);
      await _montar(tester, repo);

      await _elegir(tester, 'modulo-null', 'Ventas');
      await _elegir(tester, 'accion-null', 'Crear');

      expect(find.text('Ningún registro coincide'), findsOneWidget);
      expect(find.textContaining('Prueba con otro período'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Quitar filtros'));
      await tester.pumpAndSettle();

      expect(find.text('Ningún registro coincide'), findsNothing);
      expect(find.text('Mostrando 4 registros'), findsOneWidget);
    });
  });

  group('paginación (nunca carga todo)', () {
    final muchos = [for (var i = 1; i <= 250; i++) _registro(i)];

    testWidgets('pide 100, "Cargar más" pide otros 100 hasta agotar', (
      tester,
    ) async {
      final repo = _RepoAuditoriaFalso(muchos);
      await _montar(tester, repo);

      expect(repo.consultas.last.limite, 100);
      final lista = find.byType(Scrollable).first;

      await tester.scrollUntilVisible(
        find.text('Cargar más'),
        600,
        scrollable: lista,
      );
      expect(find.text('Mostrando los 100 más recientes'), findsOneWidget);

      await tester.tap(find.text('Cargar más'));
      await tester.pumpAndSettle();
      expect(repo.consultas.last.limite, 200);

      await tester.scrollUntilVisible(
        find.text('Cargar más'),
        600,
        scrollable: lista,
      );
      expect(find.text('Mostrando los 200 más recientes'), findsOneWidget);

      await tester.tap(find.text('Cargar más'));
      await tester.pumpAndSettle();
      expect(repo.consultas.last.limite, 300);

      // 250 < 300: ya no hay más.
      await tester.scrollUntilVisible(
        find.text('Mostrando 250 registros'),
        600,
        scrollable: lista,
      );
      expect(find.text('Cargar más'), findsNothing);
    });

    testWidgets('cambiar un filtro vuelve a la primera página', (tester) async {
      final repo = _RepoAuditoriaFalso(muchos);
      await _montar(tester, repo);
      await tester.scrollUntilVisible(
        find.text('Cargar más'),
        600,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Cargar más'));
      await tester.pumpAndSettle();
      expect(repo.consultas.last.limite, 200);

      await _elegir(tester, 'modulo-null', 'Productos');

      expect(repo.consultas.last.filtro.modulo, 'productos');
      expect(repo.consultas.last.limite, 100);
    });
  });
}
