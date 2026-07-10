import 'dart:convert';

import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/features/audit/data/datasources/audit_local_datasource.dart';
import 'package:app_gestion/features/audit/data/repositories/audit_repository_impl.dart';
import 'package:app_gestion/features/audit/domain/repositories/audit_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AuditRepositoryImpl repo;
  late String adminId;
  late String cajeroId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AuditRepositoryImpl(AuditLocalDatasource(db));

    final negocioId = generateUuidV4();
    await db
        .into(db.negocios)
        .insert(
          NegociosCompanion.insert(
            id: Value(negocioId),
            nombre: 'Negocio Test',
          ),
        );

    adminId = generateUuidV4();
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: Value(adminId),
            negocioId: negocioId,
            nombre: 'Admin',
            username: 'admin',
            passwordHash: 'hash',
            salt: 'salt',
            rol: RolUsuario.administrador,
          ),
        );

    cajeroId = generateUuidV4();
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: Value(cajeroId),
            negocioId: negocioId,
            nombre: 'Cajero Uno',
            username: 'cajero1',
            passwordHash: 'hash',
            salt: 'salt',
            rol: RolUsuario.cajero,
          ),
        );

    await db
        .into(db.auditoria)
        .insert(
          AuditoriaCompanion.insert(
            usuarioId: adminId,
            accion: 'crear',
            modulo: 'productos',
            entidadId: const Value('producto-1'),
            datosDespues: Value(jsonEncode({'nombre': 'Salami'})),
            fecha: Value(DateTime.utc(2026, 1, 10)),
          ),
        );
    await db
        .into(db.auditoria)
        .insert(
          AuditoriaCompanion.insert(
            usuarioId: cajeroId,
            accion: 'crear',
            modulo: 'ventas',
            entidadId: const Value('venta-1'),
            fecha: Value(DateTime.utc(2026, 1, 15)),
          ),
        );
    await db
        .into(db.auditoria)
        .insert(
          AuditoriaCompanion.insert(
            usuarioId: adminId,
            accion: 'editar',
            modulo: 'productos',
            entidadId: const Value('producto-1'),
            datosAntes: Value(jsonEncode({'precio': 100})),
            datosDespues: Value(jsonEncode({'precio': 120})),
            fecha: Value(DateTime.utc(2026, 1, 20)),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('watchRegistros', () {
    test('sin filtro devuelve todos, más reciente primero', () async {
      final registros = await repo
          .watchRegistros(const AuditoriaFiltro())
          .first;

      expect(registros, hasLength(3));
      expect(registros.first.accion, 'editar');
      expect(registros.first.modulo, 'productos');
      expect(registros.first.usuarioNombre, 'Admin');
    });

    test('filtra por módulo', () async {
      final registros = await repo
          .watchRegistros(const AuditoriaFiltro(modulo: 'ventas'))
          .first;

      expect(registros, hasLength(1));
      expect(registros.single.modulo, 'ventas');
      expect(registros.single.usuarioNombre, 'Cajero Uno');
    });

    test('filtra por acción', () async {
      final registros = await repo
          .watchRegistros(const AuditoriaFiltro(accion: 'editar'))
          .first;

      expect(registros, hasLength(1));
      expect(registros.single.datosAntes, {'precio': 100});
      expect(registros.single.datosDespues, {'precio': 120});
    });

    test('filtra por usuario', () async {
      final registros = await repo
          .watchRegistros(AuditoriaFiltro(usuarioId: cajeroId))
          .first;

      expect(registros, hasLength(1));
      expect(registros.single.modulo, 'ventas');
    });

    test('filtra por rango de fechas', () async {
      final registros = await repo
          .watchRegistros(
            AuditoriaFiltro(
              desde: DateTime.utc(2026, 1, 12),
              hasta: DateTime.utc(2026, 1, 18),
            ),
          )
          .first;

      expect(registros, hasLength(1));
      expect(registros.single.modulo, 'ventas');
    });
  });

  test('listarModulos devuelve módulos distintos ordenados', () async {
    final modulos = await repo.listarModulos();
    expect(modulos, ['productos', 'ventas']);
  });

  test('listarAcciones devuelve acciones distintas ordenadas', () async {
    final acciones = await repo.listarAcciones();
    expect(acciones, ['crear', 'editar']);
  });

  test('listarUsuarios devuelve los usuarios del negocio', () async {
    final usuarios = await repo.listarUsuarios();
    expect(usuarios.map((u) => u.nombre), containsAll(['Admin', 'Cajero Uno']));
  });
}
