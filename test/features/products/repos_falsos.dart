import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/inventory/domain/entities/movimiento_inventario.dart';
import 'package:app_gestion/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:app_gestion/features/products/domain/entities/producto.dart';
import 'package:app_gestion/features/products/domain/repositories/products_repository.dart';

Producto producto(
  String nombre, {
  String? id,
  String? categoria,
  String unidad = 'unidad',
  int venta = 15000,
  int compra = 10000,
  double stock = 20,
  double minimo = 2,
  bool activo = true,
}) => Producto(
  id: id ?? nombre,
  nombre: nombre,
  categoriaId: categoria,
  categoriaNombre: categoria,
  unidad: unidad,
  precioCompra: Money(compra),
  precioVenta: Money(venta),
  stockActual: stock,
  stockMinimo: minimo,
  activo: activo,
);

/// Productos en memoria (sin drift: sus streams dejan timers pendientes).
class RepoProductosFalso implements ProductsRepository {
  RepoProductosFalso(this.productos, {this.historial = const []});

  final List<Producto> productos;
  final List<HistorialPrecio> historial;
  final activaciones = <({String id, bool activo})>[];

  @override
  Stream<List<Categoria>> watchCategorias() => Stream.value(const []);

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
            (categoriaId == null || p.categoriaId == categoriaId) &&
            p.nombre.toLowerCase().contains(texto))
          p,
    ]);
  }

  @override
  Future<Producto?> obtenerProducto(String id) async {
    for (final p in productos) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Stream<List<HistorialPrecio>> watchHistorialPrecios(String productoId) =>
      Stream.value(historial);

  @override
  Future<Result<void>> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  }) async {
    activaciones.add((id: id, activo: activo));
    return const Result.ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Kárdex en memoria.
class RepoInventarioFalso implements InventoryRepository {
  RepoInventarioFalso([this.movimientos = const []]);

  final List<MovimientoInventario> movimientos;

  @override
  Stream<List<MovimientoInventario>> watchKardex(String productoId) =>
      Stream.value(movimientos);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MovimientoInventario movimiento(
  String id,
  TipoMovimientoInventario tipo,
  double cantidad,
  double stockResultante, {
  String? motivo,
}) => MovimientoInventario(
  id: id,
  tipo: tipo,
  cantidad: cantidad,
  stockResultante: stockResultante,
  motivo: motivo,
  usuarioNombre: 'Ana Admin',
  fecha: DateTime(2026, 1, 15, 10),
);
