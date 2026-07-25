import '../../database/app_database.dart';

/// Mapeos compartidos para encolar filas del dominio de productos/inventario
/// -- usados desde products y inventory datasources (ambos tocan
/// `productos`/`movimientos_inventario`).
Map<String, dynamic> categoriaPayload(Categoria c) => {
  'nombre': c.nombre,
  'created_at': c.createdAt.toIso8601String(),
  'updated_at': c.updatedAt.toIso8601String(),
  'deleted_at': c.deletedAt?.toIso8601String(),
};

Map<String, dynamic> productoPayload(Producto p) => {
  'nombre': p.nombre,
  'categoria_id': p.categoriaId,
  'unidad': p.unidad,
  'precio_compra': p.precioCompra,
  'precio_venta': p.precioVenta,
  'stock_actual': p.stockActual,
  'stock_minimo': p.stockMinimo,
  'activo': p.activo,
  'created_at': p.createdAt.toIso8601String(),
  'updated_at': p.updatedAt.toIso8601String(),
  'deleted_at': p.deletedAt?.toIso8601String(),
};

Map<String, dynamic> historialPrecioPayload(HistorialPrecio h) => {
  'producto_id': h.productoId,
  'tipo': h.tipo.name,
  'precio_anterior': h.precioAnterior,
  'precio_nuevo': h.precioNuevo,
  'usuario_id': h.usuarioId,
  'fecha': h.fecha.toIso8601String(),
  'created_at': h.createdAt.toIso8601String(),
  'updated_at': h.updatedAt.toIso8601String(),
};

Map<String, dynamic> movimientoInventarioPayload(MovimientosInventarioData m) => {
  'producto_id': m.productoId,
  'tipo': m.tipo.name,
  'cantidad': m.cantidad,
  'stock_resultante': m.stockResultante,
  'motivo': m.motivo,
  'referencia_id': m.referenciaId,
  'usuario_id': m.usuarioId,
  'fecha': m.fecha.toIso8601String(),
  'created_at': m.createdAt.toIso8601String(),
  'updated_at': m.updatedAt.toIso8601String(),
};
