import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/sales/domain/entities/venta.dart';
import 'package:app_gestion/features/sales/presentation/providers/sales_providers.dart';
import 'package:app_gestion/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

Venta _venta({MetodoPago? metodoPago, String? clienteNombre}) => Venta(
  id: 'v1',
  tipo: TipoVenta.rapida,
  total: const Money(30000),
  ganancia: const Money(10000),
  estado: EstadoVenta.completada,
  usuarioNombre: 'Ana Admin',
  fecha: DateTime(2026, 1, 15, 10),
  items: const [
    VentaItem(
      productoId: 'p1',
      productoNombre: 'Salami',
      cantidad: 2,
      precioUnitario: Money(15000),
      costoUnitario: Money(10000),
    ),
  ],
  metodoPago: metodoPago,
  clienteNombre: clienteNombre,
);

Future<void> _montar(WidgetTester tester, Venta venta) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ventaProvider('v1').overrideWith((ref) async => venta),
        authControllerProvider.overrideWith(_AuthFalso.new),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const SaleDetailScreen(ventaId: 'v1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final entrada in {
    MetodoPago.efectivo: 'Efectivo',
    MetodoPago.tarjeta: 'Tarjeta',
    MetodoPago.transferencia: 'Transferencia',
  }.entries) {
    testWidgets('muestra "Método de pago: ${entrada.value}"', (tester) async {
      await _montar(tester, _venta(metodoPago: entrada.key));

      expect(find.text('Método de pago'), findsOneWidget);
      expect(find.text(entrada.value), findsOneWidget);
    });
  }

  testWidgets('una venta sin método cargado (histórica) se muestra como '
      'Efectivo', (tester) async {
    await _montar(tester, _venta());

    expect(find.text('Método de pago'), findsOneWidget);
    expect(find.text('Efectivo'), findsOneWidget);
  });

  group('diálogo de anulación según el método de pago', () {
    Future<void> abrirDialogo(WidgetTester tester, Venta venta) async {
      await _montar(tester, venta);
      await tester.ensureVisible(find.text('Anular venta'));
      await tester.tap(find.text('Anular venta'));
      await tester.pumpAndSettle();
    }

    testWidgets('efectivo: menciona el movimiento de caja (como antes)', (
      tester,
    ) async {
      await abrirDialogo(tester, _venta(metodoPago: MetodoPago.efectivo));

      expect(
        find.textContaining(
          'revertirá el stock de los productos y el '
          'movimiento de caja asociado',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('no afecta el efectivo'), findsNothing);
    });

    testWidgets('una venta histórica (sin método) se trata como efectivo', (
      tester,
    ) async {
      await abrirDialogo(tester, _venta());

      expect(
        find.textContaining('movimiento de caja asociado'),
        findsOneWidget,
      );
    });

    for (final entrada in {
      MetodoPago.tarjeta: 'tarjeta',
      MetodoPago.transferencia: 'transferencia',
    }.entries) {
      testWidgets(
        '${entrada.value}: dice que no afecta el efectivo de la caja',
        (tester) async {
          await abrirDialogo(tester, _venta(metodoPago: entrada.key));

          expect(
            find.textContaining(
              'Esta venta se cobró con ${entrada.value}: no '
              'afecta el efectivo de la caja.',
            ),
            findsOneWidget,
          );
          expect(
            find.textContaining('movimiento de caja asociado'),
            findsNothing,
          );
        },
      );
    }

    testWidgets('el botón de confirmar es destructivo (color de error)', (
      tester,
    ) async {
      await abrirDialogo(tester, _venta(metodoPago: MetodoPago.tarjeta));

      final boton = tester.widget<FilledButton>(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Anular'),
        ),
      );
      final esquema = Theme.of(
        tester.element(find.byType(AlertDialog)),
      ).colorScheme;
      expect(boton.style?.backgroundColor?.resolve({}), esquema.error);
    });
  });

  group('fiado (crédito)', () {
    testWidgets('muestra "Fiado · <cliente>" en el método de pago', (
      tester,
    ) async {
      await _montar(
        tester,
        _venta(metodoPago: MetodoPago.credito, clienteNombre: 'Doña Rosa'),
      );

      expect(find.text('Método de pago'), findsOneWidget);
      expect(find.text('Fiado · Doña Rosa'), findsOneWidget);
    });

    testWidgets('sin nombre de cliente muestra solo "Fiado"', (tester) async {
      await _montar(tester, _venta(metodoPago: MetodoPago.credito));

      expect(find.text('Fiado'), findsOneWidget);
    });

    testWidgets('la anulación explica que revierte la deuda del cliente', (
      tester,
    ) async {
      await _montar(
        tester,
        _venta(metodoPago: MetodoPago.credito, clienteNombre: 'Doña Rosa'),
      );
      await tester.ensureVisible(find.text('Anular venta'));
      await tester.tap(find.text('Anular venta'));
      await tester.pumpAndSettle();

      expect(find.textContaining('la deuda del cliente'), findsOneWidget);
      expect(
        find.textContaining('no afecta el efectivo de la caja'),
        findsOneWidget,
      );
    });
  });
}
