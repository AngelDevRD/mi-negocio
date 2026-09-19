import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/more/presentation/screens/more_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthFalso extends AuthController {
  _AuthFalso(this._estado);

  final EstadoSesion _estado;
  int cierresDeSesion = 0;

  @override
  Future<EstadoSesion> build() async => _estado;

  @override
  Future<void> logout() async {
    cierresDeSesion++;
  }
}

Usuario _usuario(RolUsuario rol) => Usuario(
  id: 'u1',
  negocioId: 'n1',
  nombre: rol == RolUsuario.administrador ? 'Ana Admin' : 'Carlos Cajero',
  username: 'usuario',
  rol: rol,
  activo: true,
);

Future<_AuthFalso> _montar(WidgetTester tester, RolUsuario rol) async {
  // Superficie alta: la ListView es perezosa y necesitamos que construya
  // todos los ítems para poder buscarlos.
  await tester.binding.setSurfaceSize(const Size(500, 3000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final auth = _AuthFalso(SesionActiva(_usuario(rol)));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authControllerProvider.overrideWith(() => auth)],
      child: const MaterialApp(home: MoreScreen()),
    ),
  );
  await tester.pumpAndSettle();
  // MoreScreen no decide por ancho: solo importa el ALTO de las
  // restricciones (ListView perezosa). Se comprueba el que ve la pantalla.
  expect(tester.getSize(find.byType(MoreScreen)), const Size(500, 3000));
  return auth;
}

void main() {
  group('permisos por rol', () {
    testWidgets('un cajero NO ve Personal, Análisis, Datos ni Perfil', (
      tester,
    ) async {
      await _montar(tester, RolUsuario.cajero);

      // Visibles para todos.
      for (final texto in [
        'Operación',
        'Clientes y fiado',
        'Compras',
        'Gastos',
        'Cuenta',
        'Cerrar sesión',
      ]) {
        expect(find.text(texto), findsOneWidget, reason: texto);
      }
      // Solo administrador.
      for (final texto in [
        'Personal',
        'Empleados',
        'Gestionar usuarios',
        'Análisis',
        'Análisis financiero',
        'Auditoría',
        'Asistente IA',
        'Datos',
        'Exportaciones',
        'Importar datos',
        'Respaldo',
        'Perfil y suscripción',
        'Ajustes del negocio',
      ]) {
        expect(find.text(texto), findsNothing, reason: texto);
      }
      expect(find.text('Carlos Cajero'), findsOneWidget);
      expect(find.text('Cajero'), findsOneWidget);
    });

    testWidgets('un administrador ve todas las secciones y módulos', (
      tester,
    ) async {
      await _montar(tester, RolUsuario.administrador);

      for (final texto in [
        'Operación',
        'Compras',
        'Gastos',
        'Personal',
        'Empleados',
        'Gestionar usuarios',
        'Análisis',
        'Análisis financiero',
        'Auditoría',
        'Asistente IA',
        'Datos',
        'Exportaciones',
        'Importar datos',
        'Respaldo',
        'Cuenta',
        'Perfil y suscripción',
        'Ajustes del negocio',
        'Cerrar sesión',
      ]) {
        expect(find.text(texto), findsOneWidget, reason: texto);
      }
      expect(find.text('Ana Admin'), findsOneWidget);
      expect(find.text('Administrador'), findsOneWidget);
    });
  });

  group('Inventario ya no está en Más (se fusionó con Productos)', () {
    for (final rol in RolUsuario.values) {
      testWidgets('$rol no ve "Inventario"', (tester) async {
        await _montar(tester, rol);

        expect(find.text('Inventario'), findsNothing);
      });
    }
  });

  group('Clientes y fiado', () {
    for (final rol in RolUsuario.values) {
      testWidgets('$rol lo ve como PRIMER elemento de Operación', (
        tester,
      ) async {
        await _montar(tester, rol);

        final y = tester.getTopLeft(find.text('Clientes y fiado')).dy;
        expect(tester.getTopLeft(find.text('Operación')).dy, lessThan(y));
        expect(tester.getTopLeft(find.text('Compras')).dy, greaterThan(y));
      });
    }
  });

  group('cerrar sesión', () {
    Finder botonDelDialogo() => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Cerrar sesión'),
    );

    testWidgets('muestra la confirmación y cancelar NO cierra la sesión', (
      tester,
    ) async {
      final auth = await _montar(tester, RolUsuario.cajero);

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('Tendrás que volver a iniciar sesión para usar la app.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(auth.cierresDeSesion, 0);
    });

    testWidgets('confirmar SÍ llama a logout, con botón destructivo', (
      tester,
    ) async {
      final auth = await _montar(tester, RolUsuario.cajero);

      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();

      final boton = tester.widget<FilledButton>(botonDelDialogo());
      final scheme = Theme.of(tester.element(botonDelDialogo())).colorScheme;
      expect(
        boton.style?.backgroundColor?.resolve(<WidgetState>{}),
        scheme.error,
      );

      await tester.tap(botonDelDialogo());
      await tester.pumpAndSettle();

      expect(auth.cierresDeSesion, 1);
    });
  });
}
