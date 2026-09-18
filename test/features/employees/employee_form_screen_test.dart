import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/employees/presentation/screens/employee_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SesionFija extends AuthController {
  _SesionFija(this._estado);
  final EstadoSesion _estado;

  @override
  Future<EstadoSesion> build() async => _estado;
}

void main() {
  testWidgets(
    'RF-EMP-02: "." en salario muestra "Monto inválido", no se queda '
    'guardando y no lanza',
    (tester) async {
      const usuario = Usuario(
        id: 'u1',
        negocioId: 'n1',
        nombre: 'Admin',
        username: 'admin',
        rol: RolUsuario.administrador,
        activo: true,
      );

      // El formulario tiene más campos de los que caben en el viewport por
      // defecto del test: sin esto, el campo Salario nunca se construye (la
      // ListView es perezosa) y find.byType no lo encuentra.
      await tester.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => _SesionFija(const SesionActiva(usuario)),
            ),
          ],
          child: const MaterialApp(home: EmployeeFormScreen()),
        ),
      );
      await tester.pump();

      // Orden de campos en el formulario: Nombre, Cédula, Dirección,
      // Teléfono, Salario.
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Juan Pérez');
      await tester.enterText(campos.at(4), '.');

      await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pump();

      // El bug original: sin validator en salario, el formulario se daba
      // por válido, se activaba _guardando y Money.parse('.') lanzaba
      // FormatException a mitad del guardado -- el botón quedaba con el
      // indicador de progreso para siempre, sin mensaje.
      expect(find.text('Monto inválido'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
