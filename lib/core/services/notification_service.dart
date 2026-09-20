import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notificaciones locales (F18): alerta de vencimiento próximo de la
/// suscripción.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _inicializado = false;

  Future<void> _inicializar() async {
    if (_inicializado) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: 'Abrir'),
      windows: WindowsInitializationSettings(
        appName: 'MiTienda 360',
        appUserModelId: 'com.angeldevrd.appgestion',
        guid: 'a6e8f1c2-9b3d-4f7a-8e1c-2d4b6a9f0c3e',
      ),
    );
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _inicializado = true;
  }

  /// Muestra una alerta cuando la suscripción está próxima a vencer o ya
  /// venció (F18: alertas de renovación).
  Future<void> notificarVencimientoProximo(int diasRestantes) async {
    await _inicializar();
    final mensaje = diasRestantes <= 0
        ? 'Tu suscripción venció. Renueva desde Perfil para evitar interrupciones.'
        : 'Tu suscripción vence en $diasRestantes '
              '${diasRestantes == 1 ? 'día' : 'días'}. Renueva desde Perfil.';
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'suscripcion_vencimiento',
        'Vencimiento de suscripción',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(1001, 'Suscripción', mensaje, details);
  }
}
