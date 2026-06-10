import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/enums.dart';

part 'licencia.freezed.dart';

/// Licencia vigente en este dispositivo (espejo de Supabase o demo local).
@freezed
abstract class Licencia with _$Licencia {
  const factory Licencia({
    required TipoLicencia tipo,
    required EstadoLicencia estado,
    required String deviceId,
    required DateTime fechaActivacion,
    required DateTime ultimaValidacion,
    String? clave,
    DateTime? fechaVencimiento,
    String? motivoSuspension,
  }) = _Licencia;

  const Licencia._();

  /// El vencimiento se evalúa contra el reloj inyectado del repositorio
  /// (testeable), no contra `DateTime.now()`.
  bool vencidaEn(DateTime momento) =>
      fechaVencimiento != null && momento.isAfter(fechaVencimiento!);
}

/// Resultado de la verificación de licencia al arranque (RF-LIC-04/05).
sealed class LicenseCheck {
  const LicenseCheck();
}

/// No hay licencia: mostrar pantalla de activación (RF-LIC-01).
final class SinLicencia extends LicenseCheck {
  const SinLicencia();
}

/// Acceso permitido.
final class LicenciaActiva extends LicenseCheck {
  const LicenciaActiva(this.licencia);
  final Licencia licencia;
}

/// Acceso bloqueado: suspendida, vencida o fuera del período de gracia (RN-15).
final class LicenciaBloqueada extends LicenseCheck {
  const LicenciaBloqueada(this.motivo, {this.licencia});
  final String motivo;
  final Licencia? licencia;
}
