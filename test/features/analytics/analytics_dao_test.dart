import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/features/analytics/data/datasources/analytics_dao.dart';
import 'package:app_gestion/features/analytics/domain/entities/analytics_data.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AnalyticsDao dao;

  late DateTime inicioMesActual;
  late DateTime inicioMesAnterior;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = AnalyticsDao(db);

    final ahora = DateTime.now().toUtc();
    inicioMesActual = DateTime.utc(ahora.year, ahora.month);
    inicioMesAnterior = DateTime.utc(ahora.year, ahora.month - 1);
    final fechaMesActual = inicioMesActual.add(const Duration(days: 1));
    final fechaMesAnterior = inicioMesAnterior.add(const Duration(days: 1));

    final negocioId = generateUuidV4();
    await db
        .into(db.negocios)
        .insert(
          NegociosCompanion.insert(
            id: Value(negocioId),
            nombre: 'Negocio Test',
          ),
        );

    final usuarioId = generateUuidV4();
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: Value(usuarioId),
            negocioId: negocioId,
            nombre: 'Admin',
            username: 'admin',
            passwordHash: 'hash',
            salt: 'salt',
            rol: RolUsuario.administrador,
          ),
        );

    final sesionId = generateUuidV4();
    await db
        .into(db.cajaSesiones)
        .insert(
          CajaSesionesCompanion.insert(
            id: Value(sesionId),
            fechaApertura: inicioMesActual,
            montoApertura: 0,
            usuarioApertura: usuarioId,
            estado: EstadoCajaSesion.abierta,
          ),
        );

    // Producto A: precioCompra 10.00, stock 10 -> 100.00 de inventario.
    final productoAId = generateUuidV4();
    await db
        .into(db.productos)
        .insert(
          ProductosCompanion.insert(
            id: Value(productoAId),
            nombre: 'Producto A',
            precioCompra: const Value(1000),
            precioVenta: const Value(1500),
            stockActual: const Value(10),
          ),
        );

    // Producto B: precioCompra 5.00, stock 5 -> 25.00 de inventario.
    final productoBId = generateUuidV4();
    await db
        .into(db.productos)
        .insert(
          ProductosCompanion.insert(
            id: Value(productoBId),
            nombre: 'Producto B',
            precioCompra: const Value(500),
            precioVenta: const Value(800),
            stockActual: const Value(5),
          ),
        );
    // Total inventario esperado: 10*1000 + 5*500 = 12500.

    // Venta 1 (mes actual): A x5 (ganancia 500 c/u) + B x2 (ganancia 300 c/u).
    // total = 5*1500 + 2*800 = 9100, ganancia = 5*500 + 2*300 = 3100.
    final venta1Id = generateUuidV4();
    await db
        .into(db.ventas)
        .insert(
          VentasCompanion.insert(
            id: Value(venta1Id),
            tipo: TipoVenta.detallada,
            total: 9100,
            ganancia: 3100,
            cajaSesionId: sesionId,
            usuarioId: usuarioId,
            estado: EstadoVenta.completada,
            fecha: fechaMesActual,
          ),
        );
    await db
        .into(db.ventaItems)
        .insert(
          VentaItemsCompanion.insert(
            ventaId: venta1Id,
            productoId: productoAId,
            cantidad: 5,
            precioUnitario: 1500,
            costoUnitario: 1000,
          ),
        );
    await db
        .into(db.ventaItems)
        .insert(
          VentaItemsCompanion.insert(
            ventaId: venta1Id,
            productoId: productoBId,
            cantidad: 2,
            precioUnitario: 800,
            costoUnitario: 500,
          ),
        );

    // Venta 2 (mes anterior): A x3 (ganancia 500 c/u).
    // total = 3*1500 = 4500, ganancia = 3*500 = 1500.
    final venta2Id = generateUuidV4();
    await db
        .into(db.ventas)
        .insert(
          VentasCompanion.insert(
            id: Value(venta2Id),
            tipo: TipoVenta.detallada,
            total: 4500,
            ganancia: 1500,
            cajaSesionId: sesionId,
            usuarioId: usuarioId,
            estado: EstadoVenta.completada,
            fecha: fechaMesAnterior,
          ),
        );
    await db
        .into(db.ventaItems)
        .insert(
          VentaItemsCompanion.insert(
            ventaId: venta2Id,
            productoId: productoAId,
            cantidad: 3,
            precioUnitario: 1500,
            costoUnitario: 1000,
          ),
        );

    // Compras: 30.00 mes actual, 20.00 mes anterior.
    await db
        .into(db.compras)
        .insert(
          ComprasCompanion.insert(
            total: 3000,
            estado: EstadoCompra.completada,
            usuarioId: usuarioId,
            fecha: fechaMesActual,
          ),
        );
    await db
        .into(db.compras)
        .insert(
          ComprasCompanion.insert(
            total: 2000,
            estado: EstadoCompra.completada,
            usuarioId: usuarioId,
            fecha: fechaMesAnterior,
          ),
        );

    // Gastos: mes actual Servicios 10.00 + Transporte 5.00; mes anterior
    // Servicios 8.00.
    await db
        .into(db.gastos)
        .insert(
          GastosCompanion.insert(
            categoria: 'Servicios',
            concepto: 'Luz',
            fecha: fechaMesActual,
            monto: 1000,
            usuarioId: usuarioId,
          ),
        );
    await db
        .into(db.gastos)
        .insert(
          GastosCompanion.insert(
            categoria: 'Transporte',
            concepto: 'Combustible',
            fecha: fechaMesActual,
            monto: 500,
            usuarioId: usuarioId,
          ),
        );
    await db
        .into(db.gastos)
        .insert(
          GastosCompanion.insert(
            categoria: 'Servicios',
            concepto: 'Agua',
            fecha: fechaMesAnterior,
            monto: 800,
            usuarioId: usuarioId,
          ),
        );

    // Empleados: E1 más antiguo, total pagado 20.00; E2 más reciente, total
    // pagado 30.00 (15.00 + 15.00).
    final empleado1Id = generateUuidV4();
    await db
        .into(db.empleados)
        .insert(
          EmpleadosCompanion.insert(
            id: Value(empleado1Id),
            tipo: TipoEmpleado.ventas,
            nombre: 'Empleado Antiguo',
            fechaIngreso: inicioMesAnterior.subtract(const Duration(days: 400)),
          ),
        );
    final empleado2Id = generateUuidV4();
    await db
        .into(db.empleados)
        .insert(
          EmpleadosCompanion.insert(
            id: Value(empleado2Id),
            tipo: TipoEmpleado.ventas,
            nombre: 'Empleado Nuevo',
            fechaIngreso: inicioMesAnterior.subtract(const Duration(days: 100)),
          ),
        );

    await db
        .into(db.pagosEmpleados)
        .insert(
          PagosEmpleadosCompanion.insert(
            empleadoId: empleado1Id,
            fecha: fechaMesActual,
            monto: 2000,
            usuarioId: usuarioId,
          ),
        );
    await db
        .into(db.pagosEmpleados)
        .insert(
          PagosEmpleadosCompanion.insert(
            empleadoId: empleado2Id,
            fecha: fechaMesActual,
            monto: 1500,
            usuarioId: usuarioId,
          ),
        );
    await db
        .into(db.pagosEmpleados)
        .insert(
          PagosEmpleadosCompanion.insert(
            empleadoId: empleado2Id,
            fecha: fechaMesAnterior,
            monto: 1500,
            usuarioId: usuarioId,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('watchResumen', () {
    test(
      'rango mes: solo cuenta el mes actual, inventario siempre completo',
      () async {
        final resumen = await dao.watchResumen(RangoAnalisis.mes).first;

        expect(resumen.ventas.cents, 9100);
        expect(resumen.compras.cents, 3000);
        expect(resumen.gastos.cents, 1500);
        expect(resumen.sueldos.cents, 3500);
        // ganancia neta = 3100 (bruta) - 1500 (gastos) - 3500 (sueldos)
        expect(resumen.ganancia.cents, -1900);
        expect(resumen.dineroMovido.cents, 9100 + 3000 + 1500 + 3500);
        expect(resumen.valorInventario.cents, 12500);
      },
    );

    test('rango todo: acumula ambos meses', () async {
      final resumen = await dao.watchResumen(RangoAnalisis.todo).first;

      expect(resumen.ventas.cents, 9100 + 4500);
      expect(resumen.compras.cents, 3000 + 2000);
      expect(resumen.gastos.cents, 1500 + 800);
      expect(resumen.sueldos.cents, 3500 + 1500);
      // ganancia bruta 3100+1500=4600; neta = 4600 - 2300 - 5000
      expect(resumen.ganancia.cents, 4600 - 2300 - 5000);
      expect(resumen.valorInventario.cents, 12500);
    });
  });

  test(
    'watchSerieMensual (todo) devuelve un punto por mes con datos',
    () async {
      final serie = await dao.watchSerieMensual(RangoAnalisis.todo).first;

      expect(serie, hasLength(2));

      final mesAnterior = serie.firstWhere(
        (p) =>
            p.mes.year == inicioMesAnterior.year &&
            p.mes.month == inicioMesAnterior.month,
      );
      expect(mesAnterior.ventas.cents, 4500);
      expect(mesAnterior.compras.cents, 2000);
      expect(mesAnterior.gastos.cents, 800);
      expect(mesAnterior.sueldos.cents, 1500);
      expect(mesAnterior.ganancia.cents, 1500 - 800 - 1500);

      final mesActual = serie.firstWhere(
        (p) =>
            p.mes.year == inicioMesActual.year &&
            p.mes.month == inicioMesActual.month,
      );
      expect(mesActual.ventas.cents, 9100);
      expect(mesActual.compras.cents, 3000);
      expect(mesActual.gastos.cents, 1500);
      expect(mesActual.sueldos.cents, 3500);
      expect(mesActual.ganancia.cents, 3100 - 1500 - 3500);
    },
  );

  group('watchGastosPorCategoria', () {
    test('rango mes: Servicios y Transporte del mes actual', () async {
      final categorias = await dao
          .watchGastosPorCategoria(RangoAnalisis.mes)
          .first;

      expect(categorias, hasLength(2));
      expect(categorias.first.categoria, 'Servicios');
      expect(categorias.first.total.cents, 1000);
      expect(categorias.last.categoria, 'Transporte');
      expect(categorias.last.total.cents, 500);
    });

    test('rango todo: Servicios acumula ambos meses', () async {
      final categorias = await dao
          .watchGastosPorCategoria(RangoAnalisis.todo)
          .first;

      final servicios = categorias.firstWhere(
        (c) => c.categoria == 'Servicios',
      );
      expect(servicios.total.cents, 1000 + 800);
    });
  });

  test(
    'watchComparativaMensual calcula % de variación vs el mes anterior',
    () async {
      final comparativa = await dao.watchComparativaMensual().first;

      expect(comparativa.ventasActual.cents, 9100);
      expect(comparativa.ventasAnterior.cents, 4500);
      expect(
        comparativa.variacionVentas,
        closeTo((9100 - 4500) / 4500 * 100, 0.001),
      );

      expect(comparativa.gastosActual.cents, 1500);
      expect(comparativa.gastosAnterior.cents, 800);
      expect(
        comparativa.variacionGastos,
        closeTo((1500 - 800) / 800 * 100, 0.001),
      );

      expect(comparativa.gananciaActual.cents, 3100);
      expect(comparativa.gananciaAnterior.cents, 1500);
      expect(
        comparativa.variacionGanancia,
        closeTo((3100 - 1500) / 1500 * 100, 0.001),
      );
    },
  );

  group('watchRankingProductos', () {
    test('rango todo: Producto A es el más vendido y más rentable', () async {
      final ranking = await dao.watchRankingProductos(RangoAnalisis.todo).first;

      final a = ranking.firstWhere((p) => p.nombre == 'Producto A');
      final b = ranking.firstWhere((p) => p.nombre == 'Producto B');

      expect(a.unidades, 8); // 5 + 3
      expect(a.ganancia.cents, 4000); // 2500 + 1500
      expect(b.unidades, 2);
      expect(b.ganancia.cents, 600);
    });

    test('rango mes: solo cuenta la venta del mes actual', () async {
      final ranking = await dao.watchRankingProductos(RangoAnalisis.mes).first;

      final a = ranking.firstWhere((p) => p.nombre == 'Producto A');
      final b = ranking.firstWhere((p) => p.nombre == 'Producto B');

      expect(a.unidades, 5);
      expect(a.ganancia.cents, 2500);
      expect(b.unidades, 2);
      expect(b.ganancia.cents, 600);
    });
  });

  test('watchRankingEmpleados ordena por antigüedad y suma pagos', () async {
    final ranking = await dao.watchRankingEmpleados().first;

    expect(ranking, hasLength(2));
    expect(ranking.first.nombre, 'Empleado Antiguo');
    expect(ranking.first.totalPagado.cents, 2000);

    final masPagado = [...ranking]
      ..sort((a, b) => b.totalPagado.compareTo(a.totalPagado));
    expect(masPagado.first.nombre, 'Empleado Nuevo');
    expect(masPagado.first.totalPagado.cents, 3000);
  });
}
