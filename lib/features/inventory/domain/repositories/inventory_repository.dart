import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../products/domain/entities/producto.dart';
import '../entities/movimiento_inventario.dart';

/// Operaciones de inventario (RF-INV): existencias, kárdex y el único punto
/// de cambio de stock (RN-03).
abstract interface class InventoryRepository {
  /// Existencias de productos activos: stock actual, stock mínimo y precio
  /// de compra (para valor a costo), filtrables por nombre.
  Stream<List<Producto>> watchExistencias({String busqueda = ''});

  /// Kárdex del producto (RF-INV-02), más reciente primero.
  Stream<List<MovimientoInventario>> watchKardex(String productoId);

  /// Único punto de cambio de stock (RN-03/RF-INV-04). `cantidad` con signo:
  /// positiva = entrada, negativa = salida. Actualiza `productos.stock_actual`,
  /// inserta el movimiento con el stock resultante y registra auditoría, todo
  /// en una transacción.
  Future<Result<void>> applyMovement({
    required String productoId,
    required TipoMovimientoInventario tipo,
    required double cantidad,
    String? motivo,
    String? referenciaId,
    required String usuarioId,
  });

  /// Ajuste manual de inventario (RF-INV-03/RN-19): `cantidad` con signo
  /// (positiva = entrada, negativa = salida) y `motivo` obligatorio.
  Future<Result<void>> ajusteManual({
    required String productoId,
    required double cantidad,
    required String motivo,
    required String usuarioId,
  });
}
