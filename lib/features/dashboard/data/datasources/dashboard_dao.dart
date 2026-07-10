import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/dashboard_data.dart';

/// Agregados reactivos para el dashboard (RF-DASH).
///
/// Cada stream se reemite cuando cambian las tablas de las que depende
/// (table-watching de Drift), por lo que el dashboard se actualiza solo
/// cuando otra pantalla registra una venta, compra, gasto o movimiento.
class DashboardDao {
  DashboardDao(this._db);

  final AppDatabase _db;

  static DateTime _inicioDeHoy() {
    final ahora = DateTime.now().toUtc();
    return DateTime.utc(ahora.year, ahora.month, ahora.day);
  }

  static DateTime _inicioDeMes() {
    final ahora = DateTime.now().toUtc();
    return DateTime.utc(ahora.year, ahora.month);
  }

  /// Sesión de caja abierta (si hay), con monto = apertura + movimientos.
  Stream<CajaActual?> watchCajaActual() {
    const sql = '''
      SELECT cs.id AS sesion_id, cs.fecha_apertura, cs.monto_apertura,
        cs.monto_apertura + COALESCE((
          SELECT SUM(monto) FROM caja_movimientos WHERE caja_sesion_id = cs.id
        ), 0) AS monto_actual
      FROM caja_sesiones cs
      WHERE cs.estado = 'abierta'
      LIMIT 1
    ''';
    return _db
        .customSelect(sql, readsFrom: {_db.cajaSesiones, _db.cajaMovimientos})
        .watch()
        .map((rows) {
          if (rows.isEmpty) return null;
          final row = rows.first;
          return CajaActual(
            sesionId: row.read<String>('sesion_id'),
            fechaApertura: row.read<DateTime>('fecha_apertura'),
            montoApertura: Money(row.read<int>('monto_apertura')),
            montoActual: Money(row.read<int>('monto_actual')),
          );
        });
  }

  /// Total vendido hoy (ventas completadas).
  Stream<Money> watchVentasDelDia() => _watchSumaVentas(desde: _inicioDeHoy());

  /// Total vendido en el mes (ventas completadas).
  Stream<Money> watchVentasDelMes() => _watchSumaVentas(desde: _inicioDeMes());

  Stream<Money> _watchSumaVentas({required DateTime desde}) {
    final query = _db.selectOnly(_db.ventas)
      ..addColumns([_db.ventas.total.sum()])
      ..where(
        _db.ventas.estado.equalsValue(EstadoVenta.completada) &
            _db.ventas.fecha.isBiggerOrEqualValue(desde),
      );
    return query.watchSingle().map(
      (row) => Money(row.read(_db.ventas.total.sum()) ?? 0),
    );
  }

  /// Total comprado en el mes (compras completadas).
  Stream<Money> watchComprasDelMes() {
    final query = _db.selectOnly(_db.compras)
      ..addColumns([_db.compras.total.sum()])
      ..where(
        _db.compras.estado.equalsValue(EstadoCompra.completada) &
            _db.compras.fecha.isBiggerOrEqualValue(_inicioDeMes()),
      );
    return query.watchSingle().map(
      (row) => Money(row.read(_db.compras.total.sum()) ?? 0),
    );
  }

  /// Total de gastos del mes.
  Stream<Money> watchGastosDelMes() {
    final query = _db.selectOnly(_db.gastos)
      ..addColumns([_db.gastos.monto.sum()])
      ..where(
        _db.gastos.deletedAt.isNull() &
            _db.gastos.fecha.isBiggerOrEqualValue(_inicioDeMes()),
      );
    return query.watchSingle().map(
      (row) => Money(row.read(_db.gastos.monto.sum()) ?? 0),
    );
  }

  /// Ganancia del mes (RN-05). Solo se muestra al Administrador (RN-15).
  Stream<Money> watchGananciaDelMes() {
    final query = _db.selectOnly(_db.ventas)
      ..addColumns([_db.ventas.ganancia.sum()])
      ..where(
        _db.ventas.estado.equalsValue(EstadoVenta.completada) &
            _db.ventas.fecha.isBiggerOrEqualValue(_inicioDeMes()),
      );
    return query.watchSingle().map(
      (row) => Money(row.read(_db.ventas.ganancia.sum()) ?? 0),
    );
  }

  /// Productos activos cuyo stock llegó al mínimo o por debajo (RF-INV-02).
  Stream<List<ProductoBajoStock>> watchProductosBajoStock({int limit = 10}) {
    final query = _db.select(_db.productos)
      ..where(
        (t) =>
            t.activo.equals(true) &
            t.deletedAt.isNull() &
            t.stockActual.isSmallerOrEqual(t.stockMinimo),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.stockActual)])
      ..limit(limit);
    return query.watch().map(
      (rows) => rows
          .map(
            (p) => ProductoBajoStock(
              id: p.id,
              nombre: p.nombre,
              stockActual: p.stockActual,
              stockMinimo: p.stockMinimo,
              unidad: p.unidad,
            ),
          )
          .toList(),
    );
  }

  /// Mezcla de los últimos movimientos (ventas, compras y gastos) por fecha.
  Stream<List<MovimientoReciente>> watchMovimientosRecientes({int limit = 10}) {
    const sql = '''
      SELECT id, 'venta' AS tipo, fecha, total AS monto
        FROM ventas WHERE estado = 'completada'
      UNION ALL
      SELECT id, 'compra' AS tipo, fecha, total AS monto
        FROM compras WHERE estado = 'completada'
      UNION ALL
      SELECT id, 'gasto' AS tipo, fecha, monto
        FROM gastos WHERE deleted_at IS NULL
      ORDER BY fecha DESC
      LIMIT ?1
    ''';
    return _db
        .customSelect(
          sql,
          variables: [Variable.withInt(limit)],
          readsFrom: {_db.ventas, _db.compras, _db.gastos},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => MovimientoReciente(
                  id: row.read<String>('id'),
                  tipo: TipoMovimientoReciente.values.byName(
                    row.read<String>('tipo'),
                  ),
                  fecha: row.read<DateTime>('fecha'),
                  monto: Money(row.read<int>('monto')),
                ),
              )
              .toList(),
        );
  }
}
