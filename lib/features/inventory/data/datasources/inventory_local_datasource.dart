import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

/// Acceso a `productos` (existencias) y `movimientos_inventario` (kárdex)
/// para el módulo de inventario (RF-INV).
class InventoryLocalDatasource {
  InventoryLocalDatasource(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------
  // Existencias
  // ---------------------------------------------------------------------

  /// Productos activos con su categoría, para la pantalla de existencias
  /// (RF-INV-01).
  Stream<List<(Producto, String?)>> watchExistencias({String busqueda = ''}) {
    final query =
        _db.select(_db.productos).join([
          leftOuterJoin(
            _db.categorias,
            _db.categorias.id.equalsExp(_db.productos.categoriaId),
          ),
        ])..where(
          _db.productos.deletedAt.isNull() & _db.productos.activo.equals(true),
        );

    if (busqueda.trim().isNotEmpty) {
      query.where(_db.productos.nombre.like('%${busqueda.trim()}%'));
    }
    query.orderBy([OrderingTerm.asc(_db.productos.nombre)]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.productos),
              row.readTableOrNull(_db.categorias)?.nombre,
            ),
          )
          .toList(),
    );
  }

  Future<Producto?> obtenerProducto(String id) {
    return (_db.select(
      _db.productos,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  // ---------------------------------------------------------------------
  // Kárdex
  // ---------------------------------------------------------------------

  /// Movimientos del producto con el nombre del usuario (RF-INV-02), más
  /// reciente primero.
  Stream<List<(MovimientosInventarioData, String)>> watchKardex(
    String productoId,
  ) {
    final query =
        _db.select(_db.movimientosInventario).join([
            innerJoin(
              _db.usuarios,
              _db.usuarios.id.equalsExp(_db.movimientosInventario.usuarioId),
            ),
          ])
          ..where(_db.movimientosInventario.productoId.equals(productoId))
          ..orderBy([OrderingTerm.desc(_db.movimientosInventario.fecha)]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.movimientosInventario),
              row.readTable(_db.usuarios).nombre,
            ),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------
  // Movimientos (RN-03/RF-INV-04)
  // ---------------------------------------------------------------------

  /// Único punto de cambio de stock: actualiza `productos.stock_actual`,
  /// inserta el movimiento con el stock resultante y registra auditoría.
  Future<void> applyMovement({
    required Producto producto,
    required TipoMovimientoInventario tipo,
    required double cantidad,
    String? motivo,
    String? referenciaId,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final stockResultante = producto.stockActual + cantidad;

      await (_db.update(
        _db.productos,
      )..where((t) => t.id.equals(producto.id))).write(
        ProductosCompanion(
          stockActual: Value(stockResultante),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      await _db
          .into(_db.movimientosInventario)
          .insert(
            MovimientosInventarioCompanion.insert(
              productoId: producto.id,
              tipo: tipo,
              cantidad: cantidad,
              stockResultante: stockResultante,
              usuarioId: usuarioId,
              motivo: Value(motivo),
              referenciaId: Value(referenciaId),
            ),
          );

      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: usuarioId,
              accion: tipo.name,
              modulo: 'inventario',
              entidadId: Value(producto.id),
              datosDespues: Value(
                jsonEncode({
                  'cantidad': cantidad,
                  'stockResultante': stockResultante,
                  'motivo': ?motivo,
                  'referenciaId': ?referenciaId,
                }),
              ),
            ),
          );
    });
  }
}
