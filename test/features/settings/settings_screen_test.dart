import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:app_gestion/features/settings/presentation/providers/settings_providers.dart';
import 'package:app_gestion/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ajustes en memoria (sin drift: sus streams dejan timers pendientes).
class _AjustesFalsos implements SettingsLocalDatasource {
  _AjustesFalsos({this.valor = true});

  bool valor;
  bool falla = false;
  final guardados = <({bool valor, String usuarioId})>[];
  final _cambios = StreamController<bool>.broadcast();

  @override
  Stream<bool> watchPermitirStockNegativo() async* {
    yield valor;
    yield* _cambios.stream;
  }

  @override
  Future<bool> permitirStockNegativo() async => valor;

  @override
  Future<void> establecerPermitirStockNegativo(
    bool nuevo, {
    required String usuarioId,
  }) async {
    if (falla) throw StateError('base de datos caída');
    guardados.add((valor: nuevo, usuarioId: usuarioId));
    valor = nuevo;
    _cambios.add(nuevo);
  }

  Future<void> cerrar() => _cambios.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AuthFalso extends AuthController {
  @override
  Future<EstadoSesion> build() async => const SesionActiva(
    Usuario(
      id: 'admin-1',
      negocioId: 'n1',
      nombre: 'Ana Admin',
      username: 'ana',
      rol: RolUsuario.administrador,
      activo: true,
    ),
  );
}

Future<_AjustesFalsos> _montar(
  WidgetTester tester, {
  bool valor = true,
}) async {
  final ajustes = _AjustesFalsos(valor: valor);
  addTearDown(ajustes.cerrar);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsLocalDatasourceProvider.overrideWithValue(ajustes),
        authControllerProvider.overrideWith(_AuthFalso.new),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  return ajustes;
}

Finder get _interruptor => find.byType(SwitchListTile);

bool _encendido(WidgetTester tester) =>
    tester.widget<SwitchListTile>(_interruptor).value;

void main() {
  testWidgets('muestra el interruptor con su explicación y el valor actual', (
    tester,
  ) async {
    await _montar(tester);

    expect(find.text('Ajustes del negocio'), findsOneWidget);
    expect(find.text('Permitir vender sin stock'), findsOneWidget);
    expect(
      find.text(
        'Si está desactivado, no se podrán vender productos sin '
        'existencias suficientes.',
      ),
      findsOneWidget,
    );
    expect(_encendido(tester), isTrue);
  });

  testWidgets('cambiar el interruptor lo persiste (con el usuario) y avisa', (
    tester,
  ) async {
    final ajustes = await _montar(tester);

    await tester.tap(_interruptor);
    await tester.pumpAndSettle();

    expect(ajustes.guardados, [(valor: false, usuarioId: 'admin-1')]);
    expect(_encendido(tester), isFalse);
    expect(find.text('Ajuste guardado'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    await tester.tap(_interruptor);
    await tester.pumpAndSettle();

    expect(ajustes.guardados.last.valor, isTrue);
    expect(_encendido(tester), isTrue);
  });

  testWidgets('si guardar falla: mensaje de error y el interruptor conserva '
      'su valor', (tester) async {
    final ajustes = await _montar(tester);
    ajustes.falla = true;

    await tester.tap(_interruptor);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo guardar el ajuste.'), findsOneWidget);
    expect(ajustes.guardados, isEmpty);
    expect(_encendido(tester), isTrue);
  });

  testWidgets('con el ajuste guardado en false abre apagado', (tester) async {
    await _montar(tester, valor: false);

    expect(_encendido(tester), isFalse);
  });
}
