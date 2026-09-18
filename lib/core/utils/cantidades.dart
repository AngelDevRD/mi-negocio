/// Cantidad legible: entera sin decimales ("3"), fraccionaria con hasta 2
/// ("0.5", "2.25").
String formatoCantidad(double cantidad) {
  if (cantidad == cantidad.roundToDouble()) return cantidad.toStringAsFixed(0);
  final texto = cantidad.toStringAsFixed(2);
  return texto.endsWith('0') ? texto.substring(0, texto.length - 1) : texto;
}

/// Cantidad con su unidad: "1 unidad", "34 unidades", "8.5 libras", "3 kg".
///
/// Con cantidad distinta de 1 la unidad completa se pluraliza en español
/// ([pluralUnidad]); las abreviaturas (lb, kg, L, ml, oz, u.) se dejan tal
/// cual.
String formatoCantidadUnidad(double cantidad, String unidad) {
  final texto = formatoCantidad(cantidad);
  return cantidad == 1 ? '$texto $unidad' : '$texto ${pluralUnidad(unidad)}';
}

/// Plural español de una unidad de medida: vocal final + "s" (libra → libras),
/// consonante final + "es" (galón → galones, unidad → unidades). No toca
/// abreviaturas (3 letras o menos, o con punto), palabras que ya terminan en
/// "s" ni unidades de varias palabras.
String pluralUnidad(String unidad) {
  final u = unidad.trim();
  if (u.length <= 3 || u.contains('.') || u.contains(' ')) return u;
  final ultima = u[u.length - 1].toLowerCase();
  if (ultima == 's') return u;
  if ('aeiouáéíóú'.contains(ultima)) return '${u}s';
  // galón → galones: el acento desaparece al agregar la sílaba.
  const sinAcento = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u'};
  final penultima = u[u.length - 2];
  final base = sinAcento.containsKey(penultima)
      ? '${u.substring(0, u.length - 2)}${sinAcento[penultima]}$ultima'
      : u;
  return '${base}es';
}
