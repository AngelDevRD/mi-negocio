import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../entities/caja_sesion.dart';

/// Operaciones de caja diaria (RF-CAJ): sesión actual, historial y cierre.
abstract interface class CashRegisterRepository {
  /// Sesión de caja abierta (si hay), con sus movimientos en vivo.
  Stream<CajaSesion?> watchSesionActual();

  /// Sesiones cerradas, más reciente primero.
  Stream<List<CajaSesion>> watchHistorial();

  /// Sesión (abierta o cerrada) con sus movimientos, o `null` si no existe.
  Future<CajaSesion?> obtenerSesion(String id);

  /// Monto sugerido para la próxima apertura (RN-09): `montoDejadoSiguiente`
  /// de la última sesión cerrada, o cero si no hay ninguna.
  Future<Money> obtenerMontoSugeridoApertura();

  /// Cierra la sesión de caja abierta (RF-CAJ/RN-08): calcula el monto
  /// esperado (apertura + movimientos), registra el monto contado, la
  /// diferencia (contado − esperado), el monto a dejar para el día
  /// siguiente y registra el retiro del excedente en `caja_movimientos`.
  Future<Result<void>> cerrarCaja({
    required Money montoContado,
    required Money montoDejarSiguiente,
    required String usuarioId,
  });
}
