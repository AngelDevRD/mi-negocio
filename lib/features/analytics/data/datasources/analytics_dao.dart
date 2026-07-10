import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/analytics_data.dart';

/// Agregados reactivos del centro de análisis financiero (RF-ANL, Fase 15).
///
/// RNF-03: todas las cifras se calculan con consultas SQL agregadas, nunca
/// iterando listas completas en Dart.
class AnalyticsDao {
  AnalyticsDao(this._db);

  final AppDatabase _db;

  /// Fecha mínima usada cuando el rango es [RangoAnalisis.todo]: anterior a
  /// cualquier dato real, así el filtro `fecha >= ?` se cumple siempre.
  static final DateTime _desdeSiempre = DateTime.utc(1970);

  static DateTime _inicioDeMes([DateTime? referencia]) {
    final ahora = (referencia ?? DateTime.now()).toUtc();
    return DateTime.utc(ahora.year, ahora.month);
  }

  /// Límite inferior del rango seleccionado (RF-ANL-01).
  static DateTime _desdePara(RangoAnalisis rango) {
    final inicioMes = _inicioDeMes();
    switch (rango) {
      case RangoAnalisis.mes:
        return inicioMes;
      case RangoAnalisis.trimestre:
        return DateTime.utc(inicioMes.year, inicioMes.month - 2);
      case RangoAnalisis.anio:
        return DateTime.utc(inicioMes.year, inicioMes.month - 11);
      case RangoAnalisis.todo:
        return _desdeSiempre;
    }
  }

  /// Resumen del rango: ventas, compras, gastos, sueldos, ganancia neta,
  /// dinero total movido y valor actual del inventario (RF-ANL-01/02).
  Stream<ResumenFinanciero> watchResumen(RangoAnalisis rango) {
    const sql = '''
      SELECT
        (SELECT COALESCE(SUM(total), 0) FROM ventas
          WHERE estado = 'completada' AND fecha >= ?1) AS ventas,
        (SELECT COALESCE(SUM(ganancia), 0) FROM ventas
          WHERE estado = 'completada' AND fecha >= ?1) AS ganancia_bruta,
        (SELECT COALESCE(SUM(total), 0) FROM compras
          WHERE estado = 'completada' AND fecha >= ?1) AS compras,
        (SELECT COALESCE(SUM(monto), 0) FROM gastos
          WHERE deleted_at IS NULL AND fecha >= ?1) AS gastos,
        (SELECT COALESCE(SUM(monto), 0) FROM pagos_empleados
          WHERE fecha >= ?1) AS sueldos,
        (SELECT COALESCE(SUM(stock_actual * precio_compra), 0) FROM productos
          WHERE deleted_at IS NULL) AS valor_inventario
    ''';
    return _db
        .customSelect(
          sql,
          variables: [Variable.withDateTime(_desdePara(rango))],
          readsFrom: {
            _db.ventas,
            _db.compras,
            _db.gastos,
            _db.pagosEmpleados,
            _db.productos,
          },
        )
        .watchSingle()
        .map((row) {
          final ventas = Money(row.read<int>('ventas'));
          final compras = Money(row.read<int>('compras'));
          final gastos = Money(row.read<int>('gastos'));
          final sueldos = Money(row.read<int>('sueldos'));
          final gananciaBruta = Money(row.read<int>('ganancia_bruta'));
          final valorInventario = Money(
            row.read<double>('valor_inventario').round(),
          );
          return ResumenFinanciero(
            ventas: ventas,
            compras: compras,
            gastos: gastos,
            sueldos: sueldos,
            ganancia: gananciaBruta - gastos - sueldos,
            dineroMovido: ventas + compras + gastos + sueldos,
            valorInventario: valorInventario,
          );
        });
  }

  /// Totales por mes dentro del rango, para las gráficas de línea y barras
  /// (RF-ANL-04): ventas vs gastos, y ganancia mensual.
  Stream<List<PuntoMensual>> watchSerieMensual(RangoAnalisis rango) {
    const sql = '''
      SELECT strftime('%Y-%m', fecha) AS mes, 'ventas' AS tipo,
        total AS monto, ganancia AS extra
        FROM ventas WHERE estado = 'completada' AND fecha >= ?1
      UNION ALL
      SELECT strftime('%Y-%m', fecha) AS mes, 'compras' AS tipo,
        total AS monto, 0 AS extra
        FROM compras WHERE estado = 'completada' AND fecha >= ?1
      UNION ALL
      SELECT strftime('%Y-%m', fecha) AS mes, 'gastos' AS tipo,
        monto AS monto, 0 AS extra
        FROM gastos WHERE deleted_at IS NULL AND fecha >= ?1
      UNION ALL
      SELECT strftime('%Y-%m', fecha) AS mes, 'sueldos' AS tipo,
        monto AS monto, 0 AS extra
        FROM pagos_empleados WHERE fecha >= ?1
      ORDER BY mes ASC
    ''';
    return _db
        .customSelect(
          sql,
          variables: [Variable.withDateTime(_desdePara(rango))],
          readsFrom: {_db.ventas, _db.compras, _db.gastos, _db.pagosEmpleados},
        )
        .watch()
        .map((rows) {
          final porMes = <String, _AcumuladorMensual>{};
          for (final row in rows) {
            final mes = row.read<String>('mes');
            final acumulador = porMes.putIfAbsent(
              mes,
              () => _AcumuladorMensual(),
            );
            final monto = row.read<int>('monto');
            switch (row.read<String>('tipo')) {
              case 'ventas':
                acumulador.ventas += monto;
                acumulador.gananciaBruta += row.read<int>('extra');
              case 'compras':
                acumulador.compras += monto;
              case 'gastos':
                acumulador.gastos += monto;
              case 'sueldos':
                acumulador.sueldos += monto;
            }
          }
          final meses = porMes.keys.toList()..sort();
          return [
            for (final mes in meses)
              () {
                final a = porMes[mes]!;
                return PuntoMensual(
                  mes: DateTime.parse('$mes-01'),
                  ventas: Money(a.ventas),
                  compras: Money(a.compras),
                  gastos: Money(a.gastos),
                  sueldos: Money(a.sueldos),
                  ganancia: Money(a.gananciaBruta - a.gastos - a.sueldos),
                );
              }(),
          ];
        });
  }

  /// Total de gastos por categoría dentro del rango, de mayor a menor
  /// (RF-ANL-04: pastel de gastos por categoría).
  Stream<List<GastoPorCategoria>> watchGastosPorCategoria(RangoAnalisis rango) {
    final total = _db.gastos.monto.sum();
    final query = _db.selectOnly(_db.gastos)
      ..addColumns([_db.gastos.categoria, total])
      ..where(
        _db.gastos.deletedAt.isNull() &
            _db.gastos.fecha.isBiggerOrEqualValue(_desdePara(rango)),
      )
      ..groupBy([_db.gastos.categoria])
      ..orderBy([OrderingTerm.desc(total)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => GastoPorCategoria(
              categoria: row.read(_db.gastos.categoria)!,
              total: Money(row.read(total) ?? 0),
            ),
          )
          .toList(),
    );
  }

  /// Comparativa del mes actual vs el mes anterior (RF-ANL-05).
  Stream<ComparativaMensual> watchComparativaMensual() {
    final inicioActual = _inicioDeMes();
    final inicioSiguiente = DateTime.utc(
      inicioActual.year,
      inicioActual.month + 1,
    );
    final inicioAnterior = DateTime.utc(
      inicioActual.year,
      inicioActual.month - 1,
    );
    const sql = '''
      SELECT
        (SELECT COALESCE(SUM(total), 0) FROM ventas
          WHERE estado = 'completada' AND fecha >= ?1 AND fecha < ?2)
          AS ventas_actual,
        (SELECT COALESCE(SUM(total), 0) FROM ventas
          WHERE estado = 'completada' AND fecha >= ?3 AND fecha < ?1)
          AS ventas_anterior,
        (SELECT COALESCE(SUM(monto), 0) FROM gastos
          WHERE deleted_at IS NULL AND fecha >= ?1 AND fecha < ?2)
          AS gastos_actual,
        (SELECT COALESCE(SUM(monto), 0) FROM gastos
          WHERE deleted_at IS NULL AND fecha >= ?3 AND fecha < ?1)
          AS gastos_anterior,
        (SELECT COALESCE(SUM(ganancia), 0) FROM ventas
          WHERE estado = 'completada' AND fecha >= ?1 AND fecha < ?2)
          AS ganancia_actual,
        (SELECT COALESCE(SUM(ganancia), 0) FROM ventas
          WHERE estado = 'completada' AND fecha >= ?3 AND fecha < ?1)
          AS ganancia_anterior
    ''';
    return _db
        .customSelect(
          sql,
          variables: [
            Variable.withDateTime(inicioActual),
            Variable.withDateTime(inicioSiguiente),
            Variable.withDateTime(inicioAnterior),
          ],
          readsFrom: {_db.ventas, _db.gastos},
        )
        .watchSingle()
        .map(
          (row) => ComparativaMensual(
            ventasActual: Money(row.read<int>('ventas_actual')),
            ventasAnterior: Money(row.read<int>('ventas_anterior')),
            gastosActual: Money(row.read<int>('gastos_actual')),
            gastosAnterior: Money(row.read<int>('gastos_anterior')),
            gananciaActual: Money(row.read<int>('ganancia_actual')),
            gananciaAnterior: Money(row.read<int>('ganancia_anterior')),
          ),
        );
  }

  /// Ranking de productos por unidades vendidas y ganancia acumulada en el
  /// rango (RF-ANL-03: más vendido, menos vendido, más rentable).
  Stream<List<ProductoVentasRanking>> watchRankingProductos(
    RangoAnalisis rango,
  ) {
    const sql = '''
      SELECT p.id AS id, p.nombre AS nombre,
        COALESCE(SUM(vi.cantidad), 0) AS unidades,
        COALESCE(SUM((vi.precio_unitario - vi.costo_unitario) * vi.cantidad), 0)
          AS ganancia
      FROM productos p
      LEFT JOIN (
        SELECT vi.producto_id, vi.cantidad, vi.precio_unitario, vi.costo_unitario
        FROM venta_items vi
        INNER JOIN ventas v ON v.id = vi.venta_id
        WHERE v.estado = 'completada' AND v.fecha >= ?1
      ) vi ON vi.producto_id = p.id
      WHERE p.deleted_at IS NULL
      GROUP BY p.id, p.nombre
    ''';
    return _db
        .customSelect(
          sql,
          variables: [Variable.withDateTime(_desdePara(rango))],
          readsFrom: {_db.productos, _db.ventaItems, _db.ventas},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => ProductoVentasRanking(
                  id: row.read<String>('id'),
                  nombre: row.read<String>('nombre'),
                  unidades: row.read<double>('unidades'),
                  ganancia: Money(row.read<double>('ganancia').round()),
                ),
              )
              .toList(),
        );
  }

  /// Ranking de empleados por total pagado y antigüedad (RF-ANL-03).
  Stream<List<EmpleadoPagosRanking>> watchRankingEmpleados() {
    const sql = '''
      SELECT e.id AS id, e.nombre AS nombre, e.fecha_ingreso AS fecha_ingreso,
        COALESCE(SUM(pe.monto), 0) AS total_pagado
      FROM empleados e
      LEFT JOIN pagos_empleados pe ON pe.empleado_id = e.id
      WHERE e.deleted_at IS NULL
      GROUP BY e.id, e.nombre, e.fecha_ingreso
      ORDER BY e.fecha_ingreso ASC
    ''';
    return _db
        .customSelect(sql, readsFrom: {_db.empleados, _db.pagosEmpleados})
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => EmpleadoPagosRanking(
                  id: row.read<String>('id'),
                  nombre: row.read<String>('nombre'),
                  fechaIngreso: row.read<DateTime>('fecha_ingreso'),
                  totalPagado: Money(row.read<int>('total_pagado')),
                ),
              )
              .toList(),
        );
  }
}

/// Acumulador interno para [AnalyticsDao.watchSerieMensual]: suma en centavos
/// los montos de cada tipo de movimiento dentro de un mes.
class _AcumuladorMensual {
  int ventas = 0;
  int compras = 0;
  int gastos = 0;
  int sueldos = 0;
  int gananciaBruta = 0;
}
