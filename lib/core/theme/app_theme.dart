import 'package:flutter/material.dart';

/// Tema base de la aplicación (Material 3, modo claro).
///
/// NOTA F6: el sistema visual definitivo (paleta, tarjetas, tipografía) se
/// define en la Fase 6 (Dashboard); este tema establece la estructura para
/// que todas las pantallas consuman colores/estilos desde un solo lugar.
abstract final class AppTheme {
  /// Verde profundo: dinero/negocio, alto contraste en mostrador.
  static const Color seed = Color(0xFF1B7F4D);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      ),
    );
  }
}

/// Espaciado consistente en toda la app.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
