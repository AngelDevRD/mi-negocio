import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' hide Compra, CompraItem;
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../data/datasources/purchases_local_datasource.dart';
import '../../data/repositories/purchases_repository_impl.dart';
import '../../domain/entities/compra.dart';
import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/purchases_repository.dart';

final purchasesRepositoryProvider = Provider<PurchasesRepository>((ref) {
  return PurchasesRepositoryImpl(
    PurchasesLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

final proveedoresProvider = StreamProvider<List<Proveedor>>((ref) {
  return ref.watch(purchasesRepositoryProvider).watchProveedores();
});

/// Filtros activos de la lista de compras.
class ComprasFiltro {
  const ComprasFiltro({this.proveedorId, this.desde, this.hasta});

  final String? proveedorId;
  final DateTime? desde;
  final DateTime? hasta;

  ComprasFiltro copyWith({
    Object? proveedorId = _sinCambio,
    Object? desde = _sinCambio,
    Object? hasta = _sinCambio,
  }) {
    return ComprasFiltro(
      proveedorId: proveedorId == _sinCambio
          ? this.proveedorId
          : proveedorId as String?,
      desde: desde == _sinCambio ? this.desde : desde as DateTime?,
      hasta: hasta == _sinCambio ? this.hasta : hasta as DateTime?,
    );
  }

  static const _sinCambio = Object();
}

final comprasFiltroProvider =
    NotifierProvider<ComprasFiltroController, ComprasFiltro>(
      ComprasFiltroController.new,
    );

class ComprasFiltroController extends Notifier<ComprasFiltro> {
  @override
  ComprasFiltro build() => const ComprasFiltro();

  void actualizar(ComprasFiltro Function(ComprasFiltro actual) update) {
    state = update(state);
  }
}

final comprasProvider = StreamProvider<List<Compra>>((ref) {
  final filtro = ref.watch(comprasFiltroProvider);
  return ref
      .watch(purchasesRepositoryProvider)
      .watchCompras(
        proveedorId: filtro.proveedorId,
        desde: filtro.desde,
        hasta: filtro.hasta,
      );
});

final compraProvider = FutureProvider.autoDispose.family<Compra?, String>((
  ref,
  id,
) {
  return ref.watch(purchasesRepositoryProvider).obtenerCompra(id);
});

/// Estado del formulario de nueva compra.
class NuevaCompraState {
  const NuevaCompraState({
    this.proveedorId,
    this.numeroFactura,
    this.fotoFacturaPath,
    this.pagadaDeCaja = false,
    this.items = const [],
  });

  final String? proveedorId;
  final String? numeroFactura;
  final String? fotoFacturaPath;
  final bool pagadaDeCaja;
  final List<ItemCompraInput> items;

  Money get total => items.fold(
    const Money(0),
    (suma, item) => Money(suma.cents + item.subtotal.cents),
  );

  NuevaCompraState copyWith({
    Object? proveedorId = _sinCambio,
    Object? numeroFactura = _sinCambio,
    Object? fotoFacturaPath = _sinCambio,
    bool? pagadaDeCaja,
    List<ItemCompraInput>? items,
  }) {
    return NuevaCompraState(
      proveedorId: proveedorId == _sinCambio
          ? this.proveedorId
          : proveedorId as String?,
      numeroFactura: numeroFactura == _sinCambio
          ? this.numeroFactura
          : numeroFactura as String?,
      fotoFacturaPath: fotoFacturaPath == _sinCambio
          ? this.fotoFacturaPath
          : fotoFacturaPath as String?,
      pagadaDeCaja: pagadaDeCaja ?? this.pagadaDeCaja,
      items: items ?? this.items,
    );
  }

  static const _sinCambio = Object();
}

final nuevaCompraProvider =
    NotifierProvider<NuevaCompraController, NuevaCompraState>(
      NuevaCompraController.new,
    );

class NuevaCompraController extends Notifier<NuevaCompraState> {
  @override
  NuevaCompraState build() => const NuevaCompraState();

  void seleccionarProveedor(String? proveedorId) {
    state = state.copyWith(proveedorId: proveedorId);
  }

  void establecerNumeroFactura(String? numeroFactura) {
    state = state.copyWith(numeroFactura: numeroFactura);
  }

  void establecerFotoFactura(String? path) {
    state = state.copyWith(fotoFacturaPath: path);
  }

  void establecerPagadaDeCaja(bool valor) {
    state = state.copyWith(pagadaDeCaja: valor);
  }

  void agregarItem(ItemCompraInput item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void quitarItem(int indice) {
    final items = [...state.items]..removeAt(indice);
    state = state.copyWith(items: items);
  }

  void limpiar() => state = const NuevaCompraState();

  Future<Result<String>> registrar({required String usuarioId}) {
    return ref
        .read(purchasesRepositoryProvider)
        .registrarCompra(
          proveedorId: state.proveedorId,
          numeroFactura: state.numeroFactura,
          fotoFacturaPath: state.fotoFacturaPath,
          items: state.items,
          pagadaDeCaja: state.pagadaDeCaja,
          usuarioId: usuarioId,
        );
  }
}
