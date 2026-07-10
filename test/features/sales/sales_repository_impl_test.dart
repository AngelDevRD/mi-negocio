import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:app_gestion/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:app_gestion/features/sales/domain/entities/venta.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SalesRepositoryImpl repo;
  late String usuarioId;
  late String productoId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SalesRepositoryImpl(SalesLocalDatasource(db));

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

    productoId = generateUuidV4();
    await db
        .into(db.productos)
        .insert(
          ProductosCompanion.insert(
            id: Value(productoId),
            nombre: 'Salami',
            unidad: const Value('libra'),
            precioCompra: const Value(100),
            precioVenta: const Value(150),
            stockActual: const Value(10),
            stockMinimo: const Value(2),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('abrirCaja', () {
    test('abre una sesión de caja', () async {
      final result = await repo.abrirCaja(
        montoApertura: const Money(50000),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final sesiones = await db.select(db.cajaSesiones).get();
      expect(sesiones, hasLength(1));
      expect(sesiones.single.estado, EstadoCajaSesion.abierta);
      expect(sesiones.single.montoApertura, 50000);
    });

    test('falla con monto negativo', () async {
      final result = await repo.abrirCaja(
        montoApertura: const Money(-100),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si ya hay una sesión abierta', () async {
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);
      final result = await repo.abrirCaja(
        montoApertura: const Money(0),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });
  });

  group('registrarVenta', () {
    test('falla si no hay items', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: const [],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si la cantidad de un ítem es cero o negativa', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 0,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si el precio de un ítem es negativo', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 1,
            precioUnitario: const Money(-10),
          ),
        ],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si el producto no existe', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: generateUuidV4(),
            productoNombre: 'Inexistente',
            cantidad: 1,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si no hay caja abierta (RN-01)', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 1,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) {
          expect(f, isA<BusinessRuleFailure>());
          expect((f as BusinessRuleFailure).rule, 'RN-01');
        },
      );
    });

    test(
      'venta completa calcula ganancia, descuenta stock y registra caja/auditoría',
      () async {
        await repo.abrirCaja(
          montoApertura: const Money(0),
          usuarioId: usuarioId,
        );

        final result = await repo.registrarVenta(
          tipo: TipoVenta.detallada,
          items: [
            ItemVentaInput(
              productoId: productoId,
              productoNombre: 'Salami',
              cantidad: 4,
              precioUnitario: const Money(150),
            ),
          ],
          nota: 'Cliente frecuente',
          usuarioId: usuarioId,
        );
        expect(result.isOk, isTrue);
        final ventaId = result.valueOrNull!;

        final producto = await (db.select(
          db.productos,
        )..where((t) => t.id.equals(productoId))).getSingle();
        expect(producto.stockActual, 6);

        final venta = await repo.obtenerVenta(ventaId);
        expect(venta, isNotNull);
        expect(venta!.total, const Money(600));
        expect(venta.ganancia, const Money(200));
        expect(venta.estado, EstadoVenta.completada);
        expect(venta.nota, 'Cliente frecuente');
        expect(venta.items, hasLength(1));
        expect(venta.items.single.costoUnitario, const Money(100));

        final movimientos = await db.select(db.movimientosInventario).get();
        expect(movimientos, hasLength(1));
        expect(movimientos.single.tipo, TipoMovimientoInventario.venta);
        expect(movimientos.single.cantidad, -4);

        final movimientosCaja = await db.select(db.cajaMovimientos).get();
        expect(movimientosCaja, hasLength(1));
        expect(movimientosCaja.single.tipo, TipoCajaMovimiento.venta);
        expect(movimientosCaja.single.monto, 600);

        final auditoria = await db.select(db.auditoria).get();
        // Apertura de caja + entrada de inventario (applyMovement) + ventas.
        expect(auditoria, hasLength(3));
        expect(
          auditoria.map((a) => a.modulo),
          containsAll(<String>['caja', 'inventario', 'ventas']),
        );
      },
    );
  });

  group('anularVenta', () {
    test('falla si la venta no existe', () async {
      final result = await repo.anularVenta(
        generateUuidV4(),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test(
      'revierte stock, registra salida de caja y marca como anulada',
      () async {
        await repo.abrirCaja(
          montoApertura: const Money(0),
          usuarioId: usuarioId,
        );
        final registro = await repo.registrarVenta(
          tipo: TipoVenta.rapida,
          items: [
            ItemVentaInput(
              productoId: productoId,
              productoNombre: 'Salami',
              cantidad: 4,
              precioUnitario: const Money(150),
            ),
          ],
          usuarioId: usuarioId,
        );
        final ventaId = registro.valueOrNull!;

        final result = await repo.anularVenta(ventaId, usuarioId: usuarioId);
        expect(result.isOk, isTrue);

        final producto = await (db.select(
          db.productos,
        )..where((t) => t.id.equals(productoId))).getSingle();
        expect(producto.stockActual, 10);

        final venta = await repo.obtenerVenta(ventaId);
        expect(venta!.estado, EstadoVenta.anulada);

        final movimientosCaja = await db.select(db.cajaMovimientos).get();
        expect(movimientosCaja, hasLength(2));
        expect(
          movimientosCaja.map((m) => m.monto),
          containsAll(<int>[600, -600]),
        );
      },
    );

    test('falla si la venta ya está anulada', () async {
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);
      final registro = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 1,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );
      final ventaId = registro.valueOrNull!;
      await repo.anularVenta(ventaId, usuarioId: usuarioId);

      final result = await repo.anularVenta(ventaId, usuarioId: usuarioId);
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });
  });

  group('watchVentas / obtenerVenta', () {
    test('lista ventas con usuario e items', () async {
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);
      await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 2,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );

      final lista = await repo.watchVentas().first;
      expect(lista, hasLength(1));
      expect(lista.single.usuarioNombre, 'Admin');
      expect(lista.single.total, const Money(300));
    });

    test('retorna null si la venta no existe', () async {
      final detalle = await repo.obtenerVenta(generateUuidV4());
      expect(detalle, isNull);
    });
  });
}
