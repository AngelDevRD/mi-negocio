import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../entities/gasto.dart';

/// Operaciones de gastos operativos (RF-GAS).
abstract interface class ExpensesRepository {
  /// Gastos no eliminados, más reciente primero, con filtros opcionales por
  /// rango de fechas y categoría.
  Stream<List<Gasto>> watchGastos({
    DateTime? desde,
    DateTime? hasta,
    String? categoria,
  });

  /// Registra un gasto (RF-GAS-01). Si [saleDeCaja] es `true`, requiere una
  /// sesión de caja abierta y registra la salida en `caja_movimientos`
  /// (RF-GAS-02). Devuelve el id del gasto creado.
  Future<Result<String>> registrarGasto({
    required String categoria,
    required String concepto,
    required DateTime fecha,
    required Money monto,
    required bool saleDeCaja,
    required String usuarioId,
  });
}
