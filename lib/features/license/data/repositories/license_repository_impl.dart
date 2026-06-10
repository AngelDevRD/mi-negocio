import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/licencia.dart';
import '../../domain/repositories/license_repository.dart';
import '../datasources/license_local_datasource.dart';
import '../datasources/license_remote_datasource.dart';

/// Implementación del sistema de licencias (RF-LIC, RN-15..18).
class LicenseRepositoryImpl implements LicenseRepository {
  LicenseRepositoryImpl({
    required this._local,
    required this._remote,
    required this._deviceId,
    required this._isOnline,
    DateTime Function()? now,
  }) : _now = now ?? (() => DateTime.now().toUtc());

  final LicenseLocalDatasource _local;
  final LicenseRemoteDatasource _remote;
  final Future<String> Function() _deviceId;
  final Future<bool> Function() _isOnline;
  final DateTime Function() _now;

  /// RN-17: duración de la Demo.
  static const Duration duracionDemo = Duration(days: 15);

  /// RN-16: período de gracia sin validar online.
  static const Duration periodoGracia = Duration(days: 7);

  @override
  Future<LicenseCheck> verificarAlArranque() async {
    final cache = await _local.obtener();
    if (cache == null) return const SinLicencia();

    // Demo: 100% local, sin validación remota (RN-17).
    if (cache.tipo == TipoLicencia.demo) {
      if (cache.vencidaEn(_now())) {
        return LicenciaBloqueada(
          'El período de prueba de 15 días terminó. '
          'Activa una licencia para continuar; tus datos están guardados.',
          licencia: cache,
        );
      }
      return LicenciaActiva(cache);
    }

    // Local/Nube: revalidar online si se puede (RF-LIC-04).
    if (cache.clave != null && _remote.disponible && await _isOnline()) {
      try {
        final response = await _remote.validar(
          clave: cache.clave!,
          deviceId: cache.deviceId,
        );
        if (response.licencia != null) {
          final actualizada = cache.copyWith(
            estado: response.licencia!.estado,
            fechaVencimiento: response.licencia!.fechaVencimiento,
            motivoSuspension: response.licencia!.motivoSuspension,
            ultimaValidacion: _now(),
          );
          await _local.guardar(actualizada);
          return _evaluar(actualizada, validadaAhora: true);
        }
        if (!response.ok) {
          // Respuesta definitiva del servidor (clave inválida, otro device).
          return LicenciaBloqueada(
            response.error ?? 'Licencia inválida.',
            licencia: cache,
          );
        }
      } catch (_) {
        // Error de red: continuar offline con período de gracia.
      }
    }

    return _evaluar(cache, validadaAhora: false);
  }

  LicenseCheck _evaluar(Licencia licencia, {required bool validadaAhora}) {
    switch (licencia.estado) {
      case EstadoLicencia.suspendida:
        return LicenciaBloqueada(
          licencia.motivoSuspension == null
              ? 'La licencia está suspendida. Contacta al proveedor de la aplicación.'
              : 'Licencia suspendida: ${licencia.motivoSuspension}',
          licencia: licencia,
        );
      case EstadoLicencia.vencida:
        return LicenciaBloqueada(
          'La licencia venció. Renueva tu suscripción para continuar.',
          licencia: licencia,
        );
      case EstadoLicencia.pendiente:
      case EstadoLicencia.transferida:
        return LicenciaBloqueada(
          'La licencia no está activa en este dispositivo.',
          licencia: licencia,
        );
      case EstadoLicencia.activa:
        if (licencia.vencidaEn(_now())) {
          return LicenciaBloqueada(
            'La licencia venció. Renueva tu suscripción para continuar.',
            licencia: licencia,
          );
        }
        // RN-16: offline solo dentro del período de gracia.
        if (!validadaAhora) {
          final sinValidar = _now().difference(licencia.ultimaValidacion);
          if (sinValidar > periodoGracia) {
            return LicenciaBloqueada(
              'Se necesita conexión a internet para validar la licencia '
              '(más de ${periodoGracia.inDays} días sin validar).',
              licencia: licencia,
            );
          }
        }
        return LicenciaActiva(licencia);
    }
  }

  @override
  Future<Result<Licencia>> activarDemo() async {
    final existente = await _local.obtener();
    if (existente != null && existente.tipo == TipoLicencia.demo) {
      // RN-17: la demo no se reinicia borrando la licencia.
      return const Result.fail(
        LicenseFailure(
          'El período de prueba ya fue utilizado en este dispositivo.',
        ),
      );
    }
    final ahora = _now();
    final demo = Licencia(
      tipo: TipoLicencia.demo,
      estado: EstadoLicencia.activa,
      deviceId: await _deviceId(),
      fechaActivacion: ahora,
      fechaVencimiento: ahora.add(duracionDemo),
      ultimaValidacion: ahora,
    );
    await _local.guardar(demo);
    return Result.ok(demo);
  }

  @override
  Future<Result<Licencia>> activarConClave(String clave) async {
    if (clave.trim().isEmpty) {
      return const Result.fail(
        ValidationFailure('Ingresa la clave de licencia.'),
      );
    }
    if (!_remote.disponible) {
      return const Result.fail(
        NetworkFailure(
          'El servidor de licencias no está configurado en esta versión.',
        ),
      );
    }
    if (!await _isOnline()) {
      return const Result.fail(
        NetworkFailure(
          'Se necesita conexión a internet para activar la licencia.',
        ),
      );
    }
    try {
      final deviceId = await _deviceId();
      final response = await _remote.activar(
        clave: clave.trim(),
        deviceId: deviceId,
      );
      if (!response.ok || response.licencia == null) {
        return Result.fail(
          LicenseFailure(response.error ?? 'No se pudo activar la licencia.'),
        );
      }
      final dto = response.licencia!;
      final licencia = Licencia(
        tipo: dto.tipo,
        estado: dto.estado,
        clave: dto.clave,
        deviceId: deviceId,
        fechaActivacion: dto.fechaActivacion ?? _now(),
        fechaVencimiento: dto.fechaVencimiento,
        motivoSuspension: dto.motivoSuspension,
        ultimaValidacion: _now(),
      );
      await _local.guardar(licencia);
      return Result.ok(licencia);
    } catch (e) {
      return Result.fail(NetworkFailure('Error de conexión al activar: $e'));
    }
  }

  @override
  Future<Result<String>> solicitarLicencia({
    required String nombreNegocio,
    required String emailAdmin,
    String? telefono,
    required String tipoDeseado,
  }) async {
    if (nombreNegocio.trim().isEmpty || emailAdmin.trim().isEmpty) {
      return const Result.fail(
        ValidationFailure('Nombre del negocio y email son obligatorios.'),
      );
    }
    if (!_remote.disponible) {
      return const Result.fail(
        NetworkFailure(
          'El servidor de licencias no está configurado en esta versión.',
        ),
      );
    }
    if (!await _isOnline()) {
      return const Result.fail(
        NetworkFailure(
          'Se necesita conexión a internet para enviar la solicitud.',
        ),
      );
    }
    try {
      final response = await _remote.solicitar(
        nombreNegocio: nombreNegocio.trim(),
        emailAdmin: emailAdmin.trim(),
        telefono: telefono?.trim(),
        deviceId: await _deviceId(),
        tipoDeseado: tipoDeseado,
      );
      if (!response.ok) {
        return Result.fail(
          NetworkFailure(response.error ?? 'No se pudo enviar la solicitud.'),
        );
      }
      return Result.ok(response.mensaje ?? 'Solicitud enviada.');
    } catch (e) {
      return Result.fail(NetworkFailure('Error de conexión al solicitar: $e'));
    }
  }

  @override
  Future<Result<void>> desactivar() async {
    await _local.eliminar();
    return const Result.ok(null);
  }
}
