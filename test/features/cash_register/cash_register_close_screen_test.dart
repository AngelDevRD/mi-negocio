import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/cash_register/domain/entities/caja_sesion.dart';
import 'package:app_gestion/features/cash_register/presentation/providers/cash_register_providers.dart';
import 'package:app_gestion/features/cash_register/presentation/screens/cash_register_close_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'RN-08: no lanza al teclear un monto contado inválido (ej. "1.2.3")',
    (tester) async {
      final sesion = CajaSesion(
        id: 'sesion-1',
        fechaApertura: DateTime.utc(2026, 1, 1),
        montoApertura: const Money(0),
        usuarioAperturaNombre: 'Admin',
        estado: EstadoCajaSesion.abierta,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Se reemplaza el stream real (respaldado por drift) por uno
            // sintético: lo que se prueba aquí es la lógica de la pantalla
            // ante texto inválido, no la capa de persistencia (ya cubierta
            // en cash_register_repository_impl_test.dart).
            sesionActualProvider.overrideWith((ref) => Stream.value(sesion)),
          ],
          child: const MaterialApp(home: CashRegisterCloseScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Campo "Monto contado en caja": primero en la pantalla (autofocus).
      final campoMontoContado = find.byType(TextFormField).first;
      await tester.enterText(campoMontoContado, '1.2.3');
      await tester.pump();

      // El bug original lanzaba FormatException DENTRO del build (Money.parse
      // sin protección); con el fix, tryParse trata la entrada inválida como
      // si el campo estuviera vacío y no revienta la pantalla.
      expect(tester.takeException(), isNull);
    },
  );
}
