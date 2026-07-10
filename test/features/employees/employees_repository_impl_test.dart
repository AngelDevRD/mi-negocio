import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/employees/data/datasources/employees_local_datasource.dart';
import 'package:app_gestion/features/employees/data/repositories/employees_repository_impl.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:app_gestion/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late EmployeesRepositoryImpl repo;
  late SalesRepositoryImpl salesRepo;
  late String usuarioId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = EmployeesRepositoryImpl(EmployeesLocalDatasource(db));
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

  group('crearEmpleado', () {
    test('falla si el nombre está vacío', () async {
      final result = await repo.crearEmpleado(
        tipo: TipoEmpleado.ventas,
        nombre: '   ',
        fechaIngreso: DateTime.utc(2025, 1, 1),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si la cédula tiene formato inválido', () async {
      final result = await repo.crearEmpleado(
        tipo: TipoEmpleado.ventas,
        nombre: 'Juan Pérez',
        cedula: '12345',
        fechaIngreso: DateTime.utc(2025, 1, 1),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('crea un empleado de delivery con cédula válida', () async {
      final result = await repo.crearEmpleado(
        tipo: TipoEmpleado.delivery,
        nombre: 'Pedro Gómez',
        cedula: '001-1234567-8',
        fechaIngreso: DateTime.utc(2025, 1, 1),
        salario: const Money(1000000),
        frecuenciaPago: 'Quincenal',
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final empleados = await repo.watchEmpleados().first;
      expect(empleados, hasLength(1));
      expect(empleados.single.tipo, TipoEmpleado.delivery);
      expect(empleados.single.cedula, '001-1234567-8');
      expect(empleados.single.salario, const Money(1000000));
      expect(empleados.single.activo, isTrue);
    });
  });

  group('watchEmpleados', () {
    setUp(() async {
      await repo.crearEmpleado(
        tipo: TipoEmpleado.ventas,
        nombre: 'Empleado Ventas',
        fechaIngreso: DateTime.utc(2025, 1, 1),
        usuarioId: usuarioId,
      );
      await repo.crearEmpleado(
        tipo: TipoEmpleado.delivery,
        nombre: 'Empleado Delivery',
        fechaIngreso: DateTime.utc(2025, 1, 1),
        usuarioId: usuarioId,
      );
    });

    test('filtra por tipo', () async {
      final ventas = await repo.watchEmpleados(tipo: TipoEmpleado.ventas).first;
      expect(ventas, hasLength(1));
      expect(ventas.single.nombre, 'Empleado Ventas');

      final delivery = await repo
          .watchEmpleados(tipo: TipoEmpleado.delivery)
          .first;
      expect(delivery, hasLength(1));
      expect(delivery.single.nombre, 'Empleado Delivery');
    });

    test('filtra por estado activo', () async {
      final empleados = await repo.watchEmpleados().first;
      final id = empleados.first.id;

      await repo.establecerActivo(id: id, activo: false, usuarioId: usuarioId);

      final activos = await repo.watchEmpleados(activo: true).first;
      final inactivos = await repo.watchEmpleados(activo: false).first;
      expect(activos, hasLength(1));
      expect(inactivos, hasLength(1));
    });
  });

  group('actualizarEmpleado', () {
    test('actualiza la ficha del empleado', () async {
      final result = await repo.crearEmpleado(
        tipo: TipoEmpleado.ventas,
        nombre: 'Original',
        fechaIngreso: DateTime.utc(2025, 1, 1),
        usuarioId: usuarioId,
      );
      final id = (result as Ok<String>).value;

      final actualizado = await repo.actualizarEmpleado(
        id: id,
        tipo: TipoEmpleado.ventas,
        nombre: 'Actualizado',
        fechaIngreso: DateTime.utc(2025, 1, 1),
        salario: const Money(2000000),
        usuarioId: usuarioId,
      );
      expect(actualizado.isOk, isTrue);

      final empleado = await repo.obtenerEmpleado(id);
      expect(empleado!.nombre, 'Actualizado');
      expect(empleado.salario, const Money(2000000));
    });
  });

  group('registrarPago', () {
    late String empleadoId;

    setUp(() async {
      final result = await repo.crearEmpleado(
        tipo: TipoEmpleado.ventas,
        nombre: 'Empleado',
        fechaIngreso: DateTime.utc(2024, 1, 1),
        salario: const Money(1000000),
        usuarioId: usuarioId,
      );
      empleadoId = (result as Ok<String>).value;
    });

    test('falla si el monto no es mayor que cero', () async {
      final result = await repo.registrarPago(
        empleadoId: empleadoId,
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
        final result = await repo.registrarPago(
          empleadoId: empleadoId,
          fecha: DateTime.now().toUtc(),
          monto: const Money(1000000),
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

    test('registra un pago sin afectar la caja', () async {
      final result = await repo.registrarPago(
        empleadoId: empleadoId,
        fecha: DateTime.utc(2026, 6, 15),
        monto: const Money(500000),
        periodo: '1-15 junio 2026',
        saleDeCaja: false,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final pagos = await repo.watchPagos(empleadoId).first;
      expect(pagos, hasLength(1));
      expect(pagos.single.monto, const Money(500000));
      expect(pagos.single.periodo, '1-15 junio 2026');
      expect(pagos.single.saleDeCaja, isFalse);
      expect(pagos.single.usuarioNombre, 'Admin');

      final total = await repo.watchTotalPagado(empleadoId).first;
      expect(total, const Money(500000));
    });

    test('registra un pago con salida de caja', () async {
      await salesRepo.abrirCaja(
        montoApertura: const Money(50000),
        usuarioId: usuarioId,
      );

      final result = await repo.registrarPago(
        empleadoId: empleadoId,
        fecha: DateTime.utc(2026, 6, 15),
        monto: const Money(500000),
        periodo: '1-15 junio 2026',
        saleDeCaja: true,
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final pagos = await repo.watchPagos(empleadoId).first;
      expect(pagos.single.saleDeCaja, isTrue);

      final movimientos =
          await (db.select(db.cajaMovimientos)..where(
                (t) => t.tipo.equalsValue(TipoCajaMovimiento.pagoEmpleado),
              ))
              .get();
      expect(movimientos, hasLength(1));
      expect(movimientos.single.monto, -500000);
    });

    test('acumula el total pagado tras varios pagos', () async {
      await repo.registrarPago(
        empleadoId: empleadoId,
        fecha: DateTime.utc(2026, 5, 31),
        monto: const Money(500000),
        periodo: '16-31 mayo 2026',
        saleDeCaja: false,
        usuarioId: usuarioId,
      );
      await repo.registrarPago(
        empleadoId: empleadoId,
        fecha: DateTime.utc(2026, 6, 15),
        monto: const Money(500000),
        periodo: '1-15 junio 2026',
        saleDeCaja: false,
        usuarioId: usuarioId,
      );

      final total = await repo.watchTotalPagado(empleadoId).first;
      expect(total, const Money(1000000));

      final pagos = await repo.watchPagos(empleadoId).first;
      expect(pagos, hasLength(2));
      expect(pagos.first.fecha, DateTime.utc(2026, 6, 15));
    });
  });
}
