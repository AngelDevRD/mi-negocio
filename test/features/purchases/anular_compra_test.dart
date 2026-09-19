import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/cash_register/data/datasources/cash_register_local_datasource.dart';
import 'package:app_gestion/features/cash_register/data/repositories/cash_register_repository_impl.dart';
import 'package:app_gestion/features/purchases/data/datasources/purchases_local_datasource.dart';
import 'package:app_gestion/features/purchases/data/repositories/purchases_repository_impl.dart';
import 'package:app_gestion/features/purchases/domain/entities/compra.dart';
import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_test/flutter_test.dart';

import '../customers/fiado_fixture.dart';

Failure? _fallo(Result<Object?> r) => r.when(ok: (_) => null, fail: (f) => f);

void main() {
  late FiadoFixture f;
  late PurchasesRepositoryImpl repo;
  late CashRegisterRepositoryImpl caja;
  late String cajeroId;

  setUp(() async {
    f = await FiadoFixture.crear();
    repo = PurchasesRepositoryImpl(PurchasesLocalDatasource(f.db));
    caja = CashRegisterRepositoryImpl(CashRegisterLocalDatasource(f.db));
    final negocio = await f.db.select(f.db.negocios).getSingle();
    cajeroId = generateUuidV4();
    await f.db
        .into(f.db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: Value(cajeroId),
            negocioId: negocio.id,
            nombre: 'Cajero',
            username: 'cajero',
            passwordHash: 'hash',
            salt: 'salt',
            rol: RolUsuario.cajero,
          ),
        );
  });

  tearDown(() => f.cerrar());

  Future<String> comprar({
    double cantidad = 50,
    int costo = 10000,
    bool deCaja = false,
  }) async {
    final r = await repo.registrarCompra(
      items: [
        ItemCompraInput(
          productoId: f.productoId,
          productoNombre: 'Salami',
          cantidad: cantidad,
          costoUnitario: Money(costo),
        ),
      ],
      pagadaDeCaja: deCaja,
      usuarioId: f.usuarioId,
    );
    return r.valueOrNull!;
  }

  Future<Result<ResultadoAnulacionCompra>> anular(
    String id, {
    String? usuario,
  }) => repo.anularCompra(id, usuarioId: usuario ?? f.usuarioId);

  Future<Producto> producto() => (f.db.select(
    f.db.productos,
  )..where((t) => t.id.equals(f.productoId))).getSingle();

  Future<EstadoCompra> estadoDe(String id) async => (await (f.db.select(
    f.db.compras,
  )..where((t) => t.id.equals(id))).getSingle()).estado;

  Future<List<int>> escrituras() async => [
    await f.cantidadEn('movimientos_inventario'),
    await f.cantidadEn('caja_movimientos'),
    await f.cantidadEn('historial_precios'),
    await f.cantidadEn('auditoria'),
    await f.cantidadEn('sync_queue'),
  ];

  /// Deja la compra y su cambio de costo en el pasado (así lo que se haga
  /// después queda claramente POSTERIOR, sin depender del reloj del test).
  Future<void> retroceder(String compraId, DateTime instante) async {
    await (f.db.update(f.db.compras)..where((t) => t.id.equals(compraId)))
        .write(ComprasCompanion(fecha: Value(instante)));
    // El historial se crea junto con la compra: mismo instante (+1 s).
    final hist = await f.db.select(f.db.historialPrecios).get();
    for (final h in hist) {
      await (f.db.update(
        f.db.historialPrecios,
      )..where((t) => t.id.equals(h.id))).write(
        HistorialPreciosCompanion(
          fecha: Value(instante.add(const Duration(seconds: 1))),
        ),
      );
    }
  }

  group('anularCompra: stock, estado, auditoría y cola', () {
    test('revierte el stock, marca la compra anulada y registra el '
        'movimiento anulacionCompra', () async {
      final id = await comprar(cantidad: 50);
      expect((await producto()).stockActual, 150);

      final r = await anular(id);

      expect(r.isOk, isTrue);
      expect((await producto()).stockActual, 100);
      expect(await estadoDe(id), EstadoCompra.anulada);
      final movs = await (f.db.select(
        f.db.movimientosInventario,
      )..where((t) => t.referenciaId.equals(id))).get();
      final anulacion = movs.where(
        (m) => m.tipo == TipoMovimientoInventario.anulacionCompra,
      );
      expect(anulacion, hasLength(1));
      expect(anulacion.single.cantidad, -50);
      expect(anulacion.single.stockResultante, 100);
    });

    test('el stock puede quedar NEGATIVO (es una corrección, no aplica '
        'RN-12)', () async {
      await f.abrirCaja();
      final id = await comprar(cantidad: 10); // stock 110
      expect((await f.vender(cantidad: 105)).isOk, isTrue); // stock 5

      final r = await anular(id);

      expect(r.isOk, isTrue);
      expect((await producto()).stockActual, -5);
    });

    test('audita (antes/después) y encola todo lo escrito', () async {
      final id = await comprar();
      final colaAntes = (await f.db.select(f.db.syncQueue).get()).length;

      await anular(id);

      final auditoria = await (f.db.select(
        f.db.auditoria,
      )..where((t) => t.accion.equals('anular'))).get();
      expect(auditoria, hasLength(1));
      expect(auditoria.single.modulo, 'compras');
      expect(auditoria.single.entidadId, id);
      expect(auditoria.single.usuarioId, f.usuarioId);
      expect(auditoria.single.datosAntes, contains('completada'));
      expect(auditoria.single.datosDespues, contains('anulada'));

      final cola = await f.db.select(f.db.syncQueue).get();
      expect(cola.length, greaterThan(colaAntes));
      bool encolado(String tabla, {String? id}) => cola.any(
        (c) => c.tabla == tabla && (id == null || c.registroId == id),
      );
      expect(
        cola.any(
          (c) =>
              c.tabla == 'compras' &&
              c.registroId == id &&
              c.operacion == OperacionSync.update,
        ),
        isTrue,
      );
      expect(encolado('movimientos_inventario'), isTrue);
      expect(encolado('productos', id: f.productoId), isTrue);
      expect(encolado('auditoria', id: auditoria.single.id), isTrue);
    });

    test('la compra ya anulada falla sin escribir nada', () async {
      final id = await comprar();
      await anular(id);
      final antes = await escrituras();

      final r = await anular(id);

      expect(_fallo(r), isA<ValidationFailure>());
      expect(_fallo(r)!.message, contains('anulada'));
      expect(await escrituras(), antes);
      expect((await producto()).stockActual, 100);
    });

    test('una compra inexistente falla sin escribir nada', () async {
      final antes = await escrituras();

      final r = await anular('no-existe');

      expect(_fallo(r), isA<ValidationFailure>());
      expect(await escrituras(), antes);
    });

    test('doble anulación CONCURRENTE = una sola reversión', () async {
      final id = await comprar(cantidad: 50);

      final resultados = await Future.wait([anular(id), anular(id)]);

      expect(resultados.where((r) => r.isOk), hasLength(1));
      expect(resultados.where((r) => !r.isOk), hasLength(1));
      expect((await producto()).stockActual, 100); // no 50
      final anulaciones =
          await (f.db.select(f.db.movimientosInventario)..where(
                (t) => t.tipo.equalsValue(
                  TipoMovimientoInventario.anulacionCompra,
                ),
              ))
              .get();
      expect(anulaciones, hasLength(1));
    });

    test('el Cajero NO puede anular: falla sin escribir nada', () async {
      final id = await comprar();
      final antes = await escrituras();

      final r = await anular(id, usuario: cajeroId);

      expect(_fallo(r), isA<PermissionFailure>());
      expect(await estadoDe(id), EstadoCompra.completada);
      expect((await producto()).stockActual, 150);
      expect(await escrituras(), antes);
    });
  });

  group('anularCompra: caja', () {
    test('pagada de caja con la sesión ABIERTA: movimiento compensatorio y '
        'el esperado vuelve', () async {
      await f.abrirCaja(const Money(100000));
      final id = await comprar(cantidad: 5, deCaja: true); // -50000
      expect(
        (await caja.watchSesionActual().first)!.montoActual,
        const Money(50000),
      );

      final r = await anular(id);

      expect(r.isOk, isTrue);
      expect(r.valueOrNull!.cajaYaCerrada, isFalse);
      final sesion = (await caja.watchSesionActual().first)!;
      expect(sesion.montoActual, const Money(100000));
      final movs = await (f.db.select(
        f.db.cajaMovimientos,
      )..where((t) => t.referenciaId.equals(id))).get();
      expect(movs, hasLength(2)); // la salida y su compensación
      final compensacion = movs.firstWhere((m) => m.monto > 0);
      expect(compensacion.monto, 50000);
      expect(compensacion.tipo, TipoCajaMovimiento.compra);
      // Lo compensado también se sincroniza.
      final cola = await f.db.select(f.db.syncQueue).get();
      expect(
        cola.any(
          (c) =>
              c.tabla == 'caja_movimientos' && c.registroId == compensacion.id,
        ),
        isTrue,
      );
    });

    test('pagada de caja con la sesión YA CERRADA: no inserta movimiento y '
        'lo indica', () async {
      await f.abrirCaja(const Money(100000));
      final id = await comprar(cantidad: 5, deCaja: true);
      await caja.cerrarCaja(
        montoContado: const Money(50000),
        montoDejarSiguiente: const Money(0),
        usuarioId: f.usuarioId,
      );
      final movsAntes = await f.cantidadEn('caja_movimientos');

      final r = await anular(id);

      expect(r.isOk, isTrue);
      expect(r.valueOrNull!.cajaYaCerrada, isTrue);
      expect(await f.cantidadEn('caja_movimientos'), movsAntes);
      expect(await estadoDe(id), EstadoCompra.anulada);
      expect((await producto()).stockActual, 100); // el stock sí se revierte
    });

    test(
      'una compra NO pagada de caja no toca la caja ni avisa nada',
      () async {
        await f.abrirCaja(const Money(100000));
        final id = await comprar(cantidad: 5);
        final movsAntes = await f.cantidadEn('caja_movimientos');

        final r = await anular(id);

        expect(r.valueOrNull!.cajaYaCerrada, isFalse);
        expect(await f.cantidadEn('caja_movimientos'), movsAntes);
      },
    );

    test('el detalle indica si la caja del pago sigue abierta', () async {
      await f.abrirCaja(const Money(100000));
      final deCaja = await comprar(cantidad: 5, deCaja: true);
      final sinCaja = await comprar(cantidad: 5);

      expect((await repo.obtenerCompra(deCaja))!.cajaDelPagoAbierta, isTrue);
      expect((await repo.obtenerCompra(sinCaja))!.cajaDelPagoAbierta, isNull);

      await caja.cerrarCaja(
        montoContado: const Money(50000),
        montoDejarSiguiente: const Money(0),
        usuarioId: f.usuarioId,
      );
      expect((await repo.obtenerCompra(deCaja))!.cajaDelPagoAbierta, isFalse);
    });
  });

  group('anularCompra: costo', () {
    test('restaura el costo anterior si nadie lo cambió después', () async {
      final id = await comprar(cantidad: 10, costo: 12000);
      expect((await producto()).precioCompra, 12000);

      final r = await anular(id);

      expect((await producto()).precioCompra, 10000);
      expect(r.valueOrNull!.costoRestaurado, ['Salami']);
      expect(r.valueOrNull!.costoConservado, isEmpty);
      // El cambio queda en el historial de precios (RN-04).
      final hist = await (f.db.select(
        f.db.historialPrecios,
      )..orderBy([(t) => OrderingTerm.desc(t.fecha)])).get();
      final restauracion = hist.firstWhere(
        (h) => h.precioAnterior == 12000 && h.precioNuevo == 10000,
      );
      expect(restauracion.tipo, TipoPrecio.compra);
      expect(restauracion.usuarioId, f.usuarioId);
    });

    test('NO restaura si el costo cambió DESPUÉS (otra compra)', () async {
      final a = await comprar(cantidad: 10, costo: 12000);
      await retroceder(a, DateTime.utc(2020, 1, 1, 10));
      await comprar(cantidad: 1, costo: 13000);
      expect((await producto()).precioCompra, 13000);

      final r = await anular(a);

      expect((await producto()).precioCompra, 13000);
      expect(r.valueOrNull!.costoRestaurado, isEmpty);
      expect(r.valueOrNull!.costoConservado, ['Salami']);
      // El stock sí se revierte.
      expect((await producto()).stockActual, 100 + 1);
    });

    test('NO restaura si cambió después y VOLVIÓ al mismo valor', () async {
      final a = await comprar(cantidad: 10, costo: 12000);
      await retroceder(a, DateTime.utc(2020, 1, 1, 10));
      await comprar(cantidad: 1, costo: 13000);
      await comprar(cantidad: 1, costo: 12000);
      expect((await producto()).precioCompra, 12000); // igual al de A

      final r = await anular(a);

      expect((await producto()).precioCompra, 12000);
      expect(r.valueOrNull!.costoConservado, ['Salami']);
    });

    test(
      'una compra que no cambió el costo no restaura ni reporta nada',
      () async {
        final id = await comprar(cantidad: 10, costo: 10000);

        final r = await anular(id);

        expect((await producto()).precioCompra, 10000);
        expect(r.valueOrNull!.costoRestaurado, isEmpty);
        expect(r.valueOrNull!.costoConservado, isEmpty);
      },
    );

    test('con dos compras del mismo producto en el mismo instante NO se '
        'puede identificar sin ambigüedad: no restaura y lo reporta', () async {
      final a = await comprar(cantidad: 10, costo: 12000);
      final b = await comprar(cantidad: 10, costo: 12000);
      final instante = DateTime.utc(2020, 1, 1, 10);
      await retroceder(a, instante);
      await (f.db.update(f.db.compras)..where((t) => t.id.equals(b))).write(
        ComprasCompanion(fecha: Value(instante)),
      );

      final r = await anular(a);

      expect((await producto()).precioCompra, 12000);
      expect(r.valueOrNull!.costoConservado, ['Salami']);
    });
  });
}
