import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/router/app_router.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:app_gestion/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:app_gestion/features/products/domain/entities/producto.dart';
import 'package:app_gestion/features/products/domain/repositories/products_repository.dart';
import 'package:app_gestion/features/products/presentation/providers/products_providers.dart';
import 'package:app_gestion/features/sales/domain/entities/venta.dart';
import 'package:app_gestion/features/sales/domain/repositories/sales_repository.dart';
import 'package:app_gestion/features/sales/presentation/providers/sales_providers.dart';
import 'package:app_gestion/features/sales/presentation/screens/pos_screen.dart';
import 'package:app_gestion/features/sales/presentation/screens/sales_list_screen.dart';
import 'package:app_gestion/features/sales/presentation/widgets/abrir_caja_dialog.dart';
import 'package:app_gestion/features/sales/presentation/widgets/pos_widgets.dart';
import 'package:app_gestion/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Repositorio de productos en memoria (sin drift: sus streams dejan timers
/// pendientes en los widget tests).
class _ProductosFalsos implements ProductsRepository {
  _ProductosFalsos(this.productos);

  final List<Producto> productos;

  @override
  Stream<List<Producto>> watchProductos({
    String busqueda = '',
    String? categoriaId,
    bool? activo,
  }) {
    final texto = busqueda.trim().toLowerCase();
    return Stream.value([
      for (final p in productos)
        if ((activo == null || p.activo == activo) &&
            p.nombre.toLowerCase().contains(texto))
          p,
    ]);
  }

  @override
  Future<Producto?> obtenerProducto(String id) async =>
      productos.where((p) => p.id == id).firstOrNull;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Ventas que solo registran lo recibido en [registradas].
class _VentasFalsas implements SalesRepository {
  final registradas =
      <
        ({
          TipoVenta tipo,
          List<ItemVentaInput> items,
          String? nota,
          String usuarioId,
          MetodoPago metodoPago,
        })
      >[];

  @override
  Stream<List<Venta>> watchVentas({
    EstadoVenta? estado,
    DateTime? desde,
    DateTime? hasta,
  }) => Stream.value(const []);

  /// Llamadas a registrarVenta (incluye las que fallan o siguen pendientes).
  int llamadas = 0;

  /// Si no es null, el registro espera este completer (simula un registro
  /// lento).
  Completer<void>? pausa;

  /// Si no es null, el registro falla con este mensaje.
  String? falla;

  /// Si es true, el registro LANZA una excepción (no devuelve Result).
  bool lanza = false;

  @override
  Future<Result<String>> registrarVenta({
    required TipoVenta tipo,
    required List<ItemVentaInput> items,
    String? nota,
    required String usuarioId,
    MetodoPago metodoPago = MetodoPago.efectivo,
  }) async {
    llamadas++;
    await pausa?.future;
    if (lanza) throw StateError('base de datos caída');
    if (falla != null) return Result.fail(DatabaseFailure(falla!));
    registradas.add((
      tipo: tipo,
      items: items,
      nota: nota,
      usuarioId: usuarioId,
      metodoPago: metodoPago,
    ));
    return const Result.ok('venta-1');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

Producto _producto(
  String nombre, {
  Money precio = const Money(15000),
  double stock = 20,
  double minimo = 2,
  String unidad = 'unidad',
}) => Producto(
  id: nombre,
  nombre: nombre,
  unidad: unidad,
  precioCompra: const Money(1000),
  precioVenta: precio,
  stockActual: stock,
  stockMinimo: minimo,
  activo: true,
);

final _caja = CajaActual(
  sesionId: 'sesion',
  fechaApertura: DateTime(2026),
  montoApertura: const Money(0),
  montoActual: const Money(0),
);

const _telefono = Size(400, 800);
const _escritorio = Size(1400, 900);

/// Tamaño lógico de pantalla (DPR 1) para que MediaQuery lo refleje.
void _fijarTamano(WidgetTester tester, Size tamano) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamano;
  addTearDown(tester.view.reset);
}

class _Escenario {
  _Escenario(this.ventas);
  final _VentasFalsas ventas;
}

Future<_Escenario> _montar(
  WidgetTester tester, {
  Size tamano = _escritorio,
  RolUsuario rol = RolUsuario.cajero,
  List<Producto>? productos,
  bool cajaAbierta = true,
  bool permitirStock = true,
  Widget home = const PosScreen(),
}) async {
  _fijarTamano(tester, tamano);

  final ventas = _VentasFalsas();
  final List<Override> overrides = [
    productsRepositoryProvider.overrideWithValue(
      _ProductosFalsos(productos ?? [_producto('Arroz'), _producto('Salami')]),
    ),
    salesRepositoryProvider.overrideWithValue(ventas),
    cajaActualProvider.overrideWith(
      (ref) => Stream.value(cajaAbierta ? _caja : null),
    ),
    authControllerProvider.overrideWith(() => _AuthFalso(rol)),
    permitirStockNegativoProvider.overrideWith(
      (ref) => Stream.value(permitirStock),
    ),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: AppTheme.light(), home: home),
    ),
  );
  await tester.pumpAndSettle();
  // En producción el router mantiene viva la sesión; aquí se resuelve para que
  // el cobro desde la barra del teléfono (que no la observa) la encuentre.
  await ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(authControllerProvider.future);
  return _Escenario(ventas);
}

/// Toca un producto y confirma el diálogo de cantidad/monto con [cantidad].
Future<void> _agregar(
  WidgetTester tester,
  String nombre, {
  String? cantidad,
}) async {
  await tester.tap(find.text(nombre).first);
  await tester.pumpAndSettle();
  if (cantidad != null) {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cantidad (unidad)'),
      cantidad,
    );
  }
  await tester.tap(find.text('Agregar'));
  await tester.pumpAndSettle();
}

/// Texto dentro del panel del carrito (las tarjetas también muestran precios).
Finder _enCarrito(String texto) =>
    find.descendant(of: find.byType(CarritoPanel), matching: find.text(texto));

Finder _boton(String texto) => find.widgetWithText(FilledButton, texto);

Future<void> _cobrar(WidgetTester tester) async {
  await tester.tap(_boton('Cobrar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Confirmar'));
  await tester.pumpAndSettle();
}

/// Habilitación del campo "Precio unitario" del diálogo de edición.
bool _precioEditable(WidgetTester tester) {
  final campo = find.descendant(
    of: find.byType(EditarLineaDialog),
    matching: find.byType(TextField),
  );
  return tester.widget<TextField>(campo.last).enabled ?? true;
}

void main() {
  group('agregar productos', () {
    testWidgets('tocar un producto abre cantidad/monto; la línea aparece y '
        'el total se actualiza', (tester) async {
      await _montar(tester);
      expect(find.text('Toca un producto para agregarlo'), findsOneWidget);

      await tester.tap(find.text('Arroz'));
      await tester.pumpAndSettle();
      expect(find.byType(CantidadMontoDialog), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cantidad (unidad)'),
        '2',
      );
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      expect(find.text('Toca un producto para agregarlo'), findsNothing);
      // Nombre: tarjeta + línea del carrito.
      expect(find.text('Arroz'), findsNWidgets(2));
      expect(_enCarrito('RD\$ 150.00 c/u'), findsOneWidget);
      // 2 × RD$ 150.00 = RD$ 300.00 (subtotal de la línea y total).
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));
    });

    testWidgets('vender por monto calcula la cantidad', (tester) async {
      await _montar(
        tester,
        productos: [_producto('Chuleta', precio: const Money(30000))],
      );

      await tester.tap(find.text('Chuleta'));
      await tester.pumpAndSettle();
      // RD$ 150 de una chuleta de RD$ 300 = 0.5.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Monto a vender'),
        '150',
      );
      await tester.pump();
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      expect(find.text('0.5'), findsOneWidget);
      expect(_enCarrito('RD\$ 150.00'), findsNWidgets(2));
    });

    testWidgets('la advertencia de stock insuficiente sigue apareciendo', (
      tester,
    ) async {
      await _montar(tester, productos: [_producto('Arroz', stock: 2)]);

      await _agregar(tester, 'Arroz', cantidad: '5');
      expect(find.text('Stock insuficiente'), findsOneWidget);

      // Cancelar: no se agrega nada.
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Toca un producto para agregarlo'), findsOneWidget);

      // Continuar: se agrega igual (RN-12).
      await _agregar(tester, 'Arroz', cantidad: '5');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Toca un producto para agregarlo'), findsNothing);
      expect(_enCarrito('RD\$ 750.00'), findsNWidgets(2));
    });

    testWidgets('las tarjetas indican la disponibilidad con texto', (
      tester,
    ) async {
      await _montar(
        tester,
        productos: [
          _producto('Normal', stock: 12),
          _producto('Poco', stock: 3, minimo: 5),
          _producto('Agotado', stock: 0),
        ],
      );

      expect(find.text('12 unidades'), findsOneWidget);
      expect(find.text('Stock bajo: 3'), findsOneWidget);
      expect(find.text('Sin stock'), findsOneWidget);
    });

    testWidgets('buscar filtra la cuadrícula', (tester) async {
      await _montar(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar producto'),
        'sal',
      );
      await tester.pumpAndSettle();

      expect(find.text('Salami'), findsOneWidget);
      expect(find.text('Arroz'), findsNothing);
    });
  });

  group('editar el carrito', () {
    testWidgets('editar la cantidad de una línea actualiza el total', (
      tester,
    ) async {
      await _montar(tester);
      await _agregar(tester, 'Arroz');
      expect(_enCarrito('RD\$ 150.00'), findsNWidgets(2));

      // Tocar la cantidad abre la edición.
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cantidad'),
        '3',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(_enCarrito('RD\$ 450.00'), findsNWidgets(2));
    });

    testWidgets('los botones -/+ y quitar modifican la línea', (tester) async {
      await _montar(tester);
      await _agregar(tester, 'Arroz');

      await tester.tap(find.byTooltip('Agregar uno'));
      await tester.pump();
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Quitar del carrito'));
      await tester.pump();
      expect(find.text('Toca un producto para agregarlo'), findsOneWidget);
    });

    testWidgets('un cajero NO puede editar el precio de una línea', (
      tester,
    ) async {
      await _montar(tester, rol: RolUsuario.cajero);
      await _agregar(tester, 'Arroz');

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(_precioEditable(tester), isFalse);
    });

    testWidgets('un administrador SÍ puede editar el precio', (tester) async {
      await _montar(tester, rol: RolUsuario.administrador);
      await _agregar(tester, 'Arroz');

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(_precioEditable(tester), isTrue);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Precio unitario'),
        '200',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(_enCarrito('RD\$ 200.00 c/u'), findsOneWidget);
      expect(_enCarrito('RD\$ 200.00'), findsNWidgets(2));
    });
  });

  group('cobro', () {
    testWidgets('"Cobrar" registra la venta (rápida) con nota y vacía el '
        'carrito', (tester) async {
      final escenario = await _montar(tester);
      await _agregar(tester, 'Arroz', cantidad: '2');
      await tester.enterText(
        find.widgetWithText(TextField, 'Nota (opcional)'),
        'Para llevar',
      );

      await _cobrar(tester);

      expect(escenario.ventas.registradas, hasLength(1));
      final venta = escenario.ventas.registradas.single;
      expect(venta.tipo, TipoVenta.rapida);
      expect(venta.nota, 'Para llevar');
      expect(venta.usuarioId, 'u-cajero');
      expect(venta.items.single.productoId, 'Arroz');
      expect(venta.items.single.cantidad, 2);

      // Carrito y nota quedan vacíos.
      expect(find.text('Toca un producto para agregarlo'), findsOneWidget);
      final nota = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Nota (opcional)'),
      );
      expect(nota.controller!.text, isEmpty);
      expect(find.text('Venta registrada · Cambio RD\$ 0.00'), findsOneWidget);
    });

    testWidgets('"Cobrar" está deshabilitado con el carrito vacío', (
      tester,
    ) async {
      await _montar(tester);

      expect(tester.widget<FilledButton>(_boton('Cobrar')).onPressed, isNull);
    });
  });

  group('RN-12 en el POS', () {
    testWidgets('ajuste permitido: advierte y deja continuar (con unidades)', (
      tester,
    ) async {
      await _montar(tester, productos: [_producto('Arroz', stock: 2)]);

      await _agregar(tester, 'Arroz', cantidad: '5');

      expect(find.text('Stock insuficiente'), findsOneWidget);
      expect(
        find.text(
          '"Arroz" tiene 2 unidades en existencia. ¿Continuar de todos modos?',
        ),
        findsOneWidget,
      );
      expect(find.text('Continuar'), findsOneWidget);
      expect(find.text('Entendido'), findsNothing);
    });

    testWidgets('ajuste NO permitido: diálogo informativo sin "Continuar" y '
        'la línea no se agrega', (tester) async {
      await _montar(
        tester,
        productos: [_producto('Arroz', stock: 2)],
        permitirStock: false,
      );

      await _agregar(tester, 'Arroz', cantidad: '5');

      expect(find.text('Stock insuficiente'), findsOneWidget);
      expect(
        find.text(
          'No hay suficiente stock de Arroz (disponible: 2 unidades). '
          'Un administrador puede permitir vender sin stock en Ajustes.',
        ),
        findsOneWidget,
      );
      expect(find.text('Continuar'), findsNothing);
      expect(find.text('Cancelar'), findsNothing);

      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Toca un producto para agregarlo'), findsOneWidget);
      // La etiqueta de la tarjeta se mantiene.
      expect(find.text('Stock bajo: 2'), findsOneWidget);
    });

    testWidgets(
      'ajuste NO permitido pero con stock suficiente: agrega normal',
      (tester) async {
        await _montar(
          tester,
          productos: [_producto('Arroz', stock: 20)],
          permitirStock: false,
        );

        await _agregar(tester, 'Arroz', cantidad: '5');

        expect(find.text('Stock insuficiente'), findsNothing);
        expect(find.text('Toca un producto para agregarlo'), findsNothing);
      },
    );

    testWidgets('ajuste NO permitido: cuenta lo que ya está en el carrito', (
      tester,
    ) async {
      await _montar(
        tester,
        productos: [_producto('Arroz', stock: 10)],
        permitirStock: false,
      );

      await _agregar(tester, 'Arroz', cantidad: '6');
      await _agregar(tester, 'Arroz', cantidad: '6');

      expect(find.text('Stock insuficiente'), findsOneWidget);
      expect(find.text('Continuar'), findsNothing);
    });
  });

  group('RN-12 al editar el carrito', () {
    // Arroz: 2 en existencia, RD$ 150.00 c/u; se agregan 2 (justo el stock).
    Future<void> conDosEnCarrito(
      WidgetTester tester, {
      bool permitirStock = true,
      RolUsuario rol = RolUsuario.cajero,
    }) async {
      await _montar(
        tester,
        rol: rol,
        productos: [_producto('Arroz', stock: 2, minimo: 0)],
        permitirStock: permitirStock,
      );
      await _agregar(tester, 'Arroz', cantidad: '2');
      expect(find.text('Stock insuficiente'), findsNothing);
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));
    }

    Future<void> editarCantidad(WidgetTester tester, String cantidad) async {
      await tester.tap(
        find.descendant(
          of: find.byType(LineaCarrito),
          matching: find.byType(TextButton),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cantidad'),
        cantidad,
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
    }

    testWidgets('+ que supera el stock (permitido): advierte; Cancelar no '
        'cambia la cantidad; Continuar la sube', (tester) async {
      await conDosEnCarrito(tester);

      await tester.tap(find.byTooltip('Agregar uno'));
      await tester.pumpAndSettle();
      expect(find.text('Stock insuficiente'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Agregar uno'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(_enCarrito('RD\$ 450.00'), findsNWidgets(2));
    });

    testWidgets('+ que supera el stock (NO permitido): "Entendido" y la '
        'cantidad no cambia', (tester) async {
      await conDosEnCarrito(tester, permitirStock: false);

      await tester.tap(find.byTooltip('Agregar uno'));
      await tester.pumpAndSettle();

      expect(find.text('Stock insuficiente'), findsOneWidget);
      expect(find.text('Continuar'), findsNothing);
      expect(find.text('Cancelar'), findsNothing);
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));
    });

    testWidgets('+ dentro del stock no pregunta', (tester) async {
      await _montar(
        tester,
        productos: [_producto('Arroz', stock: 5, minimo: 0)],
        permitirStock: false,
      );
      await _agregar(tester, 'Arroz', cantidad: '2');

      await tester.tap(find.byTooltip('Agregar uno'));
      await tester.pumpAndSettle();

      expect(find.text('Stock insuficiente'), findsNothing);
      expect(_enCarrito('RD\$ 450.00'), findsNWidgets(2));
    });

    testWidgets('editar la cantidad hacia arriba aplica la misma regla '
        '(permitido: Cancelar no aplica, Continuar sí)', (tester) async {
      await conDosEnCarrito(tester);

      await editarCantidad(tester, '5');
      expect(find.text('Stock insuficiente'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));

      await editarCantidad(tester, '5');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(_enCarrito('RD\$ 750.00'), findsNWidgets(2));
    });

    testWidgets('editar la cantidad hacia arriba (NO permitido): '
        '"Entendido" y no se aplica', (tester) async {
      await conDosEnCarrito(tester, permitirStock: false);

      await editarCantidad(tester, '5');

      expect(find.text('Continuar'), findsNothing);
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));
    });

    testWidgets('cancelar la advertencia tampoco aplica el cambio de precio '
        'hecho en la misma edición (administrador)', (tester) async {
      await conDosEnCarrito(tester, rol: RolUsuario.administrador);

      await tester.tap(
        find.descendant(
          of: find.byType(LineaCarrito),
          matching: find.byType(TextButton),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Cantidad'),
        '5',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Precio unitario'),
        '200',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(_enCarrito('RD\$ 150.00 c/u'), findsOneWidget);
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));
    });

    testWidgets('editar hacia abajo o sin superar el stock no pregunta', (
      tester,
    ) async {
      await conDosEnCarrito(tester, permitirStock: false);

      await editarCantidad(tester, '1');

      expect(find.text('Stock insuficiente'), findsNothing);
      expect(_enCarrito('RD\$ 150.00'), findsNWidgets(2));
    });

    testWidgets('- NUNCA pregunta, aunque el carrito ya supere el stock', (
      tester,
    ) async {
      await conDosEnCarrito(tester);
      // Se sube a 3 con confirmación (supera el stock de 2).
      await tester.tap(find.byTooltip('Agregar uno'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(_enCarrito('RD\$ 450.00'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Quitar uno'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));
    });
  });

  group('método de pago en el cobro', () {
    Future<void> elegirMetodo(WidgetTester tester, String metodo) async {
      await tester.tap(_boton('Cobrar'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(SegmentedButton<MetodoPago>),
          matching: find.text(metodo),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('tarjeta: registra la venta con método tarjeta y lo dice', (
      tester,
    ) async {
      final escenario = await _montar(tester);
      await _agregar(tester, 'Arroz');

      await elegirMetodo(tester, 'Tarjeta');
      await tester.tap(find.text('Confirmar pago'));
      await tester.pumpAndSettle();

      final venta = escenario.ventas.registradas.single;
      expect(venta.metodoPago, MetodoPago.tarjeta);
      expect(find.text('Venta registrada · Tarjeta'), findsOneWidget);
      expect(find.text('Toca un producto para agregarlo'), findsOneWidget);
    });

    testWidgets('transferencia: registra método transferencia', (tester) async {
      final escenario = await _montar(tester);
      await _agregar(tester, 'Arroz');

      await elegirMetodo(tester, 'Transferencia');
      await tester.tap(find.text('Confirmar pago'));
      await tester.pumpAndSettle();

      expect(
        escenario.ventas.registradas.single.metodoPago,
        MetodoPago.transferencia,
      );
      expect(find.text('Venta registrada · Transferencia'), findsOneWidget);
    });

    testWidgets('efectivo (por defecto) conserva el flujo con cambio', (
      tester,
    ) async {
      final escenario = await _montar(tester);
      await _agregar(tester, 'Arroz');

      await _cobrar(tester);

      expect(
        escenario.ventas.registradas.single.metodoPago,
        MetodoPago.efectivo,
      );
      expect(find.text('Venta registrada · Cambio RD\$ 0.00'), findsOneWidget);
    });
  });

  group('cobro a prueba de errores', () {
    testWidgets('doble toque rápido en "Cobrar" produce UNA sola venta', (
      tester,
    ) async {
      final escenario = await _montar(tester);
      await _agregar(tester, 'Arroz');

      // Dos toques seguidos, sin frame entre ellos.
      await tester.tap(_boton('Cobrar'));
      await tester.tap(_boton('Cobrar'));
      await tester.pumpAndSettle();
      expect(find.byType(CobroDialog), findsOneWidget);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(escenario.ventas.llamadas, 1);
      expect(escenario.ventas.registradas, hasLength(1));
    });

    testWidgets('durante el registro el botón muestra progreso y no permite '
        'otro cobro', (tester) async {
      final escenario = await _montar(tester);
      escenario.ventas.pausa = Completer<void>();
      await _agregar(tester, 'Arroz');

      await tester.tap(_boton('Cobrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump();

      // Registro pendiente: progreso en el botón, deshabilitado.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final boton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(FilledButton),
        ),
      );
      expect(boton.onPressed, isNull);
      expect(escenario.ventas.llamadas, 1);

      escenario.ventas.pausa!.complete();
      await tester.pumpAndSettle();

      expect(escenario.ventas.registradas, hasLength(1));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Toca un producto para agregarlo'), findsOneWidget);
    });

    testWidgets('teléfono: doble toque en "Cobrar" de la barra = una venta', (
      tester,
    ) async {
      final escenario = await _montar(tester, tamano: _telefono);
      await _agregar(tester, 'Arroz');

      await tester.tap(_boton('Cobrar'));
      await tester.tap(_boton('Cobrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(escenario.ventas.llamadas, 1);
      expect(escenario.ventas.registradas, hasLength(1));
    });

    testWidgets('cancelar el diálogo libera el guard y permite cobrar de '
        'nuevo', (tester) async {
      final escenario = await _montar(tester);
      await _agregar(tester, 'Arroz');

      await tester.tap(_boton('Cobrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(escenario.ventas.llamadas, 0);

      await _cobrar(tester);
      expect(escenario.ventas.registradas, hasLength(1));
    });

    testWidgets('si el registro falla el carrito se conserva y se avisa', (
      tester,
    ) async {
      final escenario = await _montar(tester);
      escenario.ventas.falla = 'No hay caja abierta.';
      await _agregar(tester, 'Arroz', cantidad: '2');
      await tester.enterText(
        find.widgetWithText(TextField, 'Nota (opcional)'),
        'Para llevar',
      );

      await _cobrar(tester);

      expect(escenario.ventas.llamadas, 1);
      expect(escenario.ventas.registradas, isEmpty);
      expect(find.text('No hay caja abierta.'), findsOneWidget);
      // Las líneas y la nota siguen ahí.
      expect(find.text('Toca un producto para agregarlo'), findsNothing);
      expect(_enCarrito('RD\$ 300.00'), findsNWidgets(2));
      final nota = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Nota (opcional)'),
      );
      expect(nota.controller!.text, 'Para llevar');

      // El guard se liberó: se puede reintentar (el snackbar de error tapa el
      // botón hasta que se cierra).
      escenario.ventas.falla = null;
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      await _cobrar(tester);
      expect(escenario.ventas.registradas, hasLength(1));
    });
  });

  group('cobro: robustez ante desmontaje y excepciones', () {
    testWidgets('si la pantalla se desmonta mientras se registra, la venta '
        'queda guardada UNA vez y el carrito global se limpia', (tester) async {
      final visible = ValueNotifier<bool>(true);
      addTearDown(visible.dispose);
      final escenario = await _montar(
        tester,
        home: ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (_, mostrar, _) =>
              mostrar ? const PosScreen() : const SizedBox.shrink(),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      escenario.ventas.pausa = Completer<void>();
      await _agregar(tester, 'Arroz');
      await tester.enterText(
        find.widgetWithText(TextField, 'Nota (opcional)'),
        'Para llevar',
      );

      await tester.tap(_boton('Cobrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();
      await tester.pump();
      expect(escenario.ventas.llamadas, 1);

      // El cajero sale de la pantalla con el registro pendiente.
      visible.value = false;
      await tester.pump();
      expect(find.byType(PosScreen), findsNothing);

      escenario.ventas.pausa!.complete();
      await tester.pumpAndSettle();

      expect(escenario.ventas.registradas, hasLength(1));
      final carrito = container.read(carritoVentaProvider);
      expect(carrito.items, isEmpty);
      expect(carrito.nota, isNull);
      expect(container.read(faseCobroProvider), FaseCobro.libre);
      expect(tester.takeException(), isNull);
    });

    testWidgets('si registrar LANZA: se avisa, el carrito queda intacto y el '
        'guard se libera', (tester) async {
      final escenario = await _montar(tester);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      escenario.ventas.lanza = true;
      await _agregar(tester, 'Arroz', cantidad: '2');

      await _cobrar(tester);

      expect(escenario.ventas.llamadas, 1);
      expect(
        find.text('No se pudo registrar la venta. Intenta de nuevo.'),
        findsOneWidget,
      );
      expect(container.read(carritoVentaProvider).items, hasLength(1));
      expect(container.read(carritoVentaProvider).items.single.cantidad, 2);
      expect(container.read(faseCobroProvider), FaseCobro.libre);
      expect(tester.takeException(), isNull);

      // Se puede reintentar.
      escenario.ventas.lanza = false;
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      await _cobrar(tester);
      expect(escenario.ventas.registradas, hasLength(1));
    });
  });

  group('tarjetas del catálogo', () {
    testWidgets('el stock lleva su unidad y "unidad" se pluraliza', (
      tester,
    ) async {
      await _montar(
        tester,
        productos: [
          _producto('Una', stock: 1, minimo: 0),
          _producto('Varias', stock: 34, minimo: 0),
          _producto('Carne', unidad: 'lb', stock: 8.5, minimo: 0),
        ],
      );

      expect(find.text('1 unidad'), findsOneWidget);
      expect(find.text('34 unidades'), findsOneWidget);
      expect(find.text('8.5 lb'), findsOneWidget);
    });

    testWidgets('un producto en el carrito muestra "En carrito: N" y borde '
        'primario', (tester) async {
      await _montar(tester);
      expect(find.textContaining('En carrito'), findsNothing);

      await _agregar(tester, 'Arroz', cantidad: '2');

      expect(find.text('En carrito: 2'), findsOneWidget);
      final tarjeta = tester.widget<Card>(
        find.ancestor(
          of: find.text('En carrito: 2'),
          matching: find.byType(Card),
        ),
      );
      final forma = tarjeta.shape! as RoundedRectangleBorder;
      expect(
        forma.side.color,
        Theme.of(tester.element(find.byType(PosScreen))).colorScheme.primary,
      );
      // La otra tarjeta no está marcada.
      expect(find.textContaining('En carrito'), findsOneWidget);
    });
  });

  group('distribución', () {
    testWidgets('escritorio: panel lateral con carrito y búsqueda enfocada', (
      tester,
    ) async {
      await _montar(tester);
      expect(find.byType(CarritoPanel), findsOneWidget);
      expect(find.byType(BarraCarrito), findsNothing);
      final busqueda = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Buscar producto'),
      );
      expect(busqueda.autofocus, isTrue);
    });

    testWidgets('teléfono: sin barra con el carrito vacío y sin autofocus', (
      tester,
    ) async {
      await _montar(tester, tamano: _telefono);

      expect(find.byType(CarritoPanel), findsNothing);
      expect(find.byType(BarraCarrito), findsNothing);
      final busqueda = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Buscar producto'),
      );
      expect(busqueda.autofocus, isFalse);
    });

    testWidgets('teléfono: la barra muestra artículos y total; tocarla abre '
        'la hoja con las líneas', (tester) async {
      await _montar(tester, tamano: _telefono);
      await _agregar(tester, 'Arroz');
      await _agregar(tester, 'Salami', cantidad: '2');

      expect(find.byType(BarraCarrito), findsOneWidget);
      expect(find.text('2 artículos'), findsOneWidget);
      expect(find.text('RD\$ 450.00'), findsOneWidget);

      await tester.tap(find.text('2 artículos'));
      await tester.pumpAndSettle();

      expect(find.byType(CarritoPanel), findsOneWidget);
      expect(find.text('Carrito'), findsOneWidget);
      expect(_enCarrito('RD\$ 150.00 c/u'), findsNWidgets(2));
    });

    testWidgets('teléfono: cobrar desde la hoja cierra la hoja y registra', (
      tester,
    ) async {
      final escenario = await _montar(tester, tamano: _telefono);
      await _agregar(tester, 'Arroz');
      await tester.tap(find.text('1 artículo'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(CarritoPanel),
          matching: find.widgetWithText(FilledButton, 'Cobrar'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(escenario.ventas.registradas, hasLength(1));
      expect(find.byType(CarritoPanel), findsNothing);
      expect(find.byType(BarraCarrito), findsNothing);
    });

    testWidgets('con texto grande las tarjetas no desbordan', (tester) async {
      _fijarTamano(tester, _telefono);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productsRepositoryProvider.overrideWithValue(
              _ProductosFalsos([
                _producto(
                  'Producto con un nombre bastante largo de verdad',
                  stock: 3,
                  minimo: 5,
                  precio: const Money(123456789),
                ),
              ]),
            ),
            cajaActualProvider.overrideWith((ref) => Stream.value(_caja)),
            authControllerProvider.overrideWith(
              () => _AuthFalso(RolUsuario.cajero),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.6)),
              child: child!,
            ),
            home: const PosScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Stock bajo: 3'), findsOneWidget);
    });
  });

  group('caja cerrada', () {
    testWidgets('pide abrir la caja antes de vender', (tester) async {
      await _montar(tester, cajaAbierta: false);

      expect(find.byType(CajaCerradaView), findsOneWidget);
      expect(find.byType(ProductoPosTile), findsNothing);
      expect(find.byType(CarritoPanel), findsNothing);
    });
  });

  group('rutas', () {
    testWidgets('"Nueva venta" de la pestaña Ventas abre el POS sin hoja '
        'intermedia', (tester) async {
      _fijarTamano(tester, _telefono);

      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SalesListScreen()),
          GoRoute(
            path: AppRoutes.ventaRapida,
            builder: (_, _) => const PosScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ventasProvider.overrideWith((ref) => Stream.value(const [])),
            productsRepositoryProvider.overrideWithValue(
              _ProductosFalsos([_producto('Arroz')]),
            ),
            cajaActualProvider.overrideWith((ref) => Stream.value(_caja)),
            authControllerProvider.overrideWith(
              () => _AuthFalso(RolUsuario.cajero),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nueva venta'));
      await tester.pumpAndSettle();

      expect(find.byType(PosScreen), findsOneWidget);
      expect(find.text('Venta detallada'), findsNothing);
      expect(find.byType(BottomSheet), findsNothing);
    });
  });
}
