import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/datasources/license_local_datasource.dart';
import '../../data/datasources/license_remote_datasource.dart';
import '../../data/repositories/license_repository_impl.dart';
import '../../domain/entities/licencia.dart';
import '../../domain/repositories/license_repository.dart';

/// Identificador estable del dispositivo (RF-LIC-03).
Future<String> _obtenerDeviceId() async {
  final plugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    return (await plugin.androidInfo).id;
  }
  if (Platform.isIOS) {
    return (await plugin.iosInfo).identifierForVendor ?? 'ios-sin-id';
  }
  // Escritorio/test: sin binding de dispositivo real.
  return 'dispositivo-${Platform.operatingSystem}';
}

Future<bool> _hayInternet() async {
  final resultados = await Connectivity().checkConnectivity();
  return resultados.any((r) => r != ConnectivityResult.none);
}

final licenseRepositoryProvider = Provider<LicenseRepository>((ref) {
  return LicenseRepositoryImpl(
    local: LicenseLocalDatasource(ref.watch(appDatabaseProvider)),
    remote: SupabaseLicenseRemoteDatasource(
      disponible: SupabaseConfig.configurado,
    ),
    deviceId: _obtenerDeviceId,
    isOnline: _hayInternet,
  );
});

/// Estado global de la licencia. El router redirige según este estado
/// (guard de licencia, RN-15).
final licenseControllerProvider =
    AsyncNotifierProvider<LicenseController, LicenseCheck>(
      LicenseController.new,
    );

class LicenseController extends AsyncNotifier<LicenseCheck> {
  LicenseRepository get _repo => ref.read(licenseRepositoryProvider);

  @override
  Future<LicenseCheck> build() async {
    final check = await _repo.verificarAlArranque();
    if (check case LicenciaActiva(:final licencia)) {
      final dias = licencia.diasParaVencer(DateTime.now().toUtc());
      if (dias != null && dias <= diasAlertaRenovacion) {
        await NotificationService.instance.notificarVencimientoProximo(dias);
      }
    }
    return check;
  }

  /// Devuelve el fallo si lo hubo; `null` = éxito (la UI muestra el mensaje).
  Future<Failure?> activarDemo() async {
    final result = await _repo.activarDemo();
    return result.when(
      ok: (licencia) {
        state = AsyncData(LicenciaActiva(licencia));
        return null;
      },
      fail: (failure) => failure,
    );
  }

  Future<Failure?> activarConClave(String clave) async {
    final result = await _repo.activarConClave(clave);
    return result.when(
      ok: (licencia) {
        state = AsyncData(LicenciaActiva(licencia));
        return null;
      },
      fail: (failure) => failure,
    );
  }

  /// Devuelve (mensajeDeConfirmacion, fallo).
  Future<(String?, Failure?)> solicitar({
    required String nombreNegocio,
    String? telefono,
    required String tipoDeseado,
  }) async {
    final result = await _repo.solicitarLicencia(
      nombreNegocio: nombreNegocio,
      telefono: telefono,
      tipoDeseado: tipoDeseado,
    );
    return result.when(
      ok: (mensaje) => (mensaje, null),
      fail: (failure) => (null, failure),
    );
  }

  /// Botón «Reintentar validación» de la pantalla bloqueante (RF-LIC-05).
  Future<void> revalidar() async {
    state = const AsyncLoading();
    state = AsyncData(await _repo.verificarAlArranque());
  }

  /// Botón «Renovar» del perfil (F18): genera la solicitud de pago.
  /// Devuelve (mensajeDeConfirmacion, fallo).
  Future<(String?, Failure?)> renovar() async {
    final result = await _repo.solicitarRenovacion();
    return result.when(
      ok: (mensaje) => (mensaje, null),
      fail: (failure) => (null, failure),
    );
  }
}
