import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/expenses/data/datasources/expenses_local_datasource.dart';
import 'package:app_gestion/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:app_gestion/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ExpensesRepositoryImpl repo;
  late SalesRepositoryImpl salesRepo;
  late String usuarioId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ExpensesRepositoryImpl(ExpensesLocalDatasource(db));
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
  });

  tearDown(() async {
    await db.close();
  });

  group('registrarGasto', () {
    test('falla si la categoría está vacía', () async {
      final result = await repo.registrarGasto(
        categoria: '  ',
        concepto: 'Factura de luz',
        fecha: DateTime.now().toUtc(),
        monto: const Money(50000),
        saleDeCaja: false,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si el concepto está vacío', () async {
      final result = await repo.registrarGasto(
        categoria: 'Luz',
        concepto: '   ',
        fecha: DateTime.now().toUtc(),
        monto: const Money(50000),
        saleDeCaja: false,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si el monto no es mayor que cero', () async {
      final result = await repo.registrarGasto(
        categoria: 'Luz',
        concepto: 'Factura de luz',
        fecha: DateTime.now().toUtc(),
        monto: const Money(0),
        saleDeCaja: false,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test(
      'falla si "sale de caja" está marcado pero no hay caja abierta',
      () async {
        final result = await repo.registrarGasto(
          categoria: 'Luz',
          concepto: 'Factura de luz',
          fecha: DateTime.now().toUtc(),
          monto: const Money(50000),
          saleDeCaja: true,
          usuarioId: usuarioId,
        );
        expect(result.isOk, isFalse);
        result.when(
          ok: (_) => fail('no debería tener éxito'),
          fail: (f) => expect(f, isA<ValidationFailure>()),
        );
      },
    );

    test('registra un gasto sin afectar la caja', () async {
      final result = await repo.registrarGasto(
        categoria: 'Alquiler',
        concepto: 'Alquiler del local',
        fecha: DateTime.now().toUtc(),
        monto: const Money(1500000),
        saleDeCaja: false,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final gastos = await repo.watchGastos().first;
      expect(gastos, hasLength(1));
      expect(gastos.single.categoria, 'Alquiler');
      expect(gastos.single.concepto, 'Alquiler del local');
      expect(gastos.single.monto, const Money(1500000));
      expect(gastos.single.saleDeCaja, isFalse);
      expect(gastos.single.usuarioNombre, 'Admin');
    });

    test('registra un gasto con salida de caja', () async {
      await salesRepo.abrirCaja(
        montoApertura: const Money(50000),
        usuarioId: usuarioId,
      );

      final result = await repo.registrarGasto(
        categoria: 'Transporte',
        concepto: 'Combustible',
        fecha: DateTime.now().toUtc(),
        monto: const Money(2000),
        saleDeCaja: true,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final gastos = await repo.watchGastos().first;
      expect(gastos.single.saleDeCaja, isTrue);

      final movimientos = await (db.select(
        db.cajaMovimientos,
      )..where((t) => t.tipo.equalsValue(TipoCajaMovimiento.gasto))).get();
      expect(movimientos, hasLength(1));
      expect(movimientos.single.monto, -2000);
    });
  });

  group('watchGastos', () {
    setUp(() async {
      await repo.registrarGasto(
        categoria: 'Luz',
        concepto: 'Factura de luz de mayo',
        fecha: DateTime.utc(2026, 5, 10),
        monto: const Money(80000),
        saleDeCaja: false,
        usuarioId: usuarioId,
      );
      await repo.registrarGasto(
        categoria: 'Agua',
        concepto: 'Factura de agua de junio',
        fecha: DateTime.utc(2026, 6, 5),
        monto: const Money(30000),
        saleDeCaja: false,
        usuarioId: usuarioId,
      );
    });

    test('filtra por rango de fechas', () async {
      final gastos = await repo
          .watchGastos(
            desde: DateTime.utc(2026, 6),
            hasta: DateTime.utc(2026, 6, 30),
          )
          .first;
      expect(gastos, hasLength(1));
      expect(gastos.single.categoria, 'Agua');
    });

    test('filtra por categoría', () async {
      final gastos = await repo.watchGastos(categoria: 'Luz').first;
      expect(gastos, hasLength(1));
      expect(gastos.single.concepto, 'Factura de luz de mayo');
    });

    test('sin filtros retorna todos, más reciente primero', () async {
      final gastos = await repo.watchGastos().first;
      expect(gastos, hasLength(2));
      expect(gastos.first.categoria, 'Agua');
      expect(gastos.last.categoria, 'Luz');
    });
  });
}
