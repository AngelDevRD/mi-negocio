import 'package:drift/drift.dart';

import '../enums.dart';
import 'base.dart';
import 'negocio_tables.dart';
import 'operacion_tables.dart';

/// Clientes con fiado (crédito). El saldo NO se guarda: se calcula como la
/// suma de sus [MovimientosCliente] (libro mayor).
@TableIndex(name: 'idx_clientes_nombre', columns: {#nombre})
class Clientes extends SoftDeleteTable {
  TextColumn get nombre => text().withLength(min: 1, max: 120)();
  TextColumn get telefono => text().nullable()();
  TextColumn get nota => text().nullable()();

  /// Centavos; `null` = sin límite de crédito.
  IntColumn get limiteCredito => integer().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}

/// Libro de cuenta del cliente (como el kárdex de inventario): saldo = suma de
/// `monto`. Con signo: cargo positivo; abono y anulación negativos.
@DataClassName('MovimientoClienteData')
@TableIndex(name: 'idx_movimientos_cliente_cliente', columns: {#clienteId})
@TableIndex(name: 'idx_movimientos_cliente_fecha', columns: {#fecha})
class MovimientosCliente extends BaseTable {
  TextColumn get clienteId => text().references(Clientes, #id)();
  TextColumn get tipo => textEnum<TipoMovimientoCliente>()();
  IntColumn get monto => integer()();

  /// En cargo y anulación: la venta a crédito.
  TextColumn get ventaId => text().references(Ventas, #id).nullable()();

  /// Solo en abonos (nunca `credito`).
  TextColumn get metodoPago => textEnum<MetodoPago>().nullable()();

  /// Solo en abonos en efectivo.
  TextColumn get cajaSesionId =>
      text().references(CajaSesiones, #id).nullable()();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  TextColumn get nota => text().nullable()();
  DateTimeColumn get fecha =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
}
