import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/auth/presentation/screens/users_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

const _admin = Usuario(
  id: 'u1',
  negocioId: 'n1',
  nombre: 'Ana Admin',
  username: 'ana',
  rol: RolUsuario.administrador,
  activo: true,
);

const _cajero = Usuario(
  id: 'u2',
  negocioId: 'n1',
  nombre: 'Carlos Cajero',
  username: 'carlos',
  rol: RolUsuario.cajero,
  activo: true,
);

class _AuthFalso extends AuthController {
  @override
  Future<EstadoSesion> build() async => const SesionActiva(_admin);
}

enum _Modo { datos, carga, error }

/// Usuarios en memoria. La regla de "no desactivar al único administrador"
/// se reproduce con el MISMO mensaje del repositorio real (que ya tiene su
/// propia prueba en auth_repository_impl_test.dart).
class _RepoAuthFalso implements AuthRepository {
  _RepoAuthFalso(this.usuarios, {this.modo = _Modo.datos});

  List<Usuario> usuarios;
  final _Modo modo;

  int consultas = 0;
  final cajerosCreados =
      <({String nombre, String username, String password})>[];
  final passwordsRestablecidas = <String>[];
  final activaciones = <({String id, bool activo})>[];

  @override
  Future<List<Usuario>> listarUsuarios() async {
    consultas++;
    if (modo == _Modo.carga) return Completer<List<Usuario>>().future;
    if (modo == _Modo.error) throw StateError('boom');
    return usuarios;
  }

  @override
  Future<Result<Usuario>> crearCajero({
    required String nombre,
    required String username,
    required String password,
    required String actorId,
  }) async {
    cajerosCreados.add((
      nombre: nombre,
      username: username,
      password: password,
    ));
    return Result.ok(_cajero.copyWith(nombre: nombre, username: username));
  }

  @override
  Future<Result<void>> resetearPassword({
    required String usuarioId,
    required String nuevaPassword,
    required String actorId,
  }) async {
    passwordsRestablecidas.add(nuevaPassword);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> establecerActivo({
    required String usuarioId,
    required bool activo,
    required String actorId,
  }) async {
    final usuario = usuarios.firstWhere((u) => u.id == usuarioId);
    if (!activo && usuario.esAdministrador) {
      final activos = usuarios.where((u) => u.esAdministrador && u.activo);
      if (activos.length <= 1) {
        return const Result.fail(
          BusinessRuleFailure('No se puede desactivar al único administrador.'),
        );
      }
    }
    activaciones.add((id: usuarioId, activo: activo));
    usuarios = [
      for (final u in usuarios)
        if (u.id == usuarioId) u.copyWith(activo: activo) else u,
    ];
    return const Result.ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _montar(
  WidgetTester tester,
  _RepoAuthFalso repo, {
  bool asentar = true,
}) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(repo),
        authControllerProvider.overrideWith(_AuthFalso.new),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const UsersManagementScreen(),
      ),
    ),
  );
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  asentar ? await tester.pumpAndSettle() : await tester.pump();
}

Future<void> _abrirMenu(WidgetTester tester, String nombre) async {
  await tester.tap(find.byTooltip('Acciones de $nombre'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cargando: indicador con mensaje', (tester) async {
    await _montar(
      tester,
      _RepoAuthFalso([], modo: _Modo.carga),
      asentar: false,
    );

    expect(find.text('Cargando usuarios...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error: mensaje humano y "Reintentar" vuelve a consultar', (
    tester,
  ) async {
    final repo = _RepoAuthFalso([], modo: _Modo.error);
    await _montar(tester, repo);

    expect(find.text('No se pudieron cargar los usuarios.'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
    final antes = repo.consultas;

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repo.consultas, greaterThan(antes));
  });

  testWidgets('vacío: dice por qué y ofrece UNA acción (sin FAB)', (
    tester,
  ) async {
    await _montar(tester, _RepoAuthFalso([]));

    expect(find.text('Aún no hay usuarios'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Nuevo cajero'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('lista: rol con ícono + texto y estado Activo/Inactivo', (
    tester,
  ) async {
    await _montar(
      tester,
      _RepoAuthFalso([
        _admin,
        _cajero,
        _cajero.copyWith(
          id: 'u3',
          nombre: 'Rosa',
          username: 'rosa',
          activo: false,
        ),
      ]),
    );

    expect(find.text('Administrador'), findsOneWidget);
    expect(find.text('Cajero'), findsNWidgets(2));
    expect(find.text('Activo'), findsNWidgets(2));
    expect(find.text('Inactivo'), findsOneWidget);
    expect(find.text('Usuario: ana'), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .heroTag,
      isNull,
    );
  });

  testWidgets('no se puede desactivar al ÚNICO administrador: el mensaje del '
      'repositorio se ve', (tester) async {
    final repo = _RepoAuthFalso([_admin, _cajero]);
    await _montar(tester, repo);

    await _abrirMenu(tester, 'Ana Admin');
    await tester.tap(find.text('Desactivar'));
    await tester.pumpAndSettle();
    expect(find.text('¿Desactivar a Ana Admin?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Desactivar'));
    await tester.pumpAndSettle();

    expect(
      find.text('No se puede desactivar al único administrador.'),
      findsOneWidget,
    );
    expect(repo.activaciones, isEmpty);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('desactivar un cajero pide confirmación DESTRUCTIVA y avisa', (
    tester,
  ) async {
    final repo = _RepoAuthFalso([_admin, _cajero]);
    await _montar(tester, repo);

    await _abrirMenu(tester, 'Carlos Cajero');
    await tester.tap(find.text('Desactivar'));
    await tester.pumpAndSettle();

    final confirmar = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Desactivar'),
    );
    final scheme = Theme.of(
      tester.element(find.byType(AlertDialog)),
    ).colorScheme;
    expect(confirmar.style?.backgroundColor?.resolve({}), scheme.error);
    expect(repo.activaciones, isEmpty);

    await tester.tap(find.widgetWithText(FilledButton, 'Desactivar'));
    await tester.pumpAndSettle();

    expect(repo.activaciones, [(id: 'u2', activo: false)]);
    expect(find.text('Carlos Cajero desactivado.'), findsOneWidget);
    expect(find.text('Inactivo'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('cancelar la confirmación no cambia nada', (tester) async {
    final repo = _RepoAuthFalso([_admin, _cajero]);
    await _montar(tester, repo);

    await _abrirMenu(tester, 'Carlos Cajero');
    await tester.tap(find.text('Desactivar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repo.activaciones, isEmpty);
  });

  group('nuevo cajero', () {
    Future<void> abrirDialogo(WidgetTester tester) async {
      await tester.tap(
        find.widgetWithText(FloatingActionButton, 'Nuevo cajero'),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('valida nombre, usuario y contraseña', (tester) async {
      final repo = _RepoAuthFalso([_admin]);
      await _montar(tester, repo);
      await abrirDialogo(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
      await tester.pump();

      expect(find.text('Escribe el nombre del cajero'), findsOneWidget);
      expect(find.text('Mínimo 3 caracteres'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsWidgets);
      expect(repo.cajerosCreados, isEmpty);
    });

    testWidgets('la contraseña se oculta y el botón (con tooltip) la '
        'muestra u oculta', (tester) async {
      await _montar(tester, _RepoAuthFalso([_admin]));
      await abrirDialogo(tester);

      bool oculta() => tester
          .widget<EditableText>(
            find.descendant(
              of: find.widgetWithText(TextFormField, 'Contraseña'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText;

      expect(oculta(), isTrue);
      await tester.tap(find.byTooltip('Mostrar contraseña'));
      await tester.pump();
      expect(oculta(), isFalse);
      expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
      await tester.tap(find.byTooltip('Ocultar contraseña'));
      await tester.pump();
      expect(oculta(), isTrue);
    });

    testWidgets('crea el cajero y la contraseña NO aparece en ningún '
        'mensaje', (tester) async {
      final repo = _RepoAuthFalso([_admin]);
      await _montar(tester, repo);
      await abrirDialogo(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Carlos Cajero',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Usuario'),
        'carlos',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        'secreto123',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
      await tester.pumpAndSettle();

      expect(repo.cajerosCreados.single.password, 'secreto123');
      expect(
        find.text('Cajero creado. Ya puede iniciar sesión.'),
        findsOneWidget,
      );
      expect(find.textContaining('secreto123'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
    });
  });

  testWidgets('restablecer contraseña: confirma, pide la nueva y avisa sin '
      'mostrarla', (tester) async {
    final repo = _RepoAuthFalso([_admin, _cajero]);
    await _montar(tester, repo);

    await _abrirMenu(tester, 'Carlos Cajero');
    await tester.tap(find.text('Restablecer contraseña'));
    await tester.pumpAndSettle();
    expect(find.text('¿Restablecer la contraseña?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'nuevaClave9');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(repo.passwordsRestablecidas, ['nuevaClave9']);
    expect(
      find.text('Contraseña de Carlos Cajero restablecida.'),
      findsOneWidget,
    );
    expect(find.textContaining('nuevaClave9'), findsNothing);
    await tester.pump(const Duration(seconds: 6));
  });
}
