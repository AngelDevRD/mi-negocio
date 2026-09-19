import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' hide CajaMovimiento;
import '../../../../core/utils/money.dart';
import '../../data/datasources/cash_register_local_datasource.dart';
import '../../data/repositories/cash_register_repository_impl.dart';
import '../../domain/entities/caja_sesion.dart';
import '../../domain/entities/resumen_turno.dart';
import '../../domain/repositories/cash_register_repository.dart';

final cashRegisterRepositoryProvider = Provider<CashRegisterRepository>((ref) {
  return CashRegisterRepositoryImpl(
    CashRegisterLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

/// Sesión de caja abierta (si hay), con sus movimientos en vivo.
final sesionActualProvider = StreamProvider<CajaSesion?>((ref) {
  return ref.watch(cashRegisterRepositoryProvider).watchSesionActual();
});

/// Historial de sesiones cerradas, más reciente primero.
final historialCajaProvider = StreamProvider<List<CajaSesion>>((ref) {
  return ref.watch(cashRegisterRepositoryProvider).watchHistorial();
});

/// Sesión (abierta o cerrada) por id, con sus movimientos.
final sesionCajaProvider = FutureProvider.autoDispose
    .family<CajaSesion?, String>((ref, id) {
      return ref.watch(cashRegisterRepositoryProvider).obtenerSesion(id);
    });

/// Arqueo de una sesión (ventas por método, abonos, entradas/salidas...).
/// Mira la sesión abierta para recalcularse cuando entra un movimiento nuevo.
final resumenTurnoProvider = FutureProvider.autoDispose
    .family<ResumenTurno?, String>((ref, sesionId) {
      ref.watch(sesionActualProvider);
      return ref
          .watch(cashRegisterRepositoryProvider)
          .obtenerResumenTurno(sesionId);
    });

/// Monto sugerido para la próxima apertura (RN-09).
final montoSugeridoAperturaProvider = FutureProvider<Money>((ref) {
  return ref
      .watch(cashRegisterRepositoryProvider)
      .obtenerMontoSugeridoApertura();
});
