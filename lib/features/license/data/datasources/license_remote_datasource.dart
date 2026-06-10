import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/database/enums.dart';

/// Respuesta de la edge function `licencias`.
class RemoteLicenseResponse {
  const RemoteLicenseResponse({
    required this.ok,
    this.error,
    this.licencia,
    this.mensaje,
  });

  final bool ok;
  final String? error;
  final RemoteLicenseDto? licencia;
  final String? mensaje;

  factory RemoteLicenseResponse.fromJson(Map<String, dynamic> json) {
    return RemoteLicenseResponse(
      ok: json['ok'] == true,
      error: json['error'] as String?,
      mensaje: json['mensaje'] as String?,
      licencia: json['licencia'] == null
          ? null
          : RemoteLicenseDto.fromJson(json['licencia'] as Map<String, dynamic>),
    );
  }
}

class RemoteLicenseDto {
  const RemoteLicenseDto({
    required this.clave,
    required this.tipo,
    required this.estado,
    this.fechaActivacion,
    this.fechaVencimiento,
    this.motivoSuspension,
  });

  final String clave;
  final TipoLicencia tipo;
  final EstadoLicencia estado;
  final DateTime? fechaActivacion;
  final DateTime? fechaVencimiento;
  final String? motivoSuspension;

  factory RemoteLicenseDto.fromJson(Map<String, dynamic> json) {
    return RemoteLicenseDto(
      clave: json['clave'] as String,
      tipo: TipoLicencia.values.byName(json['tipo'] as String),
      estado: _mapEstado(json['estado'] as String),
      fechaActivacion: _parseDate(json['fechaActivacion']),
      fechaVencimiento: _parseDate(json['fechaVencimiento']),
      motivoSuspension: json['motivoSuspension'] as String?,
    );
  }

  /// El lado nube tiene un estado extra ('rechazada') que localmente se
  /// trata como suspendida (bloqueante).
  static EstadoLicencia _mapEstado(String estado) {
    if (estado == 'rechazada') return EstadoLicencia.suspendida;
    return EstadoLicencia.values.byName(estado);
  }

  static DateTime? _parseDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String).toUtc();
}

/// Cliente de la edge function `licencias` (RF-LIC). Abstracto para poder
/// simularlo en tests.
abstract class LicenseRemoteDatasource {
  /// `true` si Supabase está configurado en esta build (--dart-define).
  bool get disponible;

  Future<RemoteLicenseResponse> activar({
    required String clave,
    required String deviceId,
  });

  Future<RemoteLicenseResponse> validar({
    required String clave,
    required String deviceId,
  });

  Future<RemoteLicenseResponse> solicitar({
    required String nombreNegocio,
    required String emailAdmin,
    String? telefono,
    required String deviceId,
    required String tipoDeseado,
  });
}

class SupabaseLicenseRemoteDatasource implements LicenseRemoteDatasource {
  SupabaseLicenseRemoteDatasource({required this.disponible});

  @override
  final bool disponible;

  Future<RemoteLicenseResponse> _invoke(Map<String, dynamic> body) async {
    final response = await Supabase.instance.client.functions.invoke(
      'licencias',
      body: body,
    );
    return RemoteLicenseResponse.fromJson(
      (response.data as Map).cast<String, dynamic>(),
    );
  }

  @override
  Future<RemoteLicenseResponse> activar({
    required String clave,
    required String deviceId,
  }) {
    return _invoke({'action': 'activar', 'clave': clave, 'deviceId': deviceId});
  }

  @override
  Future<RemoteLicenseResponse> validar({
    required String clave,
    required String deviceId,
  }) {
    return _invoke({'action': 'validar', 'clave': clave, 'deviceId': deviceId});
  }

  @override
  Future<RemoteLicenseResponse> solicitar({
    required String nombreNegocio,
    required String emailAdmin,
    String? telefono,
    required String deviceId,
    required String tipoDeseado,
  }) {
    return _invoke({
      'action': 'solicitar',
      'nombreNegocio': nombreNegocio,
      'emailAdmin': emailAdmin,
      'telefono': telefono,
      'deviceId': deviceId,
      'tipoDeseado': tipoDeseado,
    });
  }
}
