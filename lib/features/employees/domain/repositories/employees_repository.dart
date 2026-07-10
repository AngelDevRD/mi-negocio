import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../entities/empleado.dart';
import '../entities/pago_empleado.dart';

/// Operaciones de empleados de ventas y delivery, y sus pagos (RF-EMP).
abstract interface class EmployeesRepository {
  /// Empleados, más reciente primero. `tipo` filtra por sección
  /// (ventas/delivery) y `activo` por estado (`null` = todos).
  Stream<List<Empleado>> watchEmpleados({TipoEmpleado? tipo, bool? activo});

  Future<Empleado?> obtenerEmpleado(String id);

  /// Crea la ficha del empleado (RF-EMP-02). Valida nombre obligatorio y, si
  /// se indica, el formato de cédula RD 000-0000000-0.
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
  });

  /// Actualiza la ficha del empleado, con las mismas validaciones.
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
  });

  /// Activa/desactiva al empleado (soft delete, RN-13: conserva historial).
  Future<Result<void>> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  });

  /// Pagos del empleado, más reciente primero.
  Stream<List<PagoEmpleado>> watchPagos(String empleadoId);

  /// Total pagado acumulado al empleado (RF-EMP-04).
  Stream<Money> watchTotalPagado(String empleadoId);

  /// Registra un pago (RF-EMP-03). Si [saleDeCaja] es `true`, requiere una
  /// sesión de caja abierta y registra la salida en `caja_movimientos`.
  Future<Result<String>> registrarPago({
    required String empleadoId,
    required DateTime fecha,
    required Money monto,
    String? periodo,
    required bool saleDeCaja,
    required String usuarioId,
  });
}
