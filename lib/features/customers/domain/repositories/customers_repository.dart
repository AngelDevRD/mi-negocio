import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../entities/cliente.dart';

/// Clientes con fiado y su libro de cuenta.
abstract interface class CustomersRepository {
  /// Clientes por nombre con su saldo calculado. [busqueda] filtra por nombre
  /// o teléfono; [activo] por estado (`null` = todos).
  Stream<List<Cliente>> watchClientes({String busqueda = '', bool? activo});

  Future<Cliente?> obtenerCliente(String id);

  /// Historial de movimientos del cliente, más reciente primero.
  Stream<List<MovimientoCliente>> watchMovimientos(String clienteId);

  /// Crea un cliente. Nombre obligatorio (máx. 120); el límite de crédito, si
  /// se indica, no puede ser negativo (`null` = sin límite).
  Future<Result<String>> crearCliente({
    required String nombre,
    String? telefono,
    String? nota,
    Money? limiteCredito,
    required String usuarioId,
  });

  Future<Result<void>> actualizarCliente({
    required String id,
    required String nombre,
    String? telefono,
    String? nota,
    Money? limiteCredito,
    required String usuarioId,
  });

  /// Activa/desactiva al cliente (un inactivo no puede recibir más fiado,
  /// pero conserva su historial y puede seguir abonando).
  Future<Result<void>> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  });

  /// Elimina al cliente SOLO si no tiene movimientos; si los tiene, falla y
  /// hay que desactivarlo.
  Future<Result<void>> eliminarCliente(String id, {required String usuarioId});

  /// Registra un abono (una sola transacción). Reglas: monto > 0; el método
  /// no puede ser `credito`; no puede superar el saldo pendiente; en efectivo
  /// exige caja abierta (RN-01) y entra a la caja.
  Future<Result<String>> registrarAbono({
    required String clienteId,
    required Money monto,
    required MetodoPago metodo,
    required String usuarioId,
    String? nota,
  });
}
