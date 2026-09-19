/// Límites de día/mes en el calendario LOCAL del negocio.
///
/// El negocio opera en hora local del dispositivo (no en UTC), pero todas
/// las fechas se guardan en la base como `DateTime.now().toUtc()`. Estas
/// funciones son puras (nunca llaman a `DateTime.now()`; reciben el instante
/// `ahora` como parámetro) para ser deterministas y fáciles de testear, y
/// devuelven el INSTANTE (en UTC) correspondiente al límite del día/mes
/// local -- listo para comparar contra una columna `fecha`.
library;

/// Instante en que empieza el día calendario local que contiene a [ahora].
DateTime inicioDelDiaLocal(DateTime ahora) {
  final local = ahora.toLocal();
  return DateTime(local.year, local.month, local.day).toUtc();
}

/// Instante en que empieza el mes calendario local que contiene a [ahora].
DateTime inicioDelMesLocal(DateTime ahora) {
  final local = ahora.toLocal();
  return DateTime(local.year, local.month).toUtc();
}

/// Instante en que empieza el mes calendario local siguiente al de [ahora]
/// (diciembre -> enero del año siguiente incluido).
DateTime inicioDelMesSiguienteLocal(DateTime ahora) {
  return inicioDeMesDesplazadoLocal(ahora, 1);
}

/// Instante en que empieza el mes calendario local que resulta de sumarle
/// [meses] (puede ser negativo, p.ej. -1 para "el mes anterior") al mes de
/// [ahora]. Siempre se construye desde componentes LOCALES antes de
/// convertir a UTC, para no perder el offset del huso horario al cruzar
/// años (a diferencia de desplazar el campo `month` sobre un instante UTC
/// ya truncado).
DateTime inicioDeMesDesplazadoLocal(DateTime ahora, int meses) {
  final local = ahora.toLocal();
  return DateTime(local.year, local.month + meses).toUtc();
}

/// Instante en que empieza el día calendario local siguiente al de [ahora].
DateTime inicioDelDiaSiguienteLocal(DateTime ahora) {
  final local = ahora.toLocal();
  return DateTime(local.year, local.month, local.day + 1).toUtc();
}

/// Instante en que empieza la semana calendario local (lunes) que contiene a
/// [ahora]. La semana laboral de un colmado arranca el lunes.
DateTime inicioDeLaSemanaLocal(DateTime ahora) {
  final local = ahora.toLocal();
  return DateTime(
    local.year,
    local.month,
    local.day - (local.weekday - DateTime.monday),
  ).toUtc();
}

/// Nombres de los meses en español (sin depender de que el `Intl` de `es`
/// esté inicializado: en tests y en pantallas no siempre lo está).
const List<String> _meses = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

/// "Septiembre 2026" para el mes de [fecha].
String nombreDelMes(DateTime fecha) =>
    '${_meses[fecha.month - 1]} ${fecha.year}';

/// Título de un grupo diario de una lista: "Hoy", "Ayer" o "dd/MM/yyyy",
/// comparando en el calendario LOCAL. [fecha] y [ahora] pueden venir en UTC.
String etiquetaDeDia(DateTime fecha, DateTime ahora) {
  final dia = fecha.toLocal();
  final hoy = ahora.toLocal();
  final soloDia = DateTime(dia.year, dia.month, dia.day);
  final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
  final diferencia = soloHoy.difference(soloDia).inDays;
  if (diferencia == 0) return 'Hoy';
  if (diferencia == 1) return 'Ayer';
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(dia.day)}/${dos(dia.month)}/${dia.year}';
}

/// Grupo de elementos de un mismo día local, en el orden en que llegaron.
class GrupoDia<T> {
  GrupoDia(this.etiqueta, this.elementos);

  /// "Hoy", "Ayer" o la fecha (ver [etiquetaDeDia]).
  final String etiqueta;
  final List<T> elementos;
}

/// Agrupa [elementos] (ya ordenados de más reciente a más antiguo) por día
/// local, sin reordenarlos.
List<GrupoDia<T>> agruparPorDia<T>(
  List<T> elementos,
  DateTime Function(T) fecha,
  DateTime ahora,
) {
  final grupos = <GrupoDia<T>>[];
  DateTime? diaActual;
  for (final e in elementos) {
    final local = fecha(e).toLocal();
    final dia = DateTime(local.year, local.month, local.day);
    if (diaActual == null || dia != diaActual) {
      grupos.add(GrupoDia<T>(etiquetaDeDia(local, ahora), []));
      diaActual = dia;
    }
    grupos.last.elementos.add(e);
  }
  return grupos;
}
