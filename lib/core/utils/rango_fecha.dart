import 'fechas.dart';

/// Rango de fechas de un filtro de lista (ventas, compras).
enum RangoFecha {
  todo('Todas las fechas'),
  hoy('Hoy'),
  semana('Esta semana'),
  mes('Este mes'),
  personalizado('Personalizado...');

  const RangoFecha(this.etiqueta);

  /// Texto del rango en el chip y en el menú.
  final String etiqueta;
}

/// Límites `desde`/`hasta` (instantes UTC del calendario LOCAL) de un [rango].
/// `hasta` es INCLUSIVO (los datasources comparan con `<=`): un milisegundo
/// antes de que empiece el período siguiente. Con [RangoFecha.personalizado]
/// se devuelven [desde]/[hasta] tal cual; con [RangoFecha.todo], ambos `null`.
({DateTime? desde, DateTime? hasta}) limitesDeRango(
  RangoFecha rango,
  DateTime ahora, {
  DateTime? desde,
  DateTime? hasta,
}) {
  const unMs = Duration(milliseconds: 1);
  return switch (rango) {
    RangoFecha.todo => (desde: null, hasta: null),
    RangoFecha.hoy => (
      desde: inicioDelDiaLocal(ahora),
      hasta: inicioDelDiaSiguienteLocal(ahora).subtract(unMs),
    ),
    RangoFecha.semana => (
      desde: inicioDeLaSemanaLocal(ahora),
      hasta: _finDeSemana(ahora).subtract(unMs),
    ),
    RangoFecha.mes => (
      desde: inicioDelMesLocal(ahora),
      hasta: inicioDelMesSiguienteLocal(ahora).subtract(unMs),
    ),
    RangoFecha.personalizado => (desde: desde, hasta: hasta),
  };
}

/// Instantes UTC (calendario local) de un rango elegido en el selector de
/// fechas: del inicio del primer día al último milisegundo del último día.
({DateTime desde, DateTime hasta}) limitesDeDias(
  DateTime primero,
  DateTime ultimo,
) {
  return (
    desde: DateTime(primero.year, primero.month, primero.day).toUtc(),
    hasta: DateTime(
      ultimo.year,
      ultimo.month,
      ultimo.day + 1,
    ).toUtc().subtract(const Duration(milliseconds: 1)),
  );
}

/// Instante en que empieza la semana local siguiente (construido desde
/// componentes locales, sin sumar 24 h a un instante UTC).
DateTime _finDeSemana(DateTime ahora) {
  final inicio = inicioDeLaSemanaLocal(ahora).toLocal();
  return DateTime(inicio.year, inicio.month, inicio.day + 7).toUtc();
}
