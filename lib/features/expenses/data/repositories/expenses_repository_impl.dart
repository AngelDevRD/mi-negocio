import '../../../../core/database/app_database.dart' as db;
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/gasto.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_local_datasource.dart';

/// Implementación de gastos operativos (RF-GAS).
class ExpensesRepositoryImpl implements ExpensesRepository {
  ExpensesRepositoryImpl(this._local);

  final ExpensesLocalDatasource _local;

  Gasto _aEntidad((db.Gasto, String) row) {
    final (gasto, usuarioNombre) = row;
    return Gasto(
      id: gasto.id,
      categoria: gasto.categoria,
      concepto: gasto.concepto,
      fecha: gasto.fecha,
      monto: Money(gasto.monto),
      saleDeCaja: gasto.cajaSesionId != null,
      usuarioNombre: usuarioNombre,
    );
  }

  @override
  Stream<List<Gasto>> watchGastos({
    DateTime? desde,
    DateTime? hasta,
    String? categoria,
  }) {
    return _local
        .watchGastos(desde: desde, hasta: hasta, categoria: categoria)
        .map((rows) => rows.map(_aEntidad).toList());
  }

  @override
  Future<Result<String>> registrarGasto({
    required String categoria,
    required String concepto,
    required DateTime fecha,
    required Money monto,
    required bool saleDeCaja,
    required String usuarioId,
  }) async {
    final categoriaLimpia = categoria.trim();
    final conceptoLimpio = concepto.trim();
    if (categoriaLimpia.isEmpty) {
      return const Result.fail(
        ValidationFailure('La categoría es obligatoria.'),
      );
    }
    if (conceptoLimpio.isEmpty) {
      return const Result.fail(
        ValidationFailure('El concepto es obligatorio.'),
      );
    }
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

    final id = await _local.registrarGasto(
      categoria: categoriaLimpia,
      concepto: conceptoLimpio,
      fecha: fecha,
      montoCents: monto.cents,
      cajaSesionId: cajaSesionId,
      usuarioId: usuarioId,
    );
    return Result.ok(id);
  }
}
