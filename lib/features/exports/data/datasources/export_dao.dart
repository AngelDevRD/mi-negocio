import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/export_models.dart';

/// Acceso a datos de fila completa para los reportes exportables (RF-EXP-02).
///
/// A diferencia de [AnalyticsDao] (agregados para el dashboard), aquí se
/// necesita el detalle de cada registro para volcarlo a Excel/PDF/CSV.
class ExportDao {
  ExportDao(this._db);

  final AppDatabase _db;

  /// Ventas completadas o anuladas en el rango, con sus ítems (RF-EXP-02).
  Future<List<VentaExportRow>> obtenerVentas({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final query =
        _db.select(_db.ventas).join([
            innerJoin(
              _db.usuarios,
              _db.usuarios.id.equalsExp(_db.ventas.usuarioId),
            ),
          ])
          ..where(
            _db.ventas.fecha.isBiggerOrEqualValue(desde) &
                _db.ventas.fecha.isSmallerOrEqualValue(hasta),
          )
          ..orderBy([OrderingTerm.asc(_db.ventas.fecha)]);
    final rows = await query.get();

    final resultado = <VentaExportRow>[];
    for (final row in rows) {
      final venta = row.readTable(_db.ventas);
      final usuario = row.readTable(_db.usuarios).nombre;

      final itemsQuery =
          _db.select(_db.ventaItems).join([
              innerJoin(
                _db.productos,
                _db.productos.id.equalsExp(_db.ventaItems.productoId),
              ),
            ])
            ..where(_db.ventaItems.ventaId.equals(venta.id))
            ..orderBy([OrderingTerm.asc(_db.ventaItems.createdAt)]);
      final itemRows = await itemsQuery.get();

      resultado.add(
        VentaExportRow(
          id: venta.id,
          fecha: venta.fecha,
          tipo: venta.tipo.name,
          usuario: usuario,
          estado: venta.estado.name,
          total: Money(venta.total),
          ganancia: Money(venta.ganancia),
          items: itemRows
              .map(
                (r) => VentaItemExportRow(
                  producto: r.readTable(_db.productos).nombre,
                  cantidad: r.readTable(_db.ventaItems).cantidad,
                  precioUnitario: Money(
                    r.readTable(_db.ventaItems).precioUnitario,
                  ),
                  costoUnitario: Money(
                    r.readTable(_db.ventaItems).costoUnitario,
                  ),
                ),
              )
              .toList(),
        ),
      );
    }
    return resultado;
  }

  /// Compras en el rango, con sus ítems (RF-EXP-02).
  Future<List<CompraExportRow>> obtenerCompras({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final query =
        _db.select(_db.compras).join([
            innerJoin(
              _db.usuarios,
              _db.usuarios.id.equalsExp(_db.compras.usuarioId),
            ),
            leftOuterJoin(
              _db.proveedores,
              _db.proveedores.id.equalsExp(_db.compras.proveedorId),
            ),
          ])
          ..where(
            _db.compras.fecha.isBiggerOrEqualValue(desde) &
                _db.compras.fecha.isSmallerOrEqualValue(hasta),
          )
          ..orderBy([OrderingTerm.asc(_db.compras.fecha)]);
    final rows = await query.get();

    final resultado = <CompraExportRow>[];
    for (final row in rows) {
      final compra = row.readTable(_db.compras);
      final usuario = row.readTable(_db.usuarios).nombre;
      final proveedor = row.readTableOrNull(_db.proveedores)?.nombre;

      final itemsQuery =
          _db.select(_db.compraItems).join([
              innerJoin(
                _db.productos,
                _db.productos.id.equalsExp(_db.compraItems.productoId),
              ),
            ])
            ..where(_db.compraItems.compraId.equals(compra.id))
            ..orderBy([OrderingTerm.asc(_db.compraItems.createdAt)]);
      final itemRows = await itemsQuery.get();

      resultado.add(
        CompraExportRow(
          id: compra.id,
          fecha: compra.fecha,
          proveedor: proveedor,
          numeroFactura: compra.numeroFactura,
          usuario: usuario,
          estado: compra.estado.name,
          total: Money(compra.total),
          items: itemRows
              .map(
                (r) => CompraItemExportRow(
                  producto: r.readTable(_db.productos).nombre,
                  cantidad: r.readTable(_db.compraItems).cantidad,
                  costoUnitario: Money(
                    r.readTable(_db.compraItems).costoUnitario,
                  ),
                ),
              )
              .toList(),
        ),
      );
    }
    return resultado;
  }

  /// Inventario actual valorizado a costo y a venta (RF-EXP-02/RF-ANL-02).
  Future<List<InventarioExportRow>> obtenerInventarioValorizado() async {
    final query =
        _db.select(_db.productos).join([
            leftOuterJoin(
              _db.categorias,
              _db.categorias.id.equalsExp(_db.productos.categoriaId),
            ),
          ])
          ..where(_db.productos.deletedAt.isNull())
          ..orderBy([OrderingTerm.asc(_db.productos.nombre)]);
    final rows = await query.get();

    return rows.map((row) {
      final producto = row.readTable(_db.productos);
      final categoria = row.readTableOrNull(_db.categorias)?.nombre;
      return InventarioExportRow(
        nombre: producto.nombre,
        categoria: categoria ?? 'Sin categoría',
        unidad: producto.unidad,
        stockActual: producto.stockActual,
        precioCompra: Money(producto.precioCompra),
        precioVenta: Money(producto.precioVenta),
        valorCosto: Money(
          (producto.stockActual * producto.precioCompra).round(),
        ),
        valorVenta: Money(
          (producto.stockActual * producto.precioVenta).round(),
        ),
      );
    }).toList();
  }

  /// Empleados activos e inactivos con sus pagos dentro del rango (RF-EXP-02).
  Future<List<EmpleadoExportRow>> obtenerEmpleadosPagos({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final empleados =
        await (_db.select(_db.empleados)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
            .get();

    final resultado = <EmpleadoExportRow>[];
    for (final empleado in empleados) {
      final pagos =
          await (_db.select(_db.pagosEmpleados)
                ..where(
                  (t) =>
                      t.empleadoId.equals(empleado.id) &
                      t.fecha.isBiggerOrEqualValue(desde) &
                      t.fecha.isSmallerOrEqualValue(hasta),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
              .get();

      final total = pagos.fold<int>(0, (suma, pago) => suma + pago.monto);

      resultado.add(
        EmpleadoExportRow(
          nombre: empleado.nombre,
          tipo: empleado.tipo.name,
          cedula: empleado.cedula,
          fechaIngreso: empleado.fechaIngreso,
          activo: empleado.activo,
          totalPagado: Money(total),
          pagos: pagos
              .map(
                (p) => PagoExportRow(
                  fecha: p.fecha,
                  monto: Money(p.monto),
                  periodo: p.periodo,
                ),
              )
              .toList(),
        ),
      );
    }
    return resultado;
  }

  /// Sesiones de caja cerradas, para el selector del reporte de cierre.
  Future<List<SesionCajaResumen>> listarSesionesCerradas() async {
    final query = _db.select(_db.cajaSesiones)
      ..where((t) => t.estado.equalsValue(EstadoCajaSesion.cerrada))
      ..orderBy([(t) => OrderingTerm.desc(t.fechaCierre)]);
    final sesiones = await query.get();
    return sesiones
        .map(
          (s) => SesionCajaResumen(
            id: s.id,
            fechaApertura: s.fechaApertura,
            fechaCierre: s.fechaCierre,
          ),
        )
        .toList();
  }

  /// Detalle de una sesión de caja cerrada y sus movimientos (RF-EXP-02).
  Future<CierreCajaExportRow> obtenerCierreCaja(String sesionId) async {
    final aperturaUsuarios = _db.alias(_db.usuarios, 'apertura_usuarios');
    final cierreUsuarios = _db.alias(_db.usuarios, 'cierre_usuarios');
    final query = _db.select(_db.cajaSesiones).join([
      innerJoin(
        aperturaUsuarios,
        aperturaUsuarios.id.equalsExp(_db.cajaSesiones.usuarioApertura),
      ),
      leftOuterJoin(
        cierreUsuarios,
        cierreUsuarios.id.equalsExp(_db.cajaSesiones.usuarioCierre),
      ),
    ])..where(_db.cajaSesiones.id.equals(sesionId));
    final row = await query.getSingle();
    final sesion = row.readTable(_db.cajaSesiones);

    final movimientos =
        await (_db.select(_db.cajaMovimientos)
              ..where((t) => t.cajaSesionId.equals(sesionId))
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
            .get();

    return CierreCajaExportRow(
      fechaApertura: sesion.fechaApertura,
      fechaCierre: sesion.fechaCierre,
      usuarioApertura: row.readTable(aperturaUsuarios).nombre,
      usuarioCierre: row.readTableOrNull(cierreUsuarios)?.nombre,
      montoApertura: Money(sesion.montoApertura),
      montoEsperado: sesion.montoEsperado == null
          ? null
          : Money(sesion.montoEsperado!),
      montoContado: sesion.montoContado == null
          ? null
          : Money(sesion.montoContado!),
      diferencia: sesion.diferencia == null ? null : Money(sesion.diferencia!),
      montoDejadoSiguiente: sesion.montoDejadoSiguiente == null
          ? null
          : Money(sesion.montoDejadoSiguiente!),
      movimientos: movimientos
          .map(
            (m) => MovimientoCajaExportRow(
              tipo: m.tipo.name,
              monto: Money(m.monto),
              fecha: m.fecha,
              motivo: m.motivo,
            ),
          )
          .toList(),
    );
  }

  /// Mini estado de resultados del mes con los datos del negocio para el
  /// encabezado del PDF (RF-EXP-02).
  Future<ResumenMensualExportRow> obtenerResumenMensual(DateTime mes) async {
    final inicio = DateTime.utc(mes.year, mes.month);
    final fin = DateTime.utc(mes.year, mes.month + 1);

    const sql = '''
      SELECT
        (SELECT COALESCE(SUM(total), 0) FROM ventas
          WHERE estado = 'completada' AND fecha >= ?1 AND fecha < ?2) AS ventas,
        (SELECT COALESCE(SUM(ganancia), 0) FROM ventas
          WHERE estado = 'completada' AND fecha >= ?1 AND fecha < ?2)
          AS ganancia_bruta,
        (SELECT COALESCE(SUM(total), 0) FROM compras
          WHERE estado = 'completada' AND fecha >= ?1 AND fecha < ?2) AS compras,
        (SELECT COALESCE(SUM(monto), 0) FROM gastos
          WHERE deleted_at IS NULL AND fecha >= ?1 AND fecha < ?2) AS gastos,
        (SELECT COALESCE(SUM(monto), 0) FROM pagos_empleados
          WHERE fecha >= ?1 AND fecha < ?2) AS sueldos
    ''';
    final row = await _db
        .customSelect(
          sql,
          variables: [
            Variable.withDateTime(inicio),
            Variable.withDateTime(fin),
          ],
          readsFrom: {_db.ventas, _db.compras, _db.gastos, _db.pagosEmpleados},
        )
        .getSingle();

    final ventas = Money(row.read<int>('ventas'));
    final compras = Money(row.read<int>('compras'));
    final gastos = Money(row.read<int>('gastos'));
    final sueldos = Money(row.read<int>('sueldos'));
    final gananciaBruta = Money(row.read<int>('ganancia_bruta'));

    final negocio = await (_db.select(_db.negocios)..limit(1)).getSingle();

    return ResumenMensualExportRow(
      mes: inicio,
      negocioNombre: negocio.nombre,
      negocioIdentificacion: negocio.identificacion,
      negocioDireccion: negocio.direccion,
      negocioTelefono: negocio.telefono,
      logoPath: negocio.logoPath,
      ventas: ventas,
      compras: compras,
      gastos: gastos,
      sueldos: sueldos,
      ganancia: gananciaBruta - gastos - sueldos,
    );
  }
}
