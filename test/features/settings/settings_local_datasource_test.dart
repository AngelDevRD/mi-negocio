import 'dart:convert';

import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsLocalDatasource settings;
  late String usuarioId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsLocalDatasource(db);

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

  test('sin valor guardado, permitir_stock_negativo es true', () async {
    expect(await settings.permitirStockNegativo(), isTrue);
    expect(await settings.watchPermitirStockNegativo().first, isTrue);
  });

  test('guardar false y leerlo; volver a true', () async {
    await settings.establecerPermitirStockNegativo(false, usuarioId: usuarioId);
    expect(await settings.permitirStockNegativo(), isFalse);

    final filas = await db.select(db.configuraciones).get();
    expect(filas, hasLength(1));
    expect(filas.single.clave, 'permitir_stock_negativo');
    expect(filas.single.valor, 'false');

    await settings.establecerPermitirStockNegativo(true, usuarioId: usuarioId);
    expect(await settings.permitirStockNegativo(), isTrue);
    // Sigue siendo una sola fila (upsert por clave).
    expect(await db.select(db.configuraciones).get(), hasLength(1));
  });

  test('el stream emite los cambios', () async {
    final emitidos = <bool>[];
    final sub = settings.watchPermitirStockNegativo().listen(emitidos.add);
    addTearDown(sub.cancel);

    await settings.establecerPermitirStockNegativo(false, usuarioId: usuarioId);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(emitidos, [true, false]);
  });

  test(
    'registra auditoría con usuario, acción, módulo y antes/después',
    () async {
      await settings.establecerPermitirStockNegativo(
        false,
        usuarioId: usuarioId,
      );

      final registros = await db.select(db.auditoria).get();
      expect(registros, hasLength(1));
      final registro = registros.single;
      expect(registro.usuarioId, usuarioId);
      expect(registro.accion, 'actualizar');
      expect(registro.modulo, 'configuracion');
      expect(registro.entidadId, 'permitir_stock_negativo');
      expect(jsonDecode(registro.datosAntes!), {
        'permitir_stock_negativo': true,
      });
      expect(jsonDecode(registro.datosDespues!), {
        'permitir_stock_negativo': false,
      });
    },
  );

  test(
    'las configuraciones no se encolan para sync (no hay payload)',
    () async {
      await settings.establecerPermitirStockNegativo(
        false,
        usuarioId: usuarioId,
      );

      expect(await db.select(db.syncQueue).get(), isEmpty);
    },
  );
}
