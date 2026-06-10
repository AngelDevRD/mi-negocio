import 'package:drift/drift.dart';

import '../enums.dart';
import 'base.dart';
import 'negocio_tables.dart';
import 'producto_tables.dart';

/// Sesión de caja diaria (RF-CAJ). Montos en centavos.
class CajaSesiones extends BaseTable {
  DateTimeColumn get fechaApertura => dateTime()();
  IntColumn get montoApertura => integer()();
  DateTimeColumn get fechaCierre => dateTime().nullable()();
  IntColumn get montoEsperado => integer().nullable()();
  IntColumn get montoContado => integer().nullable()();

  /// RN-08: contado − esperado (negativo = faltante).
  IntColumn get diferencia => integer().nullable()();

  /// RN-09: precarga la apertura siguiente.
  IntColumn get montoDejadoSiguiente => integer().nullable()();
  @ReferenceName('sesionesAbiertas')
  TextColumn get usuarioApertura => text().references(Usuarios, #id)();
  @ReferenceName('sesionesCerradas')
  TextColumn get usuarioCierre => text().references(Usuarios, #id).nullable()();
  TextColumn get estado => textEnum<EstadoCajaSesion>()();
}

@TableIndex(name: 'idx_caja_movimientos_sesion', columns: {#cajaSesionId})
class CajaMovimientos extends BaseTable {
  TextColumn get cajaSesionId => text().references(CajaSesiones, #id)();
  TextColumn get tipo => textEnum<TipoCajaMovimiento>()();

  /// Con signo: entradas positivas, salidas negativas.
  IntColumn get monto => integer()();
  TextColumn get motivo => text().nullable()();
  TextColumn get referenciaId => text().nullable()();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  DateTimeColumn get fecha =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}

/// Compras a proveedores (RF-COM). RN-10: se anulan, nunca se borran.
@TableIndex(name: 'idx_compras_fecha', columns: {#fecha})
class Compras extends BaseTable {
  TextColumn get proveedorId =>
      text().references(Proveedores, #id).nullable()();
  TextColumn get numeroFactura => text().nullable()();
  TextColumn get fotoFacturaPath => text().nullable()();
  IntColumn get total => integer()();
  BoolColumn get pagadaDeCaja => boolean().withDefault(const Constant(false))();
  TextColumn get estado => textEnum<EstadoCompra>()();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  DateTimeColumn get fecha => dateTime()();
}

class CompraItems extends BaseTable {
  TextColumn get compraId => text().references(Compras, #id)();
  TextColumn get productoId => text().references(Productos, #id)();
  RealColumn get cantidad => real()();
  IntColumn get costoUnitario => integer()();
}

/// Ventas (RF-VEN). RN-05: la ganancia usa el costo capturado al vender.
@TableIndex(name: 'idx_ventas_fecha', columns: {#fecha})
@TableIndex(name: 'idx_ventas_sesion', columns: {#cajaSesionId})
class Ventas extends BaseTable {
  TextColumn get tipo => textEnum<TipoVenta>()();
  IntColumn get total => integer()();
  IntColumn get ganancia => integer()();
  TextColumn get cajaSesionId => text().references(CajaSesiones, #id)();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  TextColumn get estado => textEnum<EstadoVenta>()();
  TextColumn get nota => text().nullable()();
  DateTimeColumn get fecha => dateTime()();
}

class VentaItems extends BaseTable {
  TextColumn get ventaId => text().references(Ventas, #id)();
  TextColumn get productoId => text().references(Productos, #id)();
  RealColumn get cantidad => real()();
  IntColumn get precioUnitario => integer()();

  /// Costo vigente al momento de la venta (RN-05).
  IntColumn get costoUnitario => integer()();
}

/// Gastos operativos (RF-GAS).
@TableIndex(name: 'idx_gastos_fecha', columns: {#fecha})
class Gastos extends SoftDeleteTable {
  TextColumn get categoria => text()();
  TextColumn get concepto => text()();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get monto => integer()();
  TextColumn get cajaSesionId =>
      text().references(CajaSesiones, #id).nullable()();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
}

/// Empleados de ventas y delivery (RF-EMP). Salario en centavos.
class Empleados extends SoftDeleteTable {
  TextColumn get tipo => textEnum<TipoEmpleado>()();
  TextColumn get fotoPath => text().nullable()();
  TextColumn get nombre => text().withLength(min: 1, max: 120)();
  TextColumn get cedula => text().nullable()();
  TextColumn get direccion => text().nullable()();
  TextColumn get telefono => text().nullable()();
  DateTimeColumn get fechaIngreso => dateTime()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  IntColumn get salario => integer().nullable()();

  /// semanal, quincenal, mensual…
  TextColumn get frecuenciaPago => text().nullable()();
}

@TableIndex(name: 'idx_pagos_empleado', columns: {#empleadoId})
class PagosEmpleados extends BaseTable {
  TextColumn get empleadoId => text().references(Empleados, #id)();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get monto => integer()();

  /// Período cubierto, ej. "1–15 junio 2026".
  TextColumn get periodo => text().nullable()();
  TextColumn get cajaSesionId =>
      text().references(CajaSesiones, #id).nullable()();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
}
