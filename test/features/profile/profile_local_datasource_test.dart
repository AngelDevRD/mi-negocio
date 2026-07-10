import 'dart:convert';

import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProfileLocalDatasource datasource;
  late String negocioId;
  late String usuarioId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = ProfileLocalDatasource(db);

    negocioId = generateUuidV4();
    await db
        .into(db.negocios)
        .insert(
          NegociosCompanion.insert(id: Value(negocioId), nombre: 'Colmado A'),
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

  test('watchNegocio emite el negocio registrado', () async {
    final negocio = await datasource.watchNegocio().first;
    expect(negocio, isNotNull);
    expect(negocio!.id, negocioId);
    expect(negocio.nombre, 'Colmado A');
  });

  test('actualizarPerfil actualiza los datos y registra auditoría', () async {
    final actual = (await datasource.watchNegocio().first)!;

    await datasource.actualizarPerfil(
      actual: actual,
      nombre: 'Colmado El Buen Precio',
      identificacion: '001-1234567-8',
      direccion: 'Calle Principal #1',
      telefono: '809-555-0000',
      email: 'contacto@colmado.com',
      logoPath: '/data/negocio/logo.png',
      actorId: usuarioId,
    );

    final actualizado = await datasource.watchNegocio().first;
    expect(actualizado!.nombre, 'Colmado El Buen Precio');
    expect(actualizado.identificacion, '001-1234567-8');
    expect(actualizado.direccion, 'Calle Principal #1');
    expect(actualizado.telefono, '809-555-0000');
    expect(actualizado.email, 'contacto@colmado.com');
    expect(actualizado.logoPath, '/data/negocio/logo.png');

    final auditoria = await db.select(db.auditoria).get();
    expect(auditoria, hasLength(1));
    expect(auditoria.single.modulo, 'perfil');
    expect(auditoria.single.accion, 'actualizar');
    expect(auditoria.single.usuarioId, usuarioId);
    expect(auditoria.single.entidadId, negocioId);

    final datosAntes =
        jsonDecode(auditoria.single.datosAntes!) as Map<String, dynamic>;
    expect(datosAntes['nombre'], 'Colmado A');

    final datosDespues =
        jsonDecode(auditoria.single.datosDespues!) as Map<String, dynamic>;
    expect(datosDespues['nombre'], 'Colmado El Buen Precio');
  });
}
