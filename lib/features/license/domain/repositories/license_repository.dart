import '../../../../core/errors/result.dart';
import '../entities/licencia.dart';

/// Contrato del sistema de licencias (RF-LIC).
abstract class LicenseRepository {
  /// Verificación al arranque: online revalida contra Supabase; offline usa
  /// la caché local con período de gracia (RN-16).
  Future<LicenseCheck> verificarAlArranque();

  /// Activa el modo Demo: 15 días, totalmente local (RN-17).
  Future<Result<Licencia>> activarDemo();

  /// Activa una licencia real contra Supabase (requiere internet).
  Future<Result<Licencia>> activarConClave(String clave);

  /// Envía una solicitud de licencia al propietario del sistema (RF-LIC-07).
  /// Devuelve el mensaje de confirmación.
  Future<Result<String>> solicitarLicencia({
    required String nombreNegocio,
    String? telefono,
    required String tipoDeseado,
  });

  /// Desactiva la licencia en este dispositivo (libera el device).
  Future<Result<void>> desactivar();

  /// Solicita la renovación de la suscripción (F18): genera una solicitud
  /// de pago que el propietario confirma desde el panel (F4). Devuelve el
  /// mensaje de confirmación.
  Future<Result<String>> solicitarRenovacion();
}
