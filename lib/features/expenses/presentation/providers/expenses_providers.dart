import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' hide Gasto;
import '../../../../core/utils/fechas.dart';
import '../../data/datasources/expenses_local_datasource.dart';
import '../../data/repositories/expenses_repository_impl.dart';
import '../../domain/entities/gasto.dart';
import '../../domain/repositories/expenses_repository.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepositoryImpl(
    ExpensesLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

/// Filtros activos de la lista de gastos: mes (RF-GAS-03) y categoría.
///
/// [mes] es el mes calendario LOCAL seleccionado (solo importan año/mes; se
/// guarda como DateTime local, no UTC). [inicioMes]/[finMes] son los
/// instantes UTC correspondientes, listos para comparar contra `fecha`.
class GastosFiltro {
  GastosFiltro({DateTime? mes, this.categoria}) : mes = mes ?? DateTime.now();

  final DateTime mes;
  final String? categoria;

  DateTime get inicioMes => inicioDelMesLocal(mes);

  /// El datasource compara con `<=` (no `<`), así que se sigue restando 1ms
  /// al inicio del mes siguiente en vez de cambiar su contrato público.
  DateTime get finMes => inicioDelMesSiguienteLocal(
    mes,
  ).subtract(const Duration(milliseconds: 1));

  GastosFiltro copyWith({DateTime? mes, Object? categoria = _sinCambio}) {
    return GastosFiltro(
      mes: mes ?? this.mes,
      categoria: categoria == _sinCambio
          ? this.categoria
          : categoria as String?,
    );
  }

  static const _sinCambio = Object();
}

final gastosFiltroProvider =
    NotifierProvider<GastosFiltroController, GastosFiltro>(
      GastosFiltroController.new,
    );

class GastosFiltroController extends Notifier<GastosFiltro> {
  @override
  GastosFiltro build() => GastosFiltro();

  void actualizar(GastosFiltro Function(GastosFiltro actual) update) {
    state = update(state);
  }
}

/// Gastos del mes/categoría filtrados, más reciente primero.
final gastosProvider = StreamProvider<List<Gasto>>((ref) {
  final filtro = ref.watch(gastosFiltroProvider);
  return ref
      .watch(expensesRepositoryProvider)
      .watchGastos(
        desde: filtro.inicioMes,
        hasta: filtro.finMes,
        categoria: filtro.categoria,
      );
});
