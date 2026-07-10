import '../../../../core/errors/result.dart';
import '../entities/compra.dart';
import '../entities/proveedor.dart';

/// Operaciones de compras (RF-COM): proveedores, listado/detalle de compras
/// y registro de una compra completa.
abstract interface class PurchasesRepository {
  /// Proveedores activos, ordenados por nombre.
  Stream<List<Proveedor>> watchProveedores();

  /// Alta rápida de proveedor desde el formulario de compra.
  Future<Result<Proveedor>> crearProveedor({
    required String nombre,
    String? telefono,
  });

  /// Compras registradas, más reciente primero, con filtros opcionales.
  Stream<List<Compra>> watchCompras({
    String? proveedorId,
    DateTime? desde,
    DateTime? hasta,
  });

  /// Compra con sus ítems, o `null` si no existe.
  Future<Compra?> obtenerCompra(String id);

  /// Registra una compra completa (RF-COM/RN-06): inserta `compras` y
  /// `compra_items`, entra el inventario de cada ítem vía
  /// `InventoryRepository.applyMovement`, actualiza `precio_compra` e
  /// inserta `historial_precios` si el costo difiere, registra auditoría y,
  /// si `pagadaDeCaja`, una salida en `caja_movimientos`. Devuelve el id de
  /// la compra creada.
  Future<Result<String>> registrarCompra({
    String? proveedorId,
    String? numeroFactura,
    String? fotoFacturaPath,
    required List<ItemCompraInput> items,
    required bool pagadaDeCaja,
    required String usuarioId,
  });
}
