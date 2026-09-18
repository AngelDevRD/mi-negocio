import 'dart:math';

import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Luminancia relativa (WCAG 2.x): cada canal ya viene en [0, 1] en la API
/// moderna de [Color] (`.r`/`.g`/`.b`).
double _luminanciaRelativa(Color color) {
  double canal(double c) {
    return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * canal(color.r) +
      0.7152 * canal(color.g) +
      0.0722 * canal(color.b);
}

/// Ratio de contraste WCAG entre dos colores: (L_claro + 0.05) / (L_oscuro
/// + 0.05). AA para texto normal exige >= 4.5:1.
double _contraste(Color a, Color b) {
  final la = _luminanciaRelativa(a);
  final lb = _luminanciaRelativa(b);
  final claro = max(la, lb);
  final oscuro = min(la, lb);
  return (claro + 0.05) / (oscuro + 0.05);
}

void main() {
  test('AppColors está registrada en AppTheme.light()', () {
    final theme = AppTheme.light();
    expect(theme.extension<AppColors>(), isNotNull);
  });

  test('contraste exito/onExito >= 4.5:1 (WCAG AA)', () {
    final colors = AppTheme.light().extension<AppColors>()!;
    expect(_contraste(colors.exito, colors.onExito), greaterThanOrEqualTo(4.5));
  });

  test('contraste advertencia/onAdvertencia >= 4.5:1 (WCAG AA)', () {
    final colors = AppTheme.light().extension<AppColors>()!;
    expect(
      _contraste(colors.advertencia, colors.onAdvertencia),
      greaterThanOrEqualTo(4.5),
    );
  });
}
