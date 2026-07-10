import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/cash_register/data/datasources/cash_register_local_datasource.dart';
import 'package:app_gestion/features/cash_register/data/repositories/cash_register_repository_impl.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:app_gestion/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:app_gestion/features/sales/domain/entities/venta.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CashRegisterRepositoryImpl repo;
  late SalesRepositoryImpl salesRepo;
  late String usuarioId;
  late String productoId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CashRegisterRepositoryImpl(CashRegisterLocalDatasource(db));
    salesRepo = SalesRepositoryImpl(SalesLocalDatasource(db));

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

  group('watchSesionActual', () {
    test('retorna null si no hay sesión abierta', () async {
      final sesion = await repo.watchSesionActual().first;
      expect(sesion, isNull);
    });

    test('retorna la sesión abierta con sus movimientos', () async {
      await salesRepo.abrirCaja(
        montoApertura: const Money(50000),
        usuarioId: usuarioId,
      );
      await salesRepo.registrarVenta(
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

      final sesion = await repo.watchSesionActual().first;
      expect(sesion, isNotNull);
      expect(sesion!.estado, EstadoCajaSesion.abierta);
      expect(sesion.montoApertura, const Money(50000));
      expect(sesion.usuarioAperturaNombre, 'Admin');
      expect(sesion.movimientos, hasLength(1));
      expect(sesion.movimientos.single.tipo, TipoCajaMovimiento.venta);
      expect(sesion.movimientos.single.monto, const Money(300));
      expect(sesion.montoActual, const Money(50300));
    });
  });

  group('obtenerMontoSugeridoApertura', () {
    test('retorna cero si no hay sesiones cerradas', () async {
      final monto = await repo.obtenerMontoSugeridoApertura();
      expect(monto, Money.zero);
    });

    test('retorna el monto dejado de la última sesión cerrada', () async {
      await salesRepo.abrirCaja(
        montoApertura: const Money(50000),
        usuarioId: usuarioId,
      );
      await repo.cerrarCaja(
        montoContado: const Money(50000),
        montoDejarSiguiente: const Money(20000),
        usuarioId: usuarioId,
      );

      final monto = await repo.obtenerMontoSugeridoApertura();
      expect(monto, const Money(20000));
    });
  });

  group('cerrarCaja', () {
    test('falla si el monto contado es negativo', () async {
      final result = await repo.cerrarCaja(
        montoContado: const Money(-1),
        montoDejarSiguiente: const Money(0),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si el monto a dejar es negativo', () async {
      final result = await repo.cerrarCaja(
        montoContado: const Money(1000),
        montoDejarSiguiente: const Money(-1),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si el monto a dejar es mayor que el contado', () async {
      await salesRepo.abrirCaja(
        montoApertura: const Money(1000),
        usuarioId: usuarioId,
      );
      final result = await repo.cerrarCaja(
        montoContado: const Money(1000),
        montoDejarSiguiente: const Money(2000),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si no hay caja abierta', () async {
      final result = await repo.cerrarCaja(
        montoContado: const Money(0),
        montoDejarSiguiente: const Money(0),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('cierra la caja calculando esperado, diferencia y retiro', () async {
      await salesRepo.abrirCaja(
        montoApertura: const Money(50000),
        usuarioId: usuarioId,
      );
      await salesRepo.registrarVenta(
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

      // Esperado = 50000 + 300 = 50300. Contado tiene un sobrante de 100.
      final result = await repo.cerrarCaja(
        montoContado: const Money(50400),
        montoDejarSiguiente: const Money(20000),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final sesionAbierta = await repo.watchSesionActual().first;
      expect(sesionAbierta, isNull);

      final historial = await repo.watchHistorial().first;
      expect(historial, hasLength(1));
      final cerrada = historial.single;
      expect(cerrada.estado, EstadoCajaSesion.cerrada);
      expect(cerrada.montoEsperado, const Money(50300));
      expect(cerrada.montoContado, const Money(50400));
      expect(cerrada.diferencia, const Money(100));
      expect(cerrada.montoDejadoSiguiente, const Money(20000));
      expect(cerrada.usuarioAperturaNombre, 'Admin');
      expect(cerrada.usuarioCierreNombre, 'Admin');

      final detalle = await repo.obtenerSesion(cerrada.id);
      expect(detalle, isNotNull);
      // venta (300) + retiro de cierre (-(50400-20000) = -30400)
      expect(detalle!.movimientos, hasLength(2));
      expect(
        detalle.movimientos.map((m) => m.tipo),
        containsAll(<TipoCajaMovimiento>[
          TipoCajaMovimiento.venta,
          TipoCajaMovimiento.retiroCierre,
        ]),
      );
      final retiro = detalle.movimientos.firstWhere(
        (m) => m.tipo == TipoCajaMovimiento.retiroCierre,
      );
      expect(retiro.monto, const Money(-30400));
    });
  });
}
