import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/features/ai_chat/data/datasources/ai_chat_remote_datasource.dart';
import 'package:app_gestion/features/ai_chat/domain/entities/chat_message.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:app_gestion/features/license/presentation/providers/license_providers.dart';

/// Licencia fija para las capturas de las pantallas de entrada (sin
/// licencia, bloqueada) y de los planes (p. ej. Nube para el asistente).
class LicenciaVisual extends LicenseController {
  LicenciaVisual(this._check);

  factory LicenciaVisual.plan(TipoLicencia tipo) => LicenciaVisual(
    LicenciaActiva(
      Licencia(
        tipo: tipo,
        estado: EstadoLicencia.activa,
        deviceId: 'dispositivo-demo',
        fechaActivacion: DateTime.now().subtract(const Duration(days: 30)),
        ultimaValidacion: DateTime.now(),
        fechaVencimiento: DateTime.now().add(const Duration(days: 300)),
      ),
    ),
  );

  final LicenseCheck _check;

  @override
  Future<LicenseCheck> build() async => _check;

  @override
  Future<void> revalidar() async {}
}

/// Sesión fija: sin negocio (configuración inicial) o sin sesión (login). El
/// login SIEMPRE falla con el mismo mensaje que el repositorio real.
class AuthVisual extends AuthController {
  AuthVisual(this._estado, {this.bloqueoSegundos});

  final EstadoSesion _estado;

  /// Si se indica, el login responde "Demasiados intentos" con esa espera.
  final int? bloqueoSegundos;

  @override
  Future<EstadoSesion> build() async => _estado;

  @override
  Future<Failure?> login({
    required String username,
    required String password,
  }) async => bloqueoSegundos != null
      ? DemasiadosIntentosFailure(bloqueoSegundos!)
      : const ValidationFailure('Usuario o contraseña incorrectos.');
}

/// Asistente de IA de mentira: responde siempre lo mismo.
class IaVisual implements AiChatRemoteDatasource {
  @override
  Future<AiChatResponse> chat({
    required List<ChatMessage> mensajes,
    required Map<String, dynamic> contexto,
  }) async => const AiChatResponse(
    ok: true,
    respuesta:
        'Este mes vendiste RD\$ 6,444.00 en 9 ventas. Tu producto más '
        'vendido fue Huevos.',
  );
}
