import '../../../../core/database/app_database.dart' as db;
import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/empleado.dart';
import '../../domain/entities/pago_empleado.dart';
import '../../domain/repositories/employees_repository.dart';
import '../datasources/employees_local_datasource.dart';

/// Implementación de empleados de ventas/delivery y sus pagos (RF-EMP).
class EmployeesRepositoryImpl implements EmployeesRepository {
  EmployeesRepositoryImpl(this._local);

  final EmployeesLocalDatasource _local;

  Empleado _aEntidad(db.Empleado e) {
    return Empleado(
      id: e.id,
      tipo: e.tipo,
      fotoPath: e.fotoPath,
      nombre: e.nombre,
      cedula: e.cedula,
      direccion: e.direccion,
      telefono: e.telefono,
      fechaIngreso: e.fechaIngreso,
      activo: e.activo,
      salario: e.salario == null ? null : Money(e.salario!),
      frecuenciaPago: e.frecuenciaPago,
    );
  }

  PagoEmpleado _pagoAEntidad((db.PagosEmpleado, String) row) {
    final (pago, usuarioNombre) = row;
    return PagoEmpleado(
      id: pago.id,
      fecha: pago.fecha,
      monto: Money(pago.monto),
      periodo: pago.periodo,
      saleDeCaja: pago.cajaSesionId != null,
      usuarioNombre: usuarioNombre,
    );
  }

  /// Valida nombre obligatorio y, si se indica, el formato de cédula RD.
  ValidationFailure? _validarFicha({
    required String nombre,
    required String? cedula,
  }) {
    if (nombre.trim().isEmpty) {
      return const ValidationFailure('El nombre es obligatorio.');
    }
    if (cedula != null &&
        cedula.trim().isNotEmpty &&
        !formatoCedulaRD.hasMatch(cedula.trim())) {
      return const ValidationFailure(
        'La cédula debe tener el formato 000-0000000-0.',
      );
    }
    return null;
  }

  @override
  Stream<List<Empleado>> watchEmpleados({TipoEmpleado? tipo, bool? activo}) {
    return _local
        .watchEmpleados(tipo: tipo, activo: activo)
        .map((rows) => rows.map(_aEntidad).toList());
  }

  @override
  Future<Empleado?> obtenerEmpleado(String id) async {
    final empleado = await _local.obtenerEmpleado(id);
    return empleado == null ? null : _aEntidad(empleado);
  }

  @override
  Future<Result<String>> crearEmpleado({
    required TipoEmpleado tipo,
    String? fotoPath,
    required String nombre,
    String? cedula,
    String? direccion,
    String? telefono,
    required DateTime fechaIngreso,
    Money? salario,
    String? frecuenciaPago,
    required String usuarioId,
  }) async {
    final nombreLimpio = nombre.trim();
    final fallo = _validarFicha(nombre: nombreLimpio, cedula: cedula);
    if (fallo != null) return Result.fail(fallo);

    final id = await _local.crearEmpleado(
      tipo: tipo,
      fotoPath: fotoPath,
      nombre: nombreLimpio,
      cedula: cedula?.trim(),
      direccion: direccion?.trim(),
      telefono: telefono?.trim(),
      fechaIngreso: fechaIngreso,
      salarioCents: salario?.cents,
      frecuenciaPago: frecuenciaPago,
      usuarioId: usuarioId,
    );
    return Result.ok(id);
  }

  @override
  Future<Result<void>> actualizarEmpleado({
    required String id,
    required TipoEmpleado tipo,
    String? fotoPath,
    required String nombre,
    String? cedula,
    String? direccion,
    String? telefono,
    required DateTime fechaIngreso,
    Money? salario,
    String? frecuenciaPago,
    required String usuarioId,
  }) async {
    final nombreLimpio = nombre.trim();
    final fallo = _validarFicha(nombre: nombreLimpio, cedula: cedula);
    if (fallo != null) return Result.fail(fallo);

    await _local.actualizarEmpleado(
      id: id,
      tipo: tipo,
      fotoPath: fotoPath,
      nombre: nombreLimpio,
      cedula: cedula?.trim(),
      direccion: direccion?.trim(),
      telefono: telefono?.trim(),
      fechaIngreso: fechaIngreso,
      salarioCents: salario?.cents,
      frecuenciaPago: frecuenciaPago,
      usuarioId: usuarioId,
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  }) async {
    await _local.establecerActivo(id: id, activo: activo, usuarioId: usuarioId);
    return const Result.ok(null);
  }

  @override
  Stream<List<PagoEmpleado>> watchPagos(String empleadoId) {
    return _local
        .watchPagos(empleadoId)
        .map((rows) => rows.map(_pagoAEntidad).toList());
  }

  @override
  Stream<Money> watchTotalPagado(String empleadoId) {
    return _local.watchTotalPagadoCents(empleadoId).map(Money.new);
  }

  @override
  Future<Result<String>> registrarPago({
    required String empleadoId,
    required DateTime fecha,
    required Money monto,
    String? periodo,
    required bool saleDeCaja,
    required String usuarioId,
  }) async {
    if (monto.cents <= 0) {
      return const Result.fail(
        ValidationFailure('El monto debe ser mayor que cero.'),
      );
    }

    String? cajaSesionId;
    if (saleDeCaja) {
      cajaSesionId = await _local.obtenerCajaAbiertaId();
      if (cajaSesionId == null) {
        return const Result.fail(
          ValidationFailure(
            'No hay una sesión de caja abierta para registrar la salida.',
          ),
        );
      }
    }

    final id = await _local.registrarPago(
      empleadoId: empleadoId,
      fecha: fecha,
      montoCents: monto.cents,
      periodo: periodo?.trim(),
      cajaSesionId: cajaSesionId,
      usuarioId: usuarioId,
    );
    return Result.ok(id);
  }
}
