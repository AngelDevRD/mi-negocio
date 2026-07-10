import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/dashboard/data/datasources/dashboard_dao.dart';
import 'package:app_gestion/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DashboardDao dao;
  late String usuarioId;
  late String cajaSesionCerradaId;

  final ahora = DateTime.now().toUtc();
  final ayer = ahora.subtract(const Duration(days: 1));
  final mesPasado = ahora.subtract(const Duration(days: 40));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = DashboardDao(db);

    final negocioId = generateUuidV4();
    await db
        .into(db.negocios)
        .insert(
          NegociosCompanion.insert(
            id: Value(negocioId),
            nombre: 'Negocio Test',
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

    cajaSesionCerradaId = generateUuidV4();
    await db
        .into(db.cajaSesiones)
        .insert(
          CajaSesionesCompanion.insert(
            id: Value(cajaSesionCerradaId),
            fechaApertura: mesPasado,
            montoApertura: 0,
            usuarioApertura: usuarioId,
            estado: EstadoCajaSesion.cerrada,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertarVenta({
    required int total,
    required int ganancia,
    required DateTime fecha,
    EstadoVenta estado = EstadoVenta.completada,
  }) {
    return db
        .into(db.ventas)
        .insert(
          VentasCompanion.insert(
            tipo: TipoVenta.rapida,
            total: total,
            ganancia: ganancia,
            cajaSesionId: cajaSesionCerradaId,
            usuarioId: usuarioId,
            estado: estado,
            fecha: fecha,
          ),
        );
  }

  Future<void> insertarCompra({
    required int total,
    required DateTime fecha,
    EstadoCompra estado = EstadoCompra.completada,
  }) {
    return db
        .into(db.compras)
        .insert(
          ComprasCompanion.insert(
            total: total,
            estado: estado,
            usuarioId: usuarioId,
            fecha: fecha,
          ),
        );
  }

  Future<void> insertarGasto({required int monto, required DateTime fecha}) {
    return db
        .into(db.gastos)
        .insert(
          GastosCompanion.insert(
            categoria: 'otros',
            concepto: 'gasto de prueba',
            fecha: fecha,
            monto: monto,
            usuarioId: usuarioId,
          ),
        );
  }

  group('watchVentasDelDia', () {
    test('suma solo las ventas completadas de hoy', () async {
      await insertarVenta(total: 1000, ganancia: 400, fecha: ahora);
      await insertarVenta(total: 500, ganancia: 200, fecha: ayer);
      await insertarVenta(
        total: 9999,
        ganancia: 1,
        fecha: ahora,
        estado: EstadoVenta.anulada,
      );

      final resultado = await dao.watchVentasDelDia().first;

      expect(resultado, Money(1000));
    });

    test('se reemite al insertar una nueva venta', () async {
      await insertarVenta(total: 1000, ganancia: 400, fecha: ahora);

      final stream = dao.watchVentasDelDia();
      final primero = await stream.first;
      expect(primero, Money(1000));

      await insertarVenta(total: 250, ganancia: 100, fecha: ahora);

      final segundo = await stream.first;
      expect(segundo, Money(1250));
    });
  });

  group('watchVentasDelMes', () {
    test('suma las ventas completadas del mes en curso', () async {
      await insertarVenta(total: 1000, ganancia: 400, fecha: ahora);
      await insertarVenta(total: 700, ganancia: 300, fecha: mesPasado);

      final resultado = await dao.watchVentasDelMes().first;

      expect(resultado, Money(1000));
    });
  });

  group('watchComprasDelMes', () {
    test('suma las compras completadas del mes en curso', () async {
      await insertarCompra(total: 2000, fecha: ahora);
      await insertarCompra(total: 1500, fecha: mesPasado);
      await insertarCompra(
        total: 999,
        fecha: ahora,
        estado: EstadoCompra.anulada,
      );

      final resultado = await dao.watchComprasDelMes().first;

      expect(resultado, Money(2000));
    });
  });

  group('watchGastosDelMes', () {
    test('suma los gastos del mes en curso', () async {
      await insertarGasto(monto: 300, fecha: ahora);
      await insertarGasto(monto: 150, fecha: mesPasado);

      final resultado = await dao.watchGastosDelMes().first;

      expect(resultado, Money(300));
    });
  });

  group('watchGananciaDelMes', () {
    test('suma la ganancia de las ventas completadas del mes', () async {
      await insertarVenta(total: 1000, ganancia: 400, fecha: ahora);
      await insertarVenta(total: 2000, ganancia: 800, fecha: ahora);
      await insertarVenta(total: 700, ganancia: 300, fecha: mesPasado);

      final resultado = await dao.watchGananciaDelMes().first;

      expect(resultado, Money(1200));
    });
  });

  group('watchProductosBajoStock', () {
    test('solo incluye productos activos con stock <= stock minimo', () async {
      await db
          .into(db.productos)
          .insert(
            ProductosCompanion.insert(
              nombre: 'Bajo stock',
              stockActual: const Value(2),
              stockMinimo: const Value(5),
            ),
          );
      await db
          .into(db.productos)
          .insert(
            ProductosCompanion.insert(
              nombre: 'Stock suficiente',
              stockActual: const Value(20),
              stockMinimo: const Value(5),
            ),
          );
      await db
          .into(db.productos)
          .insert(
            ProductosCompanion.insert(
              nombre: 'Inactivo bajo stock',
              stockActual: const Value(0),
              stockMinimo: const Value(5),
              activo: const Value(false),
            ),
          );

      final resultado = await dao.watchProductosBajoStock().first;

      expect(resultado, hasLength(1));
      expect(resultado.single.nombre, 'Bajo stock');
    });
  });

  group('watchMovimientosRecientes', () {
    test('mezcla ventas, compras y gastos ordenados por fecha desc', () async {
      final hace3 = ahora.subtract(const Duration(hours: 3));
      final hace2 = ahora.subtract(const Duration(hours: 2));
      final hace1 = ahora.subtract(const Duration(hours: 1));

      await insertarVenta(total: 1000, ganancia: 400, fecha: hace3);
      await insertarCompra(total: 500, fecha: hace2);
      await insertarGasto(monto: 200, fecha: hace1);

      final resultado = await dao.watchMovimientosRecientes().first;

      expect(resultado, hasLength(3));
      expect(resultado[0].tipo, TipoMovimientoReciente.gasto);
      expect(resultado[0].monto, Money(200));
      expect(resultado[1].tipo, TipoMovimientoReciente.compra);
      expect(resultado[1].monto, Money(500));
      expect(resultado[2].tipo, TipoMovimientoReciente.venta);
      expect(resultado[2].monto, Money(1000));
    });
  });

  group('watchCajaActual', () {
    test('devuelve null si no hay sesión abierta', () async {
      final resultado = await dao.watchCajaActual().first;

      expect(resultado, isNull);
    });

    test('calcula el monto actual como apertura + movimientos', () async {
      final sesionId = generateUuidV4();
      await db
          .into(db.cajaSesiones)
          .insert(
            CajaSesionesCompanion.insert(
              id: Value(sesionId),
              fechaApertura: ahora,
              montoApertura: 5000,
              usuarioApertura: usuarioId,
              estado: EstadoCajaSesion.abierta,
            ),
          );
      await db
          .into(db.cajaMovimientos)
          .insert(
            CajaMovimientosCompanion.insert(
              cajaSesionId: sesionId,
              tipo: TipoCajaMovimiento.venta,
              monto: 1000,
              usuarioId: usuarioId,
            ),
          );
      await db
          .into(db.cajaMovimientos)
          .insert(
            CajaMovimientosCompanion.insert(
              cajaSesionId: sesionId,
              tipo: TipoCajaMovimiento.salidaManual,
              monto: -200,
              usuarioId: usuarioId,
            ),
          );

      final resultado = await dao.watchCajaActual().first;

      expect(resultado, isNotNull);
      expect(resultado!.sesionId, sesionId);
      expect(resultado.montoApertura, Money(5000));
      expect(resultado.montoActual, Money(5800));
    });
  });
}
