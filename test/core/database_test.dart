import 'package:app_gestion/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// Crea la cadena mínima negocio → usuario admin y devuelve sus ids.
  Future<({String negocioId, String usuarioId})> seedNegocio() async {
    final negocio = await db
        .into(db.negocios)
        .insertReturning(NegociosCompanion.insert(nombre: 'Colmado La Fe'));
    final usuario = await db
        .into(db.usuarios)
        .insertReturning(
          UsuariosCompanion.insert(
            negocioId: negocio.id,
            nombre: 'Ana',
            username: 'ana',
            passwordHash: 'hash',
            salt: 'salt',
            rol: RolUsuario.administrador,
          ),
        );
    return (negocioId: negocio.id, usuarioId: usuario.id);
  }

  group('Schema v1', () {
    test('inserta y lee la cadena negocio → usuario → producto', () async {
      final seed = await seedNegocio();

      final categoria = await db
          .into(db.categorias)
          .insertReturning(CategoriasCompanion.insert(nombre: 'Embutidos'));
      final producto = await db
          .into(db.productos)
          .insertReturning(
            ProductosCompanion.insert(
              nombre: 'Salami',
              categoriaId: Value(categoria.id),
              unidad: const Value('libra'),
              precioCompra: const Value(15000),
              precioVenta: const Value(20000),
            ),
          );

      // UUID y timestamps generados por clientDefault.
      expect(producto.id, hasLength(36));
      expect(producto.createdAt.isUtc, isTrue);
      expect(producto.precioVenta, 20000);

      final usuarios = await db.select(db.usuarios).get();
      expect(usuarios.single.rol, RolUsuario.administrador);
      expect(usuarios.single.negocioId, seed.negocioId);
    });

    test('rechaza FK inválida (integridad referencial activa)', () async {
      expect(
        () => db
            .into(db.historialPrecios)
            .insert(
              HistorialPreciosCompanion.insert(
                productoId: 'producto-inexistente',
                tipo: TipoPrecio.venta,
                precioAnterior: 100,
                precioNuevo: 200,
                usuarioId: 'usuario-inexistente',
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('flujo de venta: caja + venta + items + kárdex consistente', () async {
      final seed = await seedNegocio();

      final producto = await db
          .into(db.productos)
          .insertReturning(
            ProductosCompanion.insert(
              nombre: 'Queso',
              precioCompra: const Value(10000),
              precioVenta: const Value(15000),
              stockActual: const Value(10),
            ),
          );
      final sesion = await db
          .into(db.cajaSesiones)
          .insertReturning(
            CajaSesionesCompanion.insert(
              fechaApertura: DateTime.now().toUtc(),
              montoApertura: 100000,
              usuarioApertura: seed.usuarioId,
              estado: EstadoCajaSesion.abierta,
            ),
          );
      final venta = await db
          .into(db.ventas)
          .insertReturning(
            VentasCompanion.insert(
              tipo: TipoVenta.rapida,
              total: 30000,
              ganancia: 10000, // (150 − 100) × 2 en centavos
              cajaSesionId: sesion.id,
              usuarioId: seed.usuarioId,
              estado: EstadoVenta.completada,
              fecha: DateTime.now().toUtc(),
            ),
          );
      await db
          .into(db.ventaItems)
          .insert(
            VentaItemsCompanion.insert(
              ventaId: venta.id,
              productoId: producto.id,
              cantidad: 2,
              precioUnitario: 15000,
              costoUnitario: 10000,
            ),
          );

      // Kárdex: stock inicial +10, venta −2 ⇒ SUM(cantidad) = 8.
      await db
          .into(db.movimientosInventario)
          .insert(
            MovimientosInventarioCompanion.insert(
              productoId: producto.id,
              tipo: TipoMovimientoInventario.stockInicial,
              cantidad: 10,
              stockResultante: 10,
              usuarioId: seed.usuarioId,
            ),
          );
      await db
          .into(db.movimientosInventario)
          .insert(
            MovimientosInventarioCompanion.insert(
              productoId: producto.id,
              tipo: TipoMovimientoInventario.venta,
              cantidad: -2,
              stockResultante: 8,
              referenciaId: Value(venta.id),
              usuarioId: seed.usuarioId,
            ),
          );

      final suma = db.movimientosInventario.cantidad.sum();
      final query = db.selectOnly(db.movimientosInventario)
        ..addColumns([suma])
        ..where(db.movimientosInventario.productoId.equals(producto.id));
      final stockCalculado = await query
          .map((row) => row.read(suma))
          .getSingle();

      expect(stockCalculado, 8); // RN-03: stock = SUM(movimientos)
    });

    test(
      'soft delete: el filtro deletedAt IS NULL oculta desactivados',
      () async {
        await db
            .into(db.productos)
            .insert(ProductosCompanion.insert(nombre: 'Activo'));
        await db
            .into(db.productos)
            .insert(
              ProductosCompanion.insert(
                nombre: 'Eliminado',
                deletedAt: Value(DateTime.now().toUtc()),
              ),
            );

        final visibles = await (db.select(
          db.productos,
        )..where((p) => p.deletedAt.isNull())).get();

        expect(visibles.map((p) => p.nombre), ['Activo']);
      },
    );

    test('configuración clave-valor con upsert', () async {
      await db
          .into(db.configuraciones)
          .insertOnConflictUpdate(
            ConfiguracionesCompanion.insert(
              clave: 'permitir_stock_negativo',
              valor: 'false',
            ),
          );
      await db
          .into(db.configuraciones)
          .insertOnConflictUpdate(
            ConfiguracionesCompanion.insert(
              clave: 'permitir_stock_negativo',
              valor: 'true',
            ),
          );

      final filas = await db.select(db.configuraciones).get();
      expect(filas.single.valor, 'true');
    });

    test('auditoría y sync_queue aceptan registros', () async {
      final seed = await seedNegocio();

      await db
          .into(db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: seed.usuarioId,
              accion: 'crear',
              modulo: 'productos',
              datosDespues: const Value('{"nombre":"Salami"}'),
            ),
          );
      await db
          .into(db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              tabla: 'productos',
              registroId: 'x',
              operacion: OperacionSync.insert,
              payload: '{}',
              estado: EstadoSync.pendiente,
            ),
          );

      expect((await db.select(db.auditoria).get()).length, 1);
      expect((await db.select(db.syncQueue).get()).single.intentos, 0);
    });
  });
}
