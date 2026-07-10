import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/features/backup/data/datasources/backup_dao.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BackupDao dao;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = BackupDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('volcarDatos incluye todas las tablas, aunque vacías', () async {
    final datos = await dao.volcarDatos();

    final nombresTablas = {for (final t in db.allTables) t.actualTableName};
    expect(datos.keys.toSet(), nombresTablas);
    expect(datos['negocios'], isEmpty);
  });

  test(
    'restaurarDatos reemplaza por completo el contenido de las tablas',
    () async {
      final negocioId = generateUuidV4();
      await db
          .into(db.negocios)
          .insert(
            NegociosCompanion.insert(id: Value(negocioId), nombre: 'Colmado A'),
          );

      final categoriaId = generateUuidV4();
      await db
          .into(db.categorias)
          .insert(
            CategoriasCompanion.insert(
              id: Value(categoriaId),
              nombre: 'Carnes',
            ),
          );

      // Respaldo del estado actual.
      final datos = await dao.volcarDatos();

      // Modificar el estado: borrar la categoría y agregar un negocio nuevo.
      await db.delete(db.categorias).go();
      await db
          .into(db.negocios)
          .insert(
            NegociosCompanion.insert(
              id: Value(generateUuidV4()),
              nombre: 'Colmado B',
            ),
          );

      await dao.restaurarDatos(datos);

      final negocios = await db.select(db.negocios).get();
      expect(negocios, hasLength(1));
      expect(negocios.single.id, negocioId);
      expect(negocios.single.nombre, 'Colmado A');

      final categorias = await db.select(db.categorias).get();
      expect(categorias, hasLength(1));
      expect(categorias.single.id, categoriaId);
    },
  );

  test('obtenerNegocio devuelve null si no hay negocio registrado', () async {
    expect(await dao.obtenerNegocio(), isNull);
  });

  test('rutasFotosCompras y rutasFotosEmpleados ignoran rutas nulas', () async {
    final negocioId = generateUuidV4();
    await db
        .into(db.negocios)
        .insert(
          NegociosCompanion.insert(id: Value(negocioId), nombre: 'Colmado A'),
        );

    final usuarioId = generateUuidV4();
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

    await db
        .into(db.compras)
        .insert(
          ComprasCompanion.insert(
            total: 1000,
            estado: EstadoCompra.completada,
            usuarioId: usuarioId,
            fecha: DateTime.now().toUtc(),
            fotoFacturaPath: const Value('/docs/compras/factura.jpg'),
          ),
        );
    await db
        .into(db.compras)
        .insert(
          ComprasCompanion.insert(
            total: 500,
            estado: EstadoCompra.completada,
            usuarioId: usuarioId,
            fecha: DateTime.now().toUtc(),
          ),
        );

    await db
        .into(db.empleados)
        .insert(
          EmpleadosCompanion.insert(
            tipo: TipoEmpleado.ventas,
            nombre: 'Empleado 1',
            fechaIngreso: DateTime.now().toUtc(),
            fotoPath: const Value('/docs/empleados/foto.jpg'),
          ),
        );
    await db
        .into(db.empleados)
        .insert(
          EmpleadosCompanion.insert(
            tipo: TipoEmpleado.ventas,
            nombre: 'Empleado 2',
            fechaIngreso: DateTime.now().toUtc(),
          ),
        );

    expect(await dao.rutasFotosCompras(), ['/docs/compras/factura.jpg']);
    expect(await dao.rutasFotosEmpleados(), ['/docs/empleados/foto.jpg']);
  });

  test(
    'registrarRespaldo agrega entradas al historial, recientes primero',
    () async {
      await dao.registrarRespaldo(
        tipo: TipoRespaldo.manual,
        archivo: 'respaldo_1.zip',
        tamanoBytes: 100,
        resultado: 'ok',
      );
      await dao.registrarRespaldo(
        tipo: TipoRespaldo.manual,
        archivo: 'respaldo_2.zip',
        tamanoBytes: 200,
        resultado: 'ok',
      );

      final historial = await dao.watchHistorial().first;

      expect(historial, hasLength(2));
      expect(historial.first.archivo, 'respaldo_2.zip');
      expect(historial.last.archivo, 'respaldo_1.zip');
    },
  );
}
