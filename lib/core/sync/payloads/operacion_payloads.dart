import '../../database/app_database.dart';

/// Mapeos compartidos para encolar filas de la operación diaria (ventas,
/// compras, caja, gastos, empleados) -- usados desde varios datasources que
/// tocan estas mismas tablas (ej. sales y cash_register ambos escriben
/// `caja_sesiones`/`caja_movimientos`).
Map<String, dynamic> proveedorPayload(Proveedore p) => {
  'nombre': p.nombre,
  'telefono': p.telefono,
  'created_at': p.createdAt.toIso8601String(),
  'updated_at': p.updatedAt.toIso8601String(),
  'deleted_at': p.deletedAt?.toIso8601String(),
};

Map<String, dynamic> cajaSesionPayload(CajaSesione c) => {
  'fecha_apertura': c.fechaApertura.toIso8601String(),
  'monto_apertura': c.montoApertura,
  'fecha_cierre': c.fechaCierre?.toIso8601String(),
  'monto_esperado': c.montoEsperado,
  'monto_contado': c.montoContado,
  'diferencia': c.diferencia,
  'monto_dejado_siguiente': c.montoDejadoSiguiente,
  'usuario_apertura': c.usuarioApertura,
  'usuario_cierre': c.usuarioCierre,
  'estado': c.estado.name,
  'created_at': c.createdAt.toIso8601String(),
  'updated_at': c.updatedAt.toIso8601String(),
};

Map<String, dynamic> cajaMovimientoPayload(CajaMovimiento c) => {
  'caja_sesion_id': c.cajaSesionId,
  'tipo': c.tipo.name,
  'monto': c.monto,
  'motivo': c.motivo,
  'referencia_id': c.referenciaId,
  'usuario_id': c.usuarioId,
  'fecha': c.fecha.toIso8601String(),
  'created_at': c.createdAt.toIso8601String(),
  'updated_at': c.updatedAt.toIso8601String(),
};

Map<String, dynamic> compraPayload(Compra c) => {
  'proveedor_id': c.proveedorId,
  'numero_factura': c.numeroFactura,
  'foto_factura_path': c.fotoFacturaPath,
  'total': c.total,
  'pagada_de_caja': c.pagadaDeCaja,
  'estado': c.estado.name,
  'usuario_id': c.usuarioId,
  'fecha': c.fecha.toIso8601String(),
  'created_at': c.createdAt.toIso8601String(),
  'updated_at': c.updatedAt.toIso8601String(),
};

Map<String, dynamic> compraItemPayload(CompraItem c) => {
  'compra_id': c.compraId,
  'producto_id': c.productoId,
  'cantidad': c.cantidad,
  'costo_unitario': c.costoUnitario,
  'created_at': c.createdAt.toIso8601String(),
  'updated_at': c.updatedAt.toIso8601String(),
};

Map<String, dynamic> ventaPayload(Venta v) => {
  'tipo': v.tipo.name,
  'total': v.total,
  'ganancia': v.ganancia,
  'caja_sesion_id': v.cajaSesionId,
  'usuario_id': v.usuarioId,
  'estado': v.estado.name,
  'nota': v.nota,
  'fecha': v.fecha.toIso8601String(),
  'created_at': v.createdAt.toIso8601String(),
  'updated_at': v.updatedAt.toIso8601String(),
};

Map<String, dynamic> ventaItemPayload(VentaItem v) => {
  'venta_id': v.ventaId,
  'producto_id': v.productoId,
  'cantidad': v.cantidad,
  'precio_unitario': v.precioUnitario,
  'costo_unitario': v.costoUnitario,
  'created_at': v.createdAt.toIso8601String(),
  'updated_at': v.updatedAt.toIso8601String(),
};

Map<String, dynamic> gastoPayload(Gasto g) => {
  'categoria': g.categoria,
  'concepto': g.concepto,
  'fecha': g.fecha.toIso8601String(),
  'monto': g.monto,
  'caja_sesion_id': g.cajaSesionId,
  'usuario_id': g.usuarioId,
  'created_at': g.createdAt.toIso8601String(),
  'updated_at': g.updatedAt.toIso8601String(),
  'deleted_at': g.deletedAt?.toIso8601String(),
};

Map<String, dynamic> empleadoPayload(Empleado e) => {
  'tipo': e.tipo.name,
  'foto_path': e.fotoPath,
  'nombre': e.nombre,
  'cedula': e.cedula,
  'direccion': e.direccion,
  'telefono': e.telefono,
  'fecha_ingreso': e.fechaIngreso.toIso8601String(),
  'activo': e.activo,
  'salario': e.salario,
  'frecuencia_pago': e.frecuenciaPago,
  'created_at': e.createdAt.toIso8601String(),
  'updated_at': e.updatedAt.toIso8601String(),
  'deleted_at': e.deletedAt?.toIso8601String(),
};

Map<String, dynamic> pagoEmpleadoPayload(PagosEmpleado p) => {
  'empleado_id': p.empleadoId,
  'fecha': p.fecha.toIso8601String(),
  'monto': p.monto,
  'periodo': p.periodo,
  'caja_sesion_id': p.cajaSesionId,
  'usuario_id': p.usuarioId,
  'created_at': p.createdAt.toIso8601String(),
  'updated_at': p.updatedAt.toIso8601String(),
};
