import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' hide Venta, VentaItem;
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/rango_fecha.dart';
import '../../../settings/data/datasources/settings_local_datasource.dart';
import '../../data/datasources/sales_local_datasource.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/entities/venta.dart';
import '../../domain/repositories/sales_repository.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SalesRepositoryImpl(
    SalesLocalDatasource(db),
    SettingsLocalDatasource(db),
  );
});

/// Filtros activos de la lista de ventas.
///
/// [rango] es el período elegido; [desde]/[hasta] solo cuentan con
/// [RangoFecha.personalizado] (los demás rangos se calculan al consultar, así
/// "Hoy" sigue siendo hoy aunque la app pase la medianoche abierta).
class VentasFiltro {
  const VentasFiltro({
    this.estado,
    this.rango = RangoFecha.todo,
    this.desde,
    this.hasta,
  });

  final EstadoVenta? estado;
  final RangoFecha rango;
  final DateTime? desde;
  final DateTime? hasta;

  /// `true` si hay algún filtro activo (estado o fecha).
  bool get activo => estado != null || rango != RangoFecha.todo;

  VentasFiltro copyWith({
    Object? estado = _sinCambio,
    RangoFecha? rango,
    Object? desde = _sinCambio,
    Object? hasta = _sinCambio,
  }) {
    return VentasFiltro(
      rango: rango ?? this.rango,
      estado: estado == _sinCambio ? this.estado : estado as EstadoVenta?,
      desde: desde == _sinCambio ? this.desde : desde as DateTime?,
      hasta: hasta == _sinCambio ? this.hasta : hasta as DateTime?,
    );
  }

  static const _sinCambio = Object();
}

final ventasFiltroProvider =
    NotifierProvider<VentasFiltroController, VentasFiltro>(
      VentasFiltroController.new,
    );

class VentasFiltroController extends Notifier<VentasFiltro> {
  @override
  VentasFiltro build() => const VentasFiltro();

  void actualizar(VentasFiltro Function(VentasFiltro actual) update) {
    state = update(state);
  }
}

final ventasProvider = StreamProvider<List<Venta>>((ref) {
  final filtro = ref.watch(ventasFiltroProvider);
  final limites = limitesDeRango(
    filtro.rango,
    DateTime.now(),
    desde: filtro.desde,
    hasta: filtro.hasta,
  );
  return ref
      .watch(salesRepositoryProvider)
      .watchVentas(
        estado: filtro.estado,
        desde: limites.desde,
        hasta: limites.hasta,
      );
});

final ventaProvider = FutureProvider.autoDispose.family<Venta?, String>((
  ref,
  id,
) {
  return ref.watch(salesRepositoryProvider).obtenerVenta(id);
});

/// Estado del carrito de una venta nueva.
class CarritoVentaState {
  const CarritoVentaState({this.items = const [], this.nota});

  final List<ItemVentaInput> items;
  final String? nota;

  Money get total => items.fold(
    const Money(0),
    (suma, item) => Money(suma.cents + item.subtotal.cents),
  );

  CarritoVentaState copyWith({
    List<ItemVentaInput>? items,
    Object? nota = _sinCambio,
  }) {
    return CarritoVentaState(
      items: items ?? this.items,
      nota: nota == _sinCambio ? this.nota : nota as String?,
    );
  }

  static const _sinCambio = Object();
}

/// Carrito de una venta nueva: agrega/edita ítems y registra la venta.
class CarritoVentaController extends Notifier<CarritoVentaState> {
  @override
  CarritoVentaState build() => const CarritoVentaState();

  /// Agrega un ítem; si el producto ya está en el carrito, suma la cantidad.
  void agregarItem(ItemVentaInput item) {
    final indice = state.items.indexWhere(
      (i) => i.productoId == item.productoId,
    );
    if (indice >= 0) {
      final items = [...state.items];
      final actual = items[indice];
      items[indice] = actual.copyWith(
        cantidad: actual.cantidad + item.cantidad,
      );
      state = state.copyWith(items: items);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  void actualizarCantidad(int indice, double cantidad) {
    final items = [...state.items];
    items[indice] = items[indice].copyWith(cantidad: cantidad);
    state = state.copyWith(items: items);
  }

  void actualizarPrecio(int indice, Money precioUnitario) {
    final items = [...state.items];
    items[indice] = items[indice].copyWith(precioUnitario: precioUnitario);
    state = state.copyWith(items: items);
  }

  void quitarItem(int indice) {
    final items = [...state.items]..removeAt(indice);
    state = state.copyWith(items: items);
  }

  void establecerNota(String? nota) {
    state = state.copyWith(nota: nota);
  }

  void limpiar() => state = const CarritoVentaState();

  Future<Result<String>> registrar({
    required TipoVenta tipo,
    required String usuarioId,
    MetodoPago metodoPago = MetodoPago.efectivo,
    String? clienteId,
  }) {
    return ref
        .read(salesRepositoryProvider)
        .registrarVenta(
          tipo: tipo,
          items: state.items,
          nota: state.nota,
          usuarioId: usuarioId,
          metodoPago: metodoPago,
          clienteId: clienteId,
        );
  }
}

/// Único carrito de venta: lo usa el punto de venta (PosScreen).
final carritoVentaProvider =
    NotifierProvider<CarritoVentaController, CarritoVentaState>(
      CarritoVentaController.new,
    );

/// Fase del cobro en curso.
enum FaseCobro { libre, ingresandoMonto, registrando }

/// Fase actual del cobro. Bloquea un segundo cobro desde que se pulsa "Cobrar"
/// (diálogo abierto y registro incluidos), sea desde la barra del teléfono o
/// desde el panel/hoja del carrito; el progreso solo se muestra al registrar.
final faseCobroProvider = NotifierProvider<FaseCobroController, FaseCobro>(
  FaseCobroController.new,
);

class FaseCobroController extends Notifier<FaseCobro> {
  @override
  FaseCobro build() => FaseCobro.libre;

  void establecer(FaseCobro fase) => state = fase;
}
