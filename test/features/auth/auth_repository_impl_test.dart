import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_gestion/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AuthRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AuthRepositoryImpl(AuthLocalDatasource(db));
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> registrarNegocioYAdmin({
    String username = 'admin',
    String password = 'admin123',
  }) async {
    final result = await repo.registrarNegocioYAdmin(
      nombreNegocio: 'Colmado Pérez',
      nombreAdmin: 'Juan Pérez',
      username: username,
      password: password,
    );
    expect(result.isOk, isTrue);
    return result.valueOrNull!.id;
  }

  group('registrarNegocioYAdmin', () {
    test('registra negocio y crea administrador', () async {
      final result = await repo.registrarNegocioYAdmin(
        nombreNegocio: 'Colmado Pérez',
        nombreAdmin: 'Juan Pérez',
        username: 'admin',
        password: 'admin123',
      );

      expect(result.isOk, isTrue);
      final usuario = result.valueOrNull!;
      expect(usuario.username, 'admin');
      expect(usuario.esAdministrador, isTrue);
      expect(usuario.activo, isTrue);
      expect(await repo.hayNegocioRegistrado(), isTrue);
    });

    test('falla si ya existe un negocio registrado', () async {
      await registrarNegocioYAdmin();

      final result = await repo.registrarNegocioYAdmin(
        nombreNegocio: 'Otro negocio',
        nombreAdmin: 'Otra persona',
        username: 'otro',
        password: 'otro1234',
      );

      expect(result.isOk, isFalse);
      expect(result.valueOrNull, isNull);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<BusinessRuleFailure>()),
      );
    });

    test('falla con username demasiado corto', () async {
      final result = await repo.registrarNegocioYAdmin(
        nombreNegocio: 'Colmado Pérez',
        nombreAdmin: 'Juan Pérez',
        username: 'ab',
        password: 'admin123',
      );

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });

    test('falla con password demasiado corta', () async {
      final result = await repo.registrarNegocioYAdmin(
        nombreNegocio: 'Colmado Pérez',
        nombreAdmin: 'Juan Pérez',
        username: 'admin',
        password: '123',
      );

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });
  });

  group('login', () {
    test('login exitoso con credenciales correctas', () async {
      await registrarNegocioYAdmin(username: 'admin', password: 'admin123');

      final result = await repo.login(username: 'admin', password: 'admin123');

      expect(result.isOk, isTrue);
      expect(result.valueOrNull!.username, 'admin');
    });

    test('login es case-insensitive en el username', () async {
      await registrarNegocioYAdmin(username: 'admin', password: 'admin123');

      final result = await repo.login(username: 'ADMIN', password: 'admin123');

      expect(result.isOk, isTrue);
    });

    test('falla con contraseña incorrecta', () async {
      await registrarNegocioYAdmin(username: 'admin', password: 'admin123');

      final result = await repo.login(
        username: 'admin',
        password: 'incorrecta',
      );

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });

    test('falla con usuario inexistente', () async {
      await registrarNegocioYAdmin();

      final result = await repo.login(
        username: 'noexiste',
        password: 'admin123',
      );

      expect(result.isOk, isFalse);
    });

    test('falla si el usuario está inactivo', () async {
      final adminId = await registrarNegocioYAdmin(
        username: 'admin',
        password: 'admin123',
      );
      final cajero = await repo.crearCajero(
        nombre: 'Cajero Uno',
        username: 'cajero1',
        password: 'cajero123',
        actorId: adminId,
      );
      await repo.establecerActivo(
        usuarioId: cajero.valueOrNull!.id,
        activo: false,
        actorId: adminId,
      );

      final result = await repo.login(
        username: 'cajero1',
        password: 'cajero123',
      );

      expect(result.isOk, isFalse);
    });
  });

  group('crearCajero', () {
    test('crea cajero con rol correcto', () async {
      final adminId = await registrarNegocioYAdmin();

      final result = await repo.crearCajero(
        nombre: 'Cajero Uno',
        username: 'cajero1',
        password: 'cajero123',
        actorId: adminId,
      );

      expect(result.isOk, isTrue);
      final cajero = result.valueOrNull!;
      expect(cajero.esAdministrador, isFalse);
      expect(cajero.activo, isTrue);
    });

    test('falla si el username ya existe', () async {
      final adminId = await registrarNegocioYAdmin(username: 'admin');

      final result = await repo.crearCajero(
        nombre: 'Otro',
        username: 'admin',
        password: 'cajero123',
        actorId: adminId,
      );

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });
  });

  group('resetearPassword', () {
    test('permite iniciar sesión con la nueva contraseña', () async {
      final adminId = await registrarNegocioYAdmin(
        username: 'admin',
        password: 'admin123',
      );
      final cajero = await repo.crearCajero(
        nombre: 'Cajero Uno',
        username: 'cajero1',
        password: 'cajero123',
        actorId: adminId,
      );

      final reset = await repo.resetearPassword(
        usuarioId: cajero.valueOrNull!.id,
        nuevaPassword: 'nuevaClave',
        actorId: adminId,
      );
      expect(reset.isOk, isTrue);

      final loginViejo = await repo.login(
        username: 'cajero1',
        password: 'cajero123',
      );
      expect(loginViejo.isOk, isFalse);

      final loginNuevo = await repo.login(
        username: 'cajero1',
        password: 'nuevaClave',
      );
      expect(loginNuevo.isOk, isTrue);
    });
  });

  group('cambiarPassword', () {
    test('falla si la contraseña actual es incorrecta', () async {
      await registrarNegocioYAdmin(username: 'admin', password: 'admin123');
      final usuario = (await repo.login(
        username: 'admin',
        password: 'admin123',
      )).valueOrNull!;

      final result = await repo.cambiarPassword(
        usuarioId: usuario.id,
        actual: 'incorrecta',
        nueva: 'nuevaClave123',
      );

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<ValidationFailure>()),
      );
    });

    test('cambia la contraseña con la actual correcta', () async {
      await registrarNegocioYAdmin(username: 'admin', password: 'admin123');
      final usuario = (await repo.login(
        username: 'admin',
        password: 'admin123',
      )).valueOrNull!;

      final result = await repo.cambiarPassword(
        usuarioId: usuario.id,
        actual: 'admin123',
        nueva: 'nuevaClave123',
      );
      expect(result.isOk, isTrue);

      final login = await repo.login(
        username: 'admin',
        password: 'nuevaClave123',
      );
      expect(login.isOk, isTrue);
    });
  });

  group('establecerActivo', () {
    test('no permite desactivar al único administrador', () async {
      final adminId = await registrarNegocioYAdmin();
      final usuarios = await repo.listarUsuarios();
      final admin = usuarios.first;

      final result = await repo.establecerActivo(
        usuarioId: admin.id,
        activo: false,
        actorId: adminId,
      );

      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (failure) => expect(failure, isA<BusinessRuleFailure>()),
      );
    });

    test('permite desactivar un cajero', () async {
      final adminId = await registrarNegocioYAdmin();
      final cajero = await repo.crearCajero(
        nombre: 'Cajero Uno',
        username: 'cajero1',
        password: 'cajero123',
        actorId: adminId,
      );

      final result = await repo.establecerActivo(
        usuarioId: cajero.valueOrNull!.id,
        activo: false,
        actorId: adminId,
      );

      expect(result.isOk, isTrue);
      final usuarios = await repo.listarUsuarios();
      final actualizado = usuarios.firstWhere(
        (u) => u.id == cajero.valueOrNull!.id,
      );
      expect(actualizado.activo, isFalse);
    });
  });

  group('auditoría (RF-AUD-02)', () {
    Future<List<AuditoriaData>> registros() => (db.select(
      db.auditoria,
    )..where((t) => t.modulo.equals('usuarios'))).get();

    test('crearCajero registra auditoría de creación', () async {
      final adminId = await registrarNegocioYAdmin();
      final cajero = await repo.crearCajero(
        nombre: 'Cajero Uno',
        username: 'cajero1',
        password: 'cajero123',
        actorId: adminId,
      );

      final filas = await registros();
      expect(filas, hasLength(1));
      expect(filas.first.usuarioId, adminId);
      expect(filas.first.accion, 'crear');
      expect(filas.first.entidadId, cajero.valueOrNull!.id);
    });

    test('resetearPassword y establecerActivo registran auditoría', () async {
      final adminId = await registrarNegocioYAdmin();
      final cajero = await repo.crearCajero(
        nombre: 'Cajero Uno',
        username: 'cajero1',
        password: 'cajero123',
        actorId: adminId,
      );

      await repo.resetearPassword(
        usuarioId: cajero.valueOrNull!.id,
        nuevaPassword: 'nuevaClave',
        actorId: adminId,
      );
      await repo.establecerActivo(
        usuarioId: cajero.valueOrNull!.id,
        activo: false,
        actorId: adminId,
      );

      final filas = await registros();
      final acciones = filas.map((f) => f.accion).toList();
      expect(
        acciones,
        containsAll(['crear', 'resetear_password', 'desactivar']),
      );
    });

    test('cambiarPassword registra auditoría con el propio usuario', () async {
      final adminId = await registrarNegocioYAdmin(
        username: 'admin',
        password: 'admin123',
      );

      final result = await repo.cambiarPassword(
        usuarioId: adminId,
        actual: 'admin123',
        nueva: 'nuevaClave123',
      );
      expect(result.isOk, isTrue);

      final filas = await registros();
      expect(filas, hasLength(1));
      expect(filas.first.usuarioId, adminId);
      expect(filas.first.accion, 'cambiar_password');
    });
  });
}
