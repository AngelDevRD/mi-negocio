import '../../../../core/utils/money.dart';

/// Reportes exportables (RF-EXP-02).
enum TipoReporte {
  ventas,
  compras,
  inventarioValorizado,
  empleadosPagos,
  cierreCaja,
  resumenMensual,
}

/// Formatos de exportación (RF-EXP-01).
enum FormatoExport { excel, pdf, csv }

/// Ítem de una venta exportada.
class VentaItemExportRow {
  const VentaItemExportRow({
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.costoUnitario,
  });

  final String producto;
  final double cantidad;
  final Money precioUnitario;
  final Money costoUnitario;
}

/// Fila del reporte de ventas (RF-EXP-02).
class VentaExportRow {
  const VentaExportRow({
    required this.id,
    required this.fecha,
    required this.tipo,
    required this.usuario,
    required this.estado,
    required this.total,
    required this.ganancia,
    required this.items,
  });

  final String id;
  final DateTime fecha;
  final String tipo;
  final String usuario;
  final String estado;
  final Money total;
  final Money ganancia;
  final List<VentaItemExportRow> items;
}

/// Ítem de una compra exportada.
class CompraItemExportRow {
  const CompraItemExportRow({
    required this.producto,
    required this.cantidad,
    required this.costoUnitario,
  });

  final String producto;
  final double cantidad;
  final Money costoUnitario;
}

/// Fila del reporte de compras (RF-EXP-02).
class CompraExportRow {
  const CompraExportRow({
    required this.id,
    required this.fecha,
    required this.proveedor,
    required this.numeroFactura,
    required this.usuario,
    required this.estado,
    required this.total,
    required this.items,
  });

  final String id;
  final DateTime fecha;
  final String? proveedor;
  final String? numeroFactura;
  final String usuario;
  final String estado;
  final Money total;
  final List<CompraItemExportRow> items;
}

/// Fila del reporte de inventario valorizado (RF-EXP-02/RF-ANL-02).
class InventarioExportRow {
  const InventarioExportRow({
    required this.nombre,
    required this.categoria,
    required this.unidad,
    required this.stockActual,
    required this.precioCompra,
    required this.precioVenta,
    required this.valorCosto,
    required this.valorVenta,
  });

  final String nombre;
  final String categoria;
  final String unidad;
  final double stockActual;
  final Money precioCompra;
  final Money precioVenta;
  final Money valorCosto;
  final Money valorVenta;
}

/// Pago a un empleado dentro del rango exportado.
class PagoExportRow {
  const PagoExportRow({required this.fecha, required this.monto, this.periodo});

  final DateTime fecha;
  final Money monto;
  final String? periodo;
}

/// Fila del reporte de empleados y pagos (RF-EXP-02).
class EmpleadoExportRow {
  const EmpleadoExportRow({
    required this.nombre,
    required this.tipo,
    required this.cedula,
    required this.fechaIngreso,
    required this.activo,
    required this.totalPagado,
    required this.pagos,
  });

  final String nombre;
  final String tipo;
  final String? cedula;
  final DateTime fechaIngreso;
  final bool activo;
  final Money totalPagado;
  final List<PagoExportRow> pagos;
}

/// Movimiento de caja dentro del reporte de cierre.
class MovimientoCajaExportRow {
  const MovimientoCajaExportRow({
    required this.tipo,
    required this.monto,
    required this.fecha,
    this.motivo,
  });

  final String tipo;
  final Money monto;
  final DateTime fecha;
  final String? motivo;
}

/// Sesión de caja disponible para el reporte de cierre (selector).
class SesionCajaResumen {
  const SesionCajaResumen({
    required this.id,
    required this.fechaApertura,
    required this.fechaCierre,
  });

  final String id;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
}

/// Fila del reporte de cierre de caja (RF-EXP-02).
class CierreCajaExportRow {
  const CierreCajaExportRow({
    required this.fechaApertura,
    required this.fechaCierre,
    required this.usuarioApertura,
    required this.usuarioCierre,
    required this.montoApertura,
    required this.montoEsperado,
    required this.montoContado,
    required this.diferencia,
    required this.montoDejadoSiguiente,
    required this.movimientos,
  });

  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final String usuarioApertura;
  final String? usuarioCierre;
  final Money montoApertura;
  final Money? montoEsperado;
  final Money? montoContado;
  final Money? diferencia;
  final Money? montoDejadoSiguiente;
  final List<MovimientoCajaExportRow> movimientos;
}

/// Resumen mensual (mini estado de resultados) con datos del negocio para el
/// encabezado del PDF (RF-EXP-02).
class ResumenMensualExportRow {
  const ResumenMensualExportRow({
    required this.mes,
    required this.negocioNombre,
    required this.negocioIdentificacion,
    required this.negocioDireccion,
    required this.negocioTelefono,
    required this.logoPath,
    required this.ventas,
    required this.compras,
    required this.gastos,
    required this.sueldos,
    required this.ganancia,
  });

  final DateTime mes;
  final String negocioNombre;
  final String? negocioIdentificacion;
  final String? negocioDireccion;
  final String? negocioTelefono;
  final String? logoPath;
  final Money ventas;
  final Money compras;
  final Money gastos;
  final Money sueldos;
  final Money ganancia;
}
