import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' hide Venta, VentaItem;
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../data/datasources/sales_local_datasource.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/entities/venta.dart';
import '../../domain/repositories/sales_repository.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepositoryImpl(
    SalesLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

/// Filtros activos de la lista de ventas.
class VentasFiltro {
  const VentasFiltro({this.estado, this.desde, this.hasta});

  final EstadoVenta? estado;
  final DateTime? desde;
  final DateTime? hasta;

  VentasFiltro copyWith({
    Object? estado = _sinCambio,
    Object? desde = _sinCambio,
    Object? hasta = _sinCambio,
  }) {
    return VentasFiltro(
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
  return ref
      .watch(salesRepositoryProvider)
      .watchVentas(
        estado: filtro.estado,
        desde: filtro.desde,
        hasta: filtro.hasta,
      );
});

final ventaProvider = FutureProvider.autoDispose.family<Venta?, String>((
  ref,
  id,
) {
  return ref.watch(salesRepositoryProvider).obtenerVenta(id);
});

/// Estado del carrito de una venta nueva (rápida o detallada).
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
  }) {
    return ref
        .read(salesRepositoryProvider)
        .registrarVenta(
          tipo: tipo,
          items: state.items,
          nota: state.nota,
          usuarioId: usuarioId,
        );
  }
}

final ventaRapidaCarritoProvider =
    NotifierProvider<CarritoVentaController, CarritoVentaState>(
      CarritoVentaController.new,
    );

final ventaDetalladaCarritoProvider =
    NotifierProvider<CarritoVentaController, CarritoVentaState>(
      CarritoVentaController.new,
    );
