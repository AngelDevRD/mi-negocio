import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/cash_register/data/datasources/cash_register_local_datasource.dart';
import 'package:app_gestion/features/cash_register/data/repositories/cash_register_repository_impl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../customers/fiado_fixture.dart';

Failure? _fallo(Result<void> r) => r.when(ok: (_) => null, fail: (f) => f);

void main() {
  late FiadoFixture f;
  late CashRegisterRepositoryImpl repo;

  setUp(() async {
    f = await FiadoFixture.crear();
    repo = CashRegisterRepositoryImpl(CashRegisterLocalDatasource(f.db));
  });

  tearDown(() => f.cerrar());

  Future<Result<void>> entrada(int cents, [String motivo = 'Cambio']) =>
      repo.registrarMovimientoManual(
        entrada: true,
        monto: Money(cents),
        motivo: motivo,
        usuarioId: f.usuarioId,
      );

  Future<Result<void>> salida(int cents, [String motivo = 'Delivery']) =>
      repo.registrarMovimientoManual(
        entrada: false,
        monto: Money(cents),
        motivo: motivo,
        usuarioId: f.usuarioId,
      );

  /// Cuántas filas hay en las tablas que un intento fallido NO debe tocar.
  Future<List<int>> escrituras() async => [
    await f.cantidadEn('caja_movimientos'),
    await f.cantidadEn('auditoria'),
    await f.cantidadEn('sync_queue'),
  ];

  group('registrarMovimientoManual', () {
    test('una entrada SUMA al efectivo esperado', () async {
      await f.abrirCaja(const Money(100000));

      final r = await entrada(5000, 'Cambio');

      expect(r.isOk, isTrue);
      final sesion = (await repo.watchSesionActual().first)!;
      expect(sesion.montoActual, const Money(105000));
      final mov = sesion.movimientos.single;
      expect(mov.tipo, TipoCajaMovimiento.entradaManual);
      expect(mov.monto, const Money(5000));
      expect(mov.motivo, 'Cambio');
    });

    test('una salida RESTA del efectivo esperado', () async {
      await f.abrirCaja(const Money(100000));

      final r = await salida(3000, 'Delivery');

      expect(r.isOk, isTrue);
      final sesion = (await repo.watchSesionActual().first)!;
      expect(sesion.montoActual, const Money(97000));
      final mov = sesion.movimientos.single;
      expect(mov.tipo, TipoCajaMovimiento.salidaManual);
      expect(mov.monto, const Money(-3000));
      expect(mov.motivo, 'Delivery');
    });

    test('el motivo se guarda sin espacios sobrantes', () async {
      await f.abrirCaja(const Money(100000));

      await entrada(1000, '  Cambio  ');

      final sesion = (await repo.watchSesionActual().first)!;
      expect(sesion.movimientos.single.motivo, 'Cambio');
    });

    test('una salida que deja el efectivo EN NEGATIVO falla sin escribir '
        'nada', () async {
      await f.abrirCaja(const Money(1000));
      final antes = await escrituras();

      final r = await salida(1001);

      expect(_fallo(r), isA<BusinessRuleFailure>());
      expect(_fallo(r)!.message, contains('efectivo'));
      expect(await escrituras(), antes);
    });

    test('una salida por TODO el efectivo es válida (queda en cero)', () async {
      await f.abrirCaja(const Money(1000));

      final r = await salida(1000);

      expect(r.isOk, isTrue);
      final sesion = (await repo.watchSesionActual().first)!;
      expect(sesion.montoActual, Money.zero);
    });

    test('el tope considera los movimientos previos del turno', () async {
      await f.abrirCaja(const Money(10000));

      expect((await salida(6000)).isOk, isTrue);
      final r = await salida(5000); // solo quedan 4000

      expect(_fallo(r), isA<BusinessRuleFailure>());
      final sesion = (await repo.watchSesionActual().first)!;
      expect(sesion.montoActual, const Money(4000));
    });

    test('una venta en efectivo sí cuenta como efectivo disponible', () async {
      await f.abrirCaja(Money.zero);
      await f.vender(cantidad: 2); // 30000 en efectivo

      expect((await salida(30000)).isOk, isTrue);
    });

    test('sin caja abierta falla (RN-01) y no escribe nada', () async {
      final antes = await escrituras();

      final r = await entrada(1000);

      final fallo = _fallo(r);
      expect(fallo, isA<BusinessRuleFailure>());
      expect((fallo! as BusinessRuleFailure).rule, 'RN-01');
      expect(await escrituras(), antes);
    });

    test('monto cero o negativo falla sin escribir', () async {
      await f.abrirCaja(const Money(100000));
      final antes = await escrituras();

      expect(_fallo(await entrada(0)), isA<ValidationFailure>());
      expect(_fallo(await salida(0)), isA<ValidationFailure>());
      expect(_fallo(await entrada(-500)), isA<ValidationFailure>());
      expect(await escrituras(), antes);
    });

    test('motivo vacío, en blanco o de más de 120 caracteres falla', () async {
      await f.abrirCaja(const Money(100000));
      final antes = await escrituras();

      expect(_fallo(await entrada(1000, '')), isA<ValidationFailure>());
      expect(_fallo(await entrada(1000, '   ')), isA<ValidationFailure>());
      expect(_fallo(await entrada(1000, 'x' * 121)), isA<ValidationFailure>());
      expect(await escrituras(), antes);

      // El límite exacto (120) sí es válido.
      expect((await entrada(1000, 'x' * 120)).isOk, isTrue);
    });

    test(
      'deja auditoría del movimiento y lo encola para sincronizar',
      () async {
        await f.abrirCaja(const Money(100000));
        final movimientosAntes = await f.cantidadEn('caja_movimientos');
        final auditoriaAntes = await f.cantidadEn('auditoria');
        final colaAntes = await f.db.select(f.db.syncQueue).get();

        await salida(3000, 'Delivery');

        final movimiento =
            (await f.db.select(f.db.cajaMovimientos).get()).single;
        expect(await f.cantidadEn('caja_movimientos'), movimientosAntes + 1);
        expect(movimiento.usuarioId, f.usuarioId);

        final auditoria = await (f.db.select(
          f.db.auditoria,
        )..where((t) => t.accion.equals('salida_manual'))).get();
        expect(await f.cantidadEn('auditoria'), auditoriaAntes + 1);
        expect(auditoria, hasLength(1));
        expect(auditoria.single.modulo, 'caja');
        expect(auditoria.single.usuarioId, f.usuarioId);
        expect(auditoria.single.entidadId, movimiento.id);
        expect(auditoria.single.datosDespues, contains('Delivery'));
        expect(auditoria.single.datosDespues, contains('3000'));

        final cola = await f.db.select(f.db.syncQueue).get();
        final nuevas = cola.length - colaAntes.length;
        expect(nuevas, 2); // el movimiento y su auditoría
        expect(
          cola.where(
            (c) =>
                c.tabla == 'caja_movimientos' && c.registroId == movimiento.id,
          ),
          hasLength(1),
        );
        expect(
          cola.where(
            (c) =>
                c.tabla == 'auditoria' && c.registroId == auditoria.single.id,
          ),
          hasLength(1),
        );
      },
    );

    test('una entrada audita como "entrada_manual"', () async {
      await f.abrirCaja(const Money(100000));

      await entrada(2000, 'Cambio');

      final auditoria = await (f.db.select(
        f.db.auditoria,
      )..where((t) => t.accion.equals('entrada_manual'))).get();
      expect(auditoria, hasLength(1));
    });

    test('el Cajero también puede registrar movimientos (queda en su '
        'nombre)', () async {
      final negocio = await f.db.select(f.db.negocios).getSingle();
      final cajeroId = generateUuidV4();
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
      await f.abrirCaja(const Money(100000));

      final r = await repo.registrarMovimientoManual(
        entrada: false,
        monto: const Money(1500),
        motivo: 'Servicio',
        usuarioId: cajeroId,
      );

      expect(r.isOk, isTrue);
      final movimiento = (await f.db.select(f.db.cajaMovimientos).get()).single;
      expect(movimiento.usuarioId, cajeroId);
    });
  });

  group('watchSesionActual en vivo', () {
    test('se re-emite cuando entra un movimiento a la sesión abierta '
        '(la lista de la pestaña Caja no queda desactualizada)', () async {
      await f.abrirCaja(const Money(100000));

      final siguiente = repo
          .watchSesionActual()
          .firstWhere((s) => s != null && s.movimientos.isNotEmpty)
          .timeout(const Duration(seconds: 3));
      await pumpEventQueue();
      await f.vender(cantidad: 1);

      final sesion = (await siguiente)!;
      expect(sesion.movimientos.single.monto, const Money(15000));
      expect(sesion.montoActual, const Money(115000));
    });
  });
}
