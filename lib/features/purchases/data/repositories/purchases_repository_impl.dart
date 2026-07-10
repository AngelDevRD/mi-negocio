import '../../../../core/database/app_database.dart' as db;
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/compra.dart';
import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/purchases_repository.dart';
import '../datasources/purchases_local_datasource.dart';

/// Implementación de proveedores y compras (RF-COM).
class PurchasesRepositoryImpl implements PurchasesRepository {
  PurchasesRepositoryImpl(this._local);

  final PurchasesLocalDatasource _local;

  Proveedor _proveedorAEntidad(db.Proveedore row) =>
      Proveedor(id: row.id, nombre: row.nombre, telefono: row.telefono);

  CompraItem _itemAEntidad((db.CompraItem, String) row) {
    final (item, productoNombre) = row;
    return CompraItem(
      productoId: item.productoId,
      productoNombre: productoNombre,
      cantidad: item.cantidad,
      costoUnitario: Money(item.costoUnitario),
    );
  }

  Compra _compraAEntidad(
    (db.Compra, String?, String) row, {
    List<CompraItem> items = const [],
  }) {
    final (compra, proveedorNombre, usuarioNombre) = row;
    return Compra(
      id: compra.id,
      proveedorId: compra.proveedorId,
      proveedorNombre: proveedorNombre,
      numeroFactura: compra.numeroFactura,
      fotoFacturaPath: compra.fotoFacturaPath,
      total: Money(compra.total),
      pagadaDeCaja: compra.pagadaDeCaja,
      estado: compra.estado,
      usuarioNombre: usuarioNombre,
      fecha: compra.fecha,
      items: items,
    );
  }

  @override
  Stream<List<Proveedor>> watchProveedores() {
    return _local.watchProveedores().map(
      (rows) => rows.map(_proveedorAEntidad).toList(),
    );
  }

  @override
  Future<Result<Proveedor>> crearProveedor({
    required String nombre,
    String? telefono,
  }) async {
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.isEmpty) {
      return const Result.fail(
        ValidationFailure('El nombre del proveedor es obligatorio.'),
      );
    }
    if (await _local.existeProveedor(nombreLimpio)) {
      return const Result.fail(
        ValidationFailure('Ya existe un proveedor con ese nombre.'),
      );
    }
    final telefonoLimpio = telefono?.trim();
    final fila = await _local.crearProveedor(
      nombre: nombreLimpio,
      telefono: telefonoLimpio == null || telefonoLimpio.isEmpty
          ? null
          : telefonoLimpio,
    );
    return Result.ok(_proveedorAEntidad(fila));
  }

  @override
  Stream<List<Compra>> watchCompras({
    String? proveedorId,
    DateTime? desde,
    DateTime? hasta,
  }) {
    return _local
        .watchCompras(proveedorId: proveedorId, desde: desde, hasta: hasta)
        .map((rows) => rows.map((row) => _compraAEntidad(row)).toList());
  }

  @override
  Future<Compra?> obtenerCompra(String id) async {
    final fila = await _local.obtenerCompra(id);
    if (fila == null) return null;
    final items = await _local.obtenerItemsCompra(id);
    return _compraAEntidad(fila, items: items.map(_itemAEntidad).toList());
  }

  @override
  Future<Result<String>> registrarCompra({
    String? proveedorId,
    String? numeroFactura,
    String? fotoFacturaPath,
    required List<ItemCompraInput> items,
    required bool pagadaDeCaja,
    required String usuarioId,
  }) async {
    if (items.isEmpty) {
      return const Result.fail(
        ValidationFailure('La compra debe tener al menos un producto.'),
      );
    }
    for (final item in items) {
      if (item.cantidad <= 0) {
        return Result.fail(
          ValidationFailure(
            'La cantidad de "${item.productoNombre}" debe ser mayor que cero.',
          ),
        );
      }
      if (item.costoUnitario.cents < 0) {
        return Result.fail(
          ValidationFailure(
            'El costo de "${item.productoNombre}" no puede ser negativo.',
          ),
        );
      }
      if (!await _local.existeProducto(item.productoId)) {
        return Result.fail(
          ValidationFailure(
            'El producto "${item.productoNombre}" no existe o fue eliminado.',
          ),
        );
      }
    }

    String? cajaSesionId;
    if (pagadaDeCaja) {
      cajaSesionId = await _local.obtenerCajaAbiertaId();
      if (cajaSesionId == null) {
        return const Result.fail(
          ValidationFailure(
            'No hay una sesión de caja abierta para registrar el pago.',
          ),
        );
      }
    }

    final compraId = await _local.registrarCompra(
      proveedorId: proveedorId,
      numeroFactura: numeroFactura,
      fotoFacturaPath: fotoFacturaPath,
      items: items
          .map(
            (item) => CompraItemEntrada(
              productoId: item.productoId,
              cantidad: item.cantidad,
              costoUnitarioCents: item.costoUnitario.cents,
            ),
          )
          .toList(),
      cajaSesionId: cajaSesionId,
      usuarioId: usuarioId,
    );
    return Result.ok(compraId);
  }
}
