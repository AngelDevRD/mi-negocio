/// Límite de intentos de login por usuario, EN MEMORIA del proceso.
///
/// Tras [intentosPermitidos] fallos seguidos del mismo usuario se bloquea
/// [esperaInicial]; cada fallo adicional duplica la espera hasta
/// [esperaMaxima]. Un login correcto reinicia el contador.
///
/// No se persiste nada (sin cambios de esquema): reiniciar la app limpia los
/// bloqueos. El reloj es inyectable y monotónico por defecto (un [Stopwatch]),
/// así que cambiar la hora del sistema no adelanta ni alarga la espera.
class LimitadorIntentosLogin {
  LimitadorIntentosLogin({Duration Function()? reloj})
    : _reloj = reloj ?? _relojMonotonico();

  static const int intentosPermitidos = 5;
  static const Duration esperaInicial = Duration(seconds: 30);
  static const Duration esperaMaxima = Duration(minutes: 5);

  final Duration Function() _reloj;
  final Map<String, _Estado> _estados = {};

  static Duration Function() _relojMonotonico() {
    final cronometro = Stopwatch()..start();
    return () => cronometro.elapsed;
  }

  /// Espera que le queda a [usuario] (redondeada hacia arriba a segundos
  /// enteros), o `null` si puede intentar.
  Duration? esperaRestante(String usuario) {
    final hasta = _estados[usuario]?.bloqueadoHasta;
    if (hasta == null) return null;
    final resta = hasta - _reloj();
    if (resta <= Duration.zero) return null;
    return Duration(seconds: (resta.inMilliseconds / 1000).ceil());
  }

  /// Anota un intento fallido. Devuelve la espera impuesta (o `null` si aún
  /// no se llegó al límite).
  Duration? registrarFallo(String usuario) {
    final estado = _estados.putIfAbsent(usuario, _Estado.new);
    estado.fallos++;
    if (estado.fallos < intentosPermitidos) return null;
    final espera = _esperaPara(estado.fallos);
    estado.bloqueadoHasta = _reloj() + espera;
    return espera;
  }

  /// Login correcto: se olvida el historial de [usuario].
  void reiniciar(String usuario) => _estados.remove(usuario);

  static Duration _esperaPara(int fallos) {
    var espera = esperaInicial;
    for (var i = intentosPermitidos; i < fallos; i++) {
      espera *= 2;
      if (espera >= esperaMaxima) return esperaMaxima;
    }
    return espera;
  }
}

class _Estado {
  int fallos = 0;
  Duration? bloqueadoHasta;
}
