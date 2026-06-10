import 'package:drift/drift.dart';

import '../enums.dart';
import 'base.dart';
import 'negocio_tables.dart';

class Categorias extends SoftDeleteTable {
  TextColumn get nombre => text().withLength(min: 1, max: 80)();
}

/// Productos del negocio. Precios en centavos (RNF-07). El stock se replica
/// aquí por rendimiento, pero su fuente de verdad son los movimientos (RN-03).
@TableIndex(name: 'idx_productos_nombre', columns: {#nombre})
@TableIndex(name: 'idx_productos_categoria', columns: {#categoriaId})
class Productos extends SoftDeleteTable {
  TextColumn get nombre => text().withLength(min: 1, max: 120)();
  TextColumn get categoriaId => text().references(Categorias, #id).nullable()();

  /// Unidad de venta: unidad, libra, caja, paquete…
  TextColumn get unidad => text().withDefault(const Constant('unidad'))();
  IntColumn get precioCompra => integer().withDefault(const Constant(0))();
  IntColumn get precioVenta => integer().withDefault(const Constant(0))();

  /// Cantidades como REAL: productos pesables (libras) admiten fracciones.
  RealColumn get stockActual => real().withDefault(const Constant(0))();
  RealColumn get stockMinimo => real().withDefault(const Constant(0))();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}

/// RN-04: todo cambio de precio queda registrado.
@TableIndex(name: 'idx_historial_precios_producto', columns: {#productoId})
class HistorialPrecios extends BaseTable {
  TextColumn get productoId => text().references(Productos, #id)();
  TextColumn get tipo => textEnum<TipoPrecio>()();
  IntColumn get precioAnterior => integer()();
  IntColumn get precioNuevo => integer()();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  DateTimeColumn get fecha =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}

class Proveedores extends SoftDeleteTable {
  TextColumn get nombre => text().withLength(min: 1, max: 120)();
  TextColumn get telefono => text().nullable()();
}

/// Kárdex (RN-03): única vía de cambio de stock. `cantidad` es CON SIGNO
/// (entradas positivas, salidas negativas): stock = SUM(cantidad).
@TableIndex(name: 'idx_movimientos_producto', columns: {#productoId})
@TableIndex(name: 'idx_movimientos_fecha', columns: {#fecha})
class MovimientosInventario extends BaseTable {
  TextColumn get productoId => text().references(Productos, #id)();
  TextColumn get tipo => textEnum<TipoMovimientoInventario>()();
  RealColumn get cantidad => real()();
  RealColumn get stockResultante => real()();

  /// Obligatorio en ajustes manuales (RN-19).
  TextColumn get motivo => text().nullable()();

  /// Venta, compra o anulación que originó el movimiento.
  TextColumn get referenciaId => text().nullable()();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  DateTimeColumn get fecha =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}
