import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/purchases/data/datasources/purchases_local_datasource.dart';
import 'package:app_gestion/features/purchases/data/repositories/purchases_repository_impl.dart';
import 'package:app_gestion/features/purchases/domain/entities/compra.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PurchasesRepositoryImpl repo;
  late String usuarioId;
  late String productoId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PurchasesRepositoryImpl(PurchasesLocalDatasource(db));

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

  group('crearProveedor', () {
    test('crea un proveedor', () async {
      final result = await repo.crearProveedor(
        nombre: 'Distribuidora ABC',
        telefono: '809-555-1234',
      );
      expect(result.isOk, isTrue);
      result.when(
        ok: (proveedor) {
          expect(proveedor.nombre, 'Distribuidora ABC');
          expect(proveedor.telefono, '809-555-1234');
        },
        fail: (_) => fail('no debería fallar'),
      );
    });

    test('falla si el nombre está vacío', () async {
      final result = await repo.crearProveedor(nombre: '   ');
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si ya existe un proveedor con el mismo nombre', () async {
      await repo.crearProveedor(nombre: 'Distribuidora ABC');
      final result = await repo.crearProveedor(nombre: 'Distribuidora ABC');
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });
  });

  group('registrarCompra', () {
    test('falla si no hay items', () async {
      final result = await repo.registrarCompra(
        items: const [],
        pagadaDeCaja: false,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si la cantidad de un ítem es cero o negativa', () async {
      final result = await repo.registrarCompra(
        items: [
          ItemCompraInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 0,
            costoUnitario: const Money(100),
          ),
        ],
        pagadaDeCaja: false,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si el producto no existe', () async {
      final result = await repo.registrarCompra(
        items: [
          ItemCompraInput(
            productoId: generateUuidV4(),
            productoNombre: 'Inexistente',
            cantidad: 1,
            costoUnitario: const Money(100),
          ),
        ],
        pagadaDeCaja: false,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si está pagada de caja y no hay sesión abierta', () async {
      final result = await repo.registrarCompra(
        items: [
          ItemCompraInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 5,
            costoUnitario: const Money(100),
          ),
        ],
        pagadaDeCaja: true,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test(
      'compra completa actualiza stock, costo, historial y auditoría',
      () async {
        final result = await repo.registrarCompra(
          numeroFactura: 'F-001',
          items: [
            ItemCompraInput(
              productoId: productoId,
              productoNombre: 'Salami',
              cantidad: 5,
              costoUnitario: const Money(120),
            ),
          ],
          pagadaDeCaja: false,
          usuarioId: usuarioId,
        );
        expect(result.isOk, isTrue);
        final compraId = result.valueOrNull!;

        final producto = await (db.select(
          db.productos,
        )..where((t) => t.id.equals(productoId))).getSingle();
        expect(producto.stockActual, 15);
        expect(producto.precioCompra, 120);

        final movimientos = await db.select(db.movimientosInventario).get();
        expect(movimientos, hasLength(1));
        expect(movimientos.single.tipo, TipoMovimientoInventario.compra);
        expect(movimientos.single.cantidad, 5);
        expect(movimientos.single.referenciaId, compraId);

        final historial = await db.select(db.historialPrecios).get();
        expect(historial, hasLength(1));
        expect(historial.single.precioAnterior, 100);
        expect(historial.single.precioNuevo, 120);
        expect(historial.single.tipo, TipoPrecio.compra);

        final auditoria = await db.select(db.auditoria).get();
        // Una entrada de inventario (applyMovement) + una de compras.
        expect(auditoria, hasLength(2));
        expect(
          auditoria.map((a) => a.modulo),
          containsAll(<String>['inventario', 'compras']),
        );
      },
    );

    test('no crea historial_precios si el costo no cambió', () async {
      await repo.registrarCompra(
        items: [
          ItemCompraInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 5,
            costoUnitario: const Money(100),
          ),
        ],
        pagadaDeCaja: false,
        usuarioId: usuarioId,
      );

      final historial = await db.select(db.historialPrecios).get();
      expect(historial, isEmpty);

      final producto = await (db.select(
        db.productos,
      )..where((t) => t.id.equals(productoId))).getSingle();
      expect(producto.precioCompra, 100);
    });

    test(
      'pagada de caja con sesión abierta registra salida en caja_movimientos',
      () async {
        final cajaSesionId = generateUuidV4();
        await db
            .into(db.cajaSesiones)
            .insert(
              CajaSesionesCompanion.insert(
                id: Value(cajaSesionId),
                fechaApertura: DateTime.now().toUtc(),
                montoApertura: 0,
                usuarioApertura: usuarioId,
                estado: EstadoCajaSesion.abierta,
              ),
            );

        final result = await repo.registrarCompra(
          items: [
            ItemCompraInput(
              productoId: productoId,
              productoNombre: 'Salami',
              cantidad: 2,
              costoUnitario: const Money(100),
            ),
          ],
          pagadaDeCaja: true,
          usuarioId: usuarioId,
        );
        expect(result.isOk, isTrue);
        final compraId = result.valueOrNull!;

        final movimientosCaja = await db.select(db.cajaMovimientos).get();
        expect(movimientosCaja, hasLength(1));
        expect(movimientosCaja.single.tipo, TipoCajaMovimiento.compra);
        expect(movimientosCaja.single.monto, -200);
        expect(movimientosCaja.single.referenciaId, compraId);
        expect(movimientosCaja.single.cajaSesionId, cajaSesionId);
      },
    );
  });

  group('watchCompras / obtenerCompra', () {
    test('lista compras con proveedor y usuario, e incluye ítems', () async {
      final proveedor = await repo.crearProveedor(nombre: 'Distribuidora ABC');
      final proveedorId = proveedor.valueOrNull!.id;

      final result = await repo.registrarCompra(
        proveedorId: proveedorId,
        numeroFactura: 'F-100',
        items: [
          ItemCompraInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 3,
            costoUnitario: const Money(110),
          ),
        ],
        pagadaDeCaja: false,
        usuarioId: usuarioId,
      );
      final compraId = result.valueOrNull!;

      final lista = await repo.watchCompras().first;
      expect(lista, hasLength(1));
      expect(lista.single.proveedorNombre, 'Distribuidora ABC');
      expect(lista.single.usuarioNombre, 'Admin');
      expect(lista.single.total, const Money(330));

      final detalle = await repo.obtenerCompra(compraId);
      expect(detalle, isNotNull);
      expect(detalle!.items, hasLength(1));
      expect(detalle.items.single.productoNombre, 'Salami');
      expect(detalle.items.single.subtotal, const Money(330));
    });

    test('retorna null si la compra no existe', () async {
      final detalle = await repo.obtenerCompra(generateUuidV4());
      expect(detalle, isNull);
    });
  });
}
