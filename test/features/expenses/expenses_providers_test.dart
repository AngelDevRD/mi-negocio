import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/utils/fechas.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/expenses/data/datasources/expenses_local_datasource.dart';
import 'package:app_gestion/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:app_gestion/features/expenses/presentation/providers/expenses_providers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GastosFiltro', () {
    test('inicioMes/finMes usan el calendario LOCAL, no UTC', () {
      final filtro = GastosFiltro(mes: DateTime(2030, 3, 15));

      expect(filtro.inicioMes, inicioDelMesLocal(DateTime(2030, 3, 15)));
      // finMes = 1ms antes del inicio del mes siguiente local.
      expect(
        filtro.finMes,
        inicioDelMesSiguienteLocal(
          DateTime(2030, 3, 15),
        ).subtract(const Duration(milliseconds: 1)),
      );
    });
  });

  group('RN: gasto a las 21:00 local del último día del mes', () {
    late AppDatabase db;
    late ExpensesRepositoryImpl repo;
    late String usuarioId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ExpensesRepositoryImpl(ExpensesLocalDatasource(db));

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

    test('aparece en ESE mes y no en el siguiente', () async {
      // 31 de marzo de 2030, 21:00 hora local: último día del mes.
      final gastoFechaUtc = DateTime(2030, 3, 31, 21).toUtc();
      await repo.registrarGasto(
        categoria: 'Servicios',
        concepto: 'Luz',
        fecha: gastoFechaUtc,
        monto: const Money(1000),
        saleDeCaja: false,
        usuarioId: usuarioId,
      );

      final filtroMarzo = GastosFiltro(mes: DateTime(2030, 3, 1));
      final gastosMarzo = await repo
          .watchGastos(desde: filtroMarzo.inicioMes, hasta: filtroMarzo.finMes)
          .first;
      expect(gastosMarzo, hasLength(1));

      final filtroAbril = GastosFiltro(mes: DateTime(2030, 4, 1));
      final gastosAbril = await repo
          .watchGastos(desde: filtroAbril.inicioMes, hasta: filtroAbril.finMes)
          .first;
      expect(gastosAbril, isEmpty);
    });
  });
}
