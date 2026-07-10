import '../../../../core/database/app_database.dart' as db;
import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../../products/domain/entities/producto.dart';
import '../../domain/entities/movimiento_inventario.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_datasource.dart';

/// Implementación del módulo de inventario (RF-INV): existencias, kárdex y
/// el único punto de cambio de stock (RN-03).
class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._local);

  final InventoryLocalDatasource _local;

  Producto _productoAEntidad((db.Producto, String?) row) {
    final (producto, categoriaNombre) = row;
    return Producto(
      id: producto.id,
      nombre: producto.nombre,
      categoriaId: producto.categoriaId,
      categoriaNombre: categoriaNombre,
      unidad: producto.unidad,
      precioCompra: Money(producto.precioCompra),
      precioVenta: Money(producto.precioVenta),
      stockActual: producto.stockActual,
      stockMinimo: producto.stockMinimo,
      activo: producto.activo,
    );
  }

  MovimientoInventario _movimientoAEntidad(
    (db.MovimientosInventarioData, String) row,
  ) {
    final (movimiento, usuarioNombre) = row;
    return MovimientoInventario(
      id: movimiento.id,
      tipo: movimiento.tipo,
      cantidad: movimiento.cantidad,
      stockResultante: movimiento.stockResultante,
      motivo: movimiento.motivo,
      referenciaId: movimiento.referenciaId,
      usuarioNombre: usuarioNombre,
      fecha: movimiento.fecha,
    );
  }

  @override
  Stream<List<Producto>> watchExistencias({String busqueda = ''}) {
    return _local
        .watchExistencias(busqueda: busqueda)
        .map((rows) => rows.map(_productoAEntidad).toList());
  }

  @override
  Stream<List<MovimientoInventario>> watchKardex(String productoId) {
    return _local
        .watchKardex(productoId)
        .map((rows) => rows.map(_movimientoAEntidad).toList());
  }

  @override
  Future<Result<void>> applyMovement({
    required String productoId,
    required TipoMovimientoInventario tipo,
    required double cantidad,
    String? motivo,
    String? referenciaId,
    required String usuarioId,
  }) async {
    if (cantidad == 0) {
      return const Result.fail(
        ValidationFailure('La cantidad del movimiento no puede ser cero.'),
      );
    }
    final producto = await _local.obtenerProducto(productoId);
    if (producto == null) {
      return const Result.fail(
        ValidationFailure('El producto no existe o fue eliminado.'),
      );
    }
    await _local.applyMovement(
      producto: producto,
      tipo: tipo,
      cantidad: cantidad,
      motivo: motivo,
      referenciaId: referenciaId,
      usuarioId: usuarioId,
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> ajusteManual({
    required String productoId,
    required double cantidad,
    required String motivo,
    required String usuarioId,
  }) {
    final motivoLimpio = motivo.trim();
    if (motivoLimpio.isEmpty) {
      return Future.value(
        const Result.fail(
          ValidationFailure('El motivo del ajuste es obligatorio.'),
        ),
      );
    }
    if (cantidad == 0) {
      return Future.value(
        const Result.fail(
          ValidationFailure('La cantidad del ajuste no puede ser cero.'),
        ),
      );
    }
    return applyMovement(
      productoId: productoId,
      tipo: cantidad > 0
          ? TipoMovimientoInventario.ajusteEntrada
          : TipoMovimientoInventario.ajusteSalida,
      cantidad: cantidad,
      motivo: motivoLimpio,
      usuarioId: usuarioId,
    );
  }
}
