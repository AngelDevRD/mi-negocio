import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/features/exports/data/datasources/export_dao.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ExportDao dao;

  late String usuarioId;
  late String productoAId;
  late String productoBId;
  late String proveedorId;
  late String empleadoId;

  late DateTime inicioMes;
  late DateTime finMes;
  late DateTime fechaEnMes;
  late DateTime fechaFueraDeMes;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = ExportDao(db);

    final ahora = DateTime.now().toUtc();
    inicioMes = DateTime.utc(ahora.year, ahora.month);
    finMes = DateTime.utc(
      ahora.year,
      ahora.month + 1,
    ).subtract(const Duration(seconds: 1));
    fechaEnMes = inicioMes.add(const Duration(days: 1));
    fechaFueraDeMes = inicioMes.subtract(const Duration(days: 5));

    final negocioId = generateUuidV4();
    await db
        .into(db.negocios)
        .insert(
          NegociosCompanion.insert(
            id: Value(negocioId),
            nombre: 'Colmado Test',
            identificacion: const Value('123456789'),
            direccion: const Value('Calle Falsa 123'),
            telefono: const Value('809-555-0000'),
          ),
        );

    usuarioId = generateUuidV4();
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

    final categoriaId = generateUuidV4();
    await db
        .into(db.categorias)
        .insert(
          CategoriasCompanion.insert(id: Value(categoriaId), nombre: 'Carnes'),
        );

    // Producto A: precioCompra 10.00, precioVenta 15.00, stock 10.
    productoAId = generateUuidV4();
    await db
        .into(db.productos)
        .insert(
          ProductosCompanion.insert(
            id: Value(productoAId),
            nombre: 'Producto A',
            categoriaId: Value(categoriaId),
            precioCompra: const Value(1000),
            precioVenta: const Value(1500),
            stockActual: const Value(10),
          ),
        );

    // Producto B sin categoría: precioCompra 5.00, precioVenta 8.00, stock 5.
    productoBId = generateUuidV4();
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

    proveedorId = generateUuidV4();
    await db
        .into(db.proveedores)
        .insert(
          ProveedoresCompanion.insert(
            id: Value(proveedorId),
            nombre: 'Proveedor X',
          ),
        );

    empleadoId = generateUuidV4();
    await db
        .into(db.empleados)
        .insert(
          EmpleadosCompanion.insert(
            id: Value(empleadoId),
            tipo: TipoEmpleado.ventas,
            nombre: 'Empleado 1',
            fechaIngreso: inicioMes.subtract(const Duration(days: 100)),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('obtenerVentas devuelve la venta con sus ítems', () async {
    final sesionId = generateUuidV4();
    await db
        .into(db.cajaSesiones)
        .insert(
          CajaSesionesCompanion.insert(
            id: Value(sesionId),
            fechaApertura: fechaEnMes,
            montoApertura: 0,
            usuarioApertura: usuarioId,
            estado: EstadoCajaSesion.abierta,
          ),
        );

    final ventaId = generateUuidV4();
    await db
        .into(db.ventas)
        .insert(
          VentasCompanion.insert(
            id: Value(ventaId),
            tipo: TipoVenta.detallada,
            total: 9100,
            ganancia: 3100,
            cajaSesionId: sesionId,
            usuarioId: usuarioId,
            estado: EstadoVenta.completada,
            fecha: fechaEnMes,
          ),
        );
    await db
        .into(db.ventaItems)
        .insert(
          VentaItemsCompanion.insert(
            ventaId: ventaId,
            productoId: productoAId,
            cantidad: 5,
            precioUnitario: 1500,
            costoUnitario: 1000,
          ),
        );

    final ventas = await dao.obtenerVentas(desde: inicioMes, hasta: finMes);

    expect(ventas, hasLength(1));
    final venta = ventas.single;
    expect(venta.id, ventaId);
    expect(venta.tipo, 'detallada');
    expect(venta.usuario, 'Admin');
    expect(venta.estado, 'completada');
    expect(venta.total.cents, 9100);
    expect(venta.ganancia.cents, 3100);
    expect(venta.items, hasLength(1));
    expect(venta.items.single.producto, 'Producto A');
    expect(venta.items.single.cantidad, 5);
    expect(venta.items.single.precioUnitario.cents, 1500);
    expect(venta.items.single.costoUnitario.cents, 1000);
  });

  test('obtenerCompras devuelve la compra con proveedor e ítems', () async {
    final compraId = generateUuidV4();
    await db
        .into(db.compras)
        .insert(
          ComprasCompanion.insert(
            id: Value(compraId),
            proveedorId: Value(proveedorId),
            numeroFactura: const Value('F-001'),
            total: 5000,
            estado: EstadoCompra.completada,
            usuarioId: usuarioId,
            fecha: fechaEnMes,
          ),
        );
    await db
        .into(db.compraItems)
        .insert(
          CompraItemsCompanion.insert(
            compraId: compraId,
            productoId: productoBId,
            cantidad: 10,
            costoUnitario: 500,
          ),
        );

    final compras = await dao.obtenerCompras(desde: inicioMes, hasta: finMes);

    expect(compras, hasLength(1));
    final compra = compras.single;
    expect(compra.id, compraId);
    expect(compra.proveedor, 'Proveedor X');
    expect(compra.numeroFactura, 'F-001');
    expect(compra.usuario, 'Admin');
    expect(compra.estado, 'completada');
    expect(compra.total.cents, 5000);
    expect(compra.items, hasLength(1));
    expect(compra.items.single.producto, 'Producto B');
    expect(compra.items.single.cantidad, 10);
    expect(compra.items.single.costoUnitario.cents, 500);
  });

  test('obtenerCompras sin proveedor devuelve proveedor null', () async {
    final compraId = generateUuidV4();
    await db
        .into(db.compras)
        .insert(
          ComprasCompanion.insert(
            id: Value(compraId),
            total: 1000,
            estado: EstadoCompra.completada,
            usuarioId: usuarioId,
            fecha: fechaEnMes,
          ),
        );

    final compras = await dao.obtenerCompras(desde: inicioMes, hasta: finMes);

    expect(compras.single.proveedor, isNull);
    expect(compras.single.items, isEmpty);
  });

  test(
    'obtenerInventarioValorizado calcula el valor a costo y a venta',
    () async {
      final inventario = await dao.obtenerInventarioValorizado();

      expect(inventario, hasLength(2));

      final a = inventario.firstWhere((p) => p.nombre == 'Producto A');
      expect(a.categoria, 'Carnes');
      expect(a.stockActual, 10);
      expect(a.valorCosto.cents, 10000);
      expect(a.valorVenta.cents, 15000);

      final b = inventario.firstWhere((p) => p.nombre == 'Producto B');
      expect(b.categoria, 'Sin categoría');
      expect(b.valorCosto.cents, 2500);
      expect(b.valorVenta.cents, 4000);
    },
  );

  test('obtenerEmpleadosPagos suma solo los pagos dentro del rango', () async {
    await db
        .into(db.pagosEmpleados)
        .insert(
          PagosEmpleadosCompanion.insert(
            empleadoId: empleadoId,
            fecha: fechaEnMes,
            monto: 2000,
            usuarioId: usuarioId,
            periodo: const Value('1-15'),
          ),
        );
    await db
        .into(db.pagosEmpleados)
        .insert(
          PagosEmpleadosCompanion.insert(
            empleadoId: empleadoId,
            fecha: fechaFueraDeMes,
            monto: 1500,
            usuarioId: usuarioId,
          ),
        );

    final empleados = await dao.obtenerEmpleadosPagos(
      desde: inicioMes,
      hasta: finMes,
    );

    expect(empleados, hasLength(1));
    final empleado = empleados.single;
    expect(empleado.nombre, 'Empleado 1');
    expect(empleado.activo, isTrue);
    expect(empleado.totalPagado.cents, 2000);
    expect(empleado.pagos, hasLength(1));
    expect(empleado.pagos.single.monto.cents, 2000);
    expect(empleado.pagos.single.periodo, '1-15');
  });

  group('cierre de caja', () {
    test('listarSesionesCerradas solo devuelve sesiones cerradas', () async {
      final abiertaId = generateUuidV4();
      await db
          .into(db.cajaSesiones)
          .insert(
            CajaSesionesCompanion.insert(
              id: Value(abiertaId),
              fechaApertura: fechaEnMes,
              montoApertura: 0,
              usuarioApertura: usuarioId,
              estado: EstadoCajaSesion.abierta,
            ),
          );

      final cerradaId = generateUuidV4();
      await db
          .into(db.cajaSesiones)
          .insert(
            CajaSesionesCompanion.insert(
              id: Value(cerradaId),
              fechaApertura: fechaEnMes,
              fechaCierre: Value(fechaEnMes.add(const Duration(hours: 8))),
              montoApertura: 0,
              usuarioApertura: usuarioId,
              usuarioCierre: Value(usuarioId),
              estado: EstadoCajaSesion.cerrada,
            ),
          );

      final sesiones = await dao.listarSesionesCerradas();

      expect(sesiones, hasLength(1));
      expect(sesiones.single.id, cerradaId);
    });

    test('obtenerCierreCaja devuelve el resumen y los movimientos', () async {
      final sesionId = generateUuidV4();
      await db
          .into(db.cajaSesiones)
          .insert(
            CajaSesionesCompanion.insert(
              id: Value(sesionId),
              fechaApertura: fechaEnMes,
              fechaCierre: Value(fechaEnMes.add(const Duration(hours: 8))),
              montoApertura: 100000,
              montoEsperado: const Value(150000),
              montoContado: const Value(149000),
              diferencia: const Value(-1000),
              montoDejadoSiguiente: const Value(100000),
              usuarioApertura: usuarioId,
              usuarioCierre: Value(usuarioId),
              estado: EstadoCajaSesion.cerrada,
            ),
          );
      await db
          .into(db.cajaMovimientos)
          .insert(
            CajaMovimientosCompanion.insert(
              cajaSesionId: sesionId,
              tipo: TipoCajaMovimiento.entradaManual,
              monto: 5000,
              motivo: const Value('Vuelto inicial'),
              usuarioId: usuarioId,
              fecha: Value(fechaEnMes),
            ),
          );

      final cierre = await dao.obtenerCierreCaja(sesionId);

      expect(cierre.usuarioApertura, 'Admin');
      expect(cierre.usuarioCierre, 'Admin');
      expect(cierre.montoApertura.cents, 100000);
      expect(cierre.montoEsperado!.cents, 150000);
      expect(cierre.montoContado!.cents, 149000);
      expect(cierre.diferencia!.cents, -1000);
      expect(cierre.montoDejadoSiguiente!.cents, 100000);
      expect(cierre.movimientos, hasLength(1));
      expect(cierre.movimientos.single.tipo, 'entradaManual');
      expect(cierre.movimientos.single.monto.cents, 5000);
      expect(cierre.movimientos.single.motivo, 'Vuelto inicial');
    });
  });

  test(
    'obtenerResumenMensual calcula la ganancia neta del mes y los datos del negocio',
    () async {
      final sesionId = generateUuidV4();
      await db
          .into(db.cajaSesiones)
          .insert(
            CajaSesionesCompanion.insert(
              id: Value(sesionId),
              fechaApertura: fechaEnMes,
              montoApertura: 0,
              usuarioApertura: usuarioId,
              estado: EstadoCajaSesion.abierta,
            ),
          );

      // Ventas: total 9100, ganancia bruta 3100.
      await db
          .into(db.ventas)
          .insert(
            VentasCompanion.insert(
              tipo: TipoVenta.detallada,
              total: 9100,
              ganancia: 3100,
              cajaSesionId: sesionId,
              usuarioId: usuarioId,
              estado: EstadoVenta.completada,
              fecha: fechaEnMes,
            ),
          );

      // Compras: total 3000.
      await db
          .into(db.compras)
          .insert(
            ComprasCompanion.insert(
              total: 3000,
              estado: EstadoCompra.completada,
              usuarioId: usuarioId,
              fecha: fechaEnMes,
            ),
          );

      // Gastos: 1000.
      await db
          .into(db.gastos)
          .insert(
            GastosCompanion.insert(
              categoria: 'Servicios',
              concepto: 'Luz',
              fecha: fechaEnMes,
              monto: 1000,
              usuarioId: usuarioId,
            ),
          );

      // Sueldos: 2000.
      await db
          .into(db.pagosEmpleados)
          .insert(
            PagosEmpleadosCompanion.insert(
              empleadoId: empleadoId,
              fecha: fechaEnMes,
              monto: 2000,
              usuarioId: usuarioId,
            ),
          );

      final resumen = await dao.obtenerResumenMensual(inicioMes);

      expect(resumen.negocioNombre, 'Colmado Test');
      expect(resumen.negocioIdentificacion, '123456789');
      expect(resumen.ventas.cents, 9100);
      expect(resumen.compras.cents, 3000);
      expect(resumen.gastos.cents, 1000);
      expect(resumen.sueldos.cents, 2000);
      // ganancia neta = ganancia bruta (3100) - gastos (1000) - sueldos (2000)
      expect(resumen.ganancia.cents, 100);
    },
  );
}
