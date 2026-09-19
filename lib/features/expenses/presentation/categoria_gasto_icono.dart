import 'package:flutter/material.dart';

/// Ícono de una categoría de gasto. Las categorías predefinidas tienen el suyo;
/// una personalizada usa el genérico. Siempre va junto al NOMBRE de la
/// categoría: el ícono ayuda a ubicarla, no la reemplaza.
IconData iconoCategoriaGasto(String categoria) => switch (categoria) {
  'Luz' => Icons.bolt_outlined,
  'Agua' => Icons.water_drop_outlined,
  'Alquiler' => Icons.home_outlined,
  'Transporte' => Icons.local_shipping_outlined,
  _ => Icons.receipt_long_outlined,
};
