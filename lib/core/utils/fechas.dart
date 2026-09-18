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
