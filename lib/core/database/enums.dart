/// Enums del modelo de datos. Se almacenan como TEXT (nombre del enum) en
/// SQLite vía `textEnum<T>()`. NO renombrar valores ya publicados: romperían
/// los datos existentes.
library;

enum RolUsuario { administrador, cajero }

enum TipoLicencia { demo, local, nube }

enum EstadoLicencia { pendiente, activa, suspendida, vencida, transferida }

enum TipoPrecio { compra, venta }

/// RN-03: el stock solo cambia por movimientos.
enum TipoMovimientoInventario {
  stockInicial,
  compra,
  venta,
  ajusteEntrada,
  ajusteSalida,
  anulacionVenta,
  anulacionCompra,
}

enum TipoVenta { rapida, detallada }

enum EstadoVenta { completada, anulada }

enum EstadoCompra { completada, anulada }

enum EstadoCajaSesion { abierta, cerrada }

enum TipoCajaMovimiento {
  venta,
  gasto,
  compra,
  pagoEmpleado,
  entradaManual,
  salidaManual,
  retiroCierre,
}

enum TipoEmpleado { ventas, delivery }

enum TipoRespaldo { manual, automatico }

enum OperacionSync { insert, update, delete }

enum EstadoSync { pendiente, enviado, error }
