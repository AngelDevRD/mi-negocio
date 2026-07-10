import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/products/data/datasources/products_local_datasource.dart';
import 'package:app_gestion/features/products/data/repositories/products_repository_impl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProductsRepositoryImpl repo;
  late String usuarioId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProductsRepositoryImpl(ProductsLocalDatasource(db));

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
  });

  tearDown(() async {
    await db.close();
  });

  group('crearProducto', () {
    test('crea el producto y registra movimiento de stock inicial', () async {
      final result = await repo.crearProducto(
        nombre: 'Salami',
        unidad: 'libra',
        precioCompra: Money.parse('100'),
        precioVenta: Money.parse('150'),
        stockInicial: 20,
        stockMinimo: 5,
        usuarioId: usuarioId,
      );

      expect(result.isOk, isTrue);
      final producto = result.valueOrNull!;
      expect(producto.nombre, 'Salami');
      expect(producto.stockActual, 20);

      final movimientos = await db.select(db.movimientosInventario).get();
      expect(movimientos, hasLength(1));
      expect(movimientos.single.tipo, TipoMovimientoInventario.stockInicial);
      expect(movimientos.single.cantidad, 20);

      final auditoria = await db.select(db.auditoria).get();
      expect(auditoria, hasLength(1));
      expect(auditoria.single.accion, 'crear');
      expect(auditoria.single.modulo, 'productos');
    });

    test(
      'no registra movimiento de inventario si el stock inicial es 0',
      () async {
        final result = await repo.crearProducto(
          nombre: 'Queso',
          unidad: 'libra',
          precioCompra: Money.parse('80'),
          precioVenta: Money.parse('120'),
          stockInicial: 0,
          stockMinimo: 2,
          usuarioId: usuarioId,
        );

        expect(result.isOk, isTrue);
        final movimientos = await db.select(db.movimientosInventario).get();
        expect(movimientos, isEmpty);
      },
    );

    test('falla si el nombre ya existe', () async {
      await repo.crearProducto(
        nombre: 'Jamón',
        unidad: 'libra',
        precioCompra: Money.parse('100'),
        precioVenta: Money.parse('150'),
        stockInicial: 0,
        stockMinimo: 0,
        usuarioId: usuarioId,
      );

      final result = await repo.crearProducto(
        nombre: 'Jamón',
        unidad: 'libra',
        precioCompra: Money.parse('100'),
        precioVenta: Money.parse('150'),
        stockInicial: 0,
        stockMinimo: 0,
        usuarioId: usuarioId,
      );

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });

    test('falla con datos inválidos', () async {
      final result = await repo.crearProducto(
        nombre: '',
        unidad: 'libra',
        precioCompra: Money.parse('100'),
        precioVenta: Money.parse('150'),
        stockInicial: 0,
        stockMinimo: 0,
        usuarioId: usuarioId,
      );

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });
  });

  group('actualizarProducto', () {
    Future<String> crearProductoBase() async {
      final result = await repo.crearProducto(
        nombre: 'Mortadela',
        unidad: 'libra',
        precioCompra: Money.parse('50'),
        precioVenta: Money.parse('80'),
        stockInicial: 10,
        stockMinimo: 2,
        usuarioId: usuarioId,
      );
      return result.valueOrNull!.id;
    }

    test('cambio de precio inserta historial y auditoría', () async {
      final id = await crearProductoBase();

      final result1 = await repo.actualizarProducto(
        id: id,
        nombre: 'Mortadela',
        unidad: 'libra',
        precioCompra: Money.parse('55'),
        precioVenta: Money.parse('85'),
        stockMinimo: 2,
        usuarioId: usuarioId,
      );
      expect(result1.isOk, isTrue);

      final result2 = await repo.actualizarProducto(
        id: id,
        nombre: 'Mortadela',
        unidad: 'libra',
        precioCompra: Money.parse('60'),
        precioVenta: Money.parse('90'),
        stockMinimo: 2,
        usuarioId: usuarioId,
      );
      expect(result2.isOk, isTrue);

      final historial = await db.select(db.historialPrecios).get();
      // 2 cambios x (compra + venta) = 4 entradas.
      expect(historial, hasLength(4));

      // crear (1) + 2 ediciones = 3 registros de auditoría.
      final auditoria = await db.select(db.auditoria).get();
      expect(auditoria.where((a) => a.accion == 'editar'), hasLength(2));

      final producto = await repo.obtenerProducto(id);
      expect(producto!.precioCompra, Money.parse('60'));
      expect(producto.precioVenta, Money.parse('90'));
    });

    test('no inserta historial si el precio no cambia', () async {
      final id = await crearProductoBase();

      await repo.actualizarProducto(
        id: id,
        nombre: 'Mortadela especial',
        unidad: 'libra',
        precioCompra: Money.parse('50'),
        precioVenta: Money.parse('80'),
        stockMinimo: 3,
        usuarioId: usuarioId,
      );

      final historial = await db.select(db.historialPrecios).get();
      expect(historial, isEmpty);

      final producto = await repo.obtenerProducto(id);
      expect(producto!.nombre, 'Mortadela especial');
      expect(producto.stockMinimo, 3);
    });

    test('falla si el producto no existe', () async {
      final result = await repo.actualizarProducto(
        id: generateUuidV4(),
        nombre: 'Inexistente',
        unidad: 'libra',
        precioCompra: Money.parse('10'),
        precioVenta: Money.parse('20'),
        stockMinimo: 0,
        usuarioId: usuarioId,
      );

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });
  });

  group('establecerActivo', () {
    test('desactiva y reactiva el producto, registrando auditoría', () async {
      final creado = await repo.crearProducto(
        nombre: 'Chorizo',
        unidad: 'libra',
        precioCompra: Money.parse('40'),
        precioVenta: Money.parse('60'),
        stockInicial: 5,
        stockMinimo: 1,
        usuarioId: usuarioId,
      );
      final id = creado.valueOrNull!.id;

      final desactivar = await repo.establecerActivo(
        id: id,
        activo: false,
        usuarioId: usuarioId,
      );
      expect(desactivar.isOk, isTrue);

      var producto = await repo.obtenerProducto(id);
      expect(producto!.activo, isFalse);

      final activar = await repo.establecerActivo(
        id: id,
        activo: true,
        usuarioId: usuarioId,
      );
      expect(activar.isOk, isTrue);

      producto = await repo.obtenerProducto(id);
      expect(producto!.activo, isTrue);

      final auditoria = await db.select(db.auditoria).get();
      expect(auditoria.where((a) => a.accion == 'desactivar'), hasLength(1));
      expect(auditoria.where((a) => a.accion == 'activar'), hasLength(1));
    });
  });

  group('categorías', () {
    test('crear, renombrar y eliminar una categoría', () async {
      final crear = await repo.crearCategoria('Embutidos');
      expect(crear.isOk, isTrue);
      final categoria = crear.valueOrNull!;

      final renombrar = await repo.renombrarCategoria(
        id: categoria.id,
        nombre: 'Embutidos finos',
      );
      expect(renombrar.isOk, isTrue);

      final categorias = await repo.watchCategorias().first;
      expect(categorias.single.nombre, 'Embutidos finos');

      final eliminar = await repo.eliminarCategoria(categoria.id);
      expect(eliminar.isOk, isTrue);

      final categoriasTrasEliminar = await repo.watchCategorias().first;
      expect(categoriasTrasEliminar, isEmpty);
    });

    test('falla si el nombre de categoría ya existe', () async {
      await repo.crearCategoria('Lácteos');
      final result = await repo.crearCategoria('Lácteos');

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });
  });
}
