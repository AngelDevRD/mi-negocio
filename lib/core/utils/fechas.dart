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
  final local = ahora.toLocal();
  final siguiente = local.month == 12
      ? DateTime(local.year + 1)
      : DateTime(local.year, local.month + 1);
  return siguiente.toUtc();
}
