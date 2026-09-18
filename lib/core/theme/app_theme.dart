import 'package:flutter/material.dart';

/// Tema base de la aplicación (Material 3, modo claro).
///
/// Sistema visual minimalista: claridad > consistencia > usabilidad >
/// estética. Sin gradientes, sombras ni animaciones gratuitas. Todas las
/// pantallas consumen colores/espaciados/radios desde este archivo.
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
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
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
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      extensions: const [AppColors.light],
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

/// Radios de borde consistentes en toda la app (tarjetas, snackbars, chips).
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

/// Colores semánticos que Material 3 no cubre (éxito/advertencia), como
/// [ThemeExtension] para poder tematizarlos junto al resto del tema.
///
/// Uso: `AppColors.of(context).exito` o, con la extensión de contexto,
/// `context.appColors.exito`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.exito,
    required this.onExito,
    required this.advertencia,
    required this.onAdvertencia,
  });

  /// Confirmaciones, montos positivos, operaciones completadas con éxito.
  final Color exito;

  /// Contenido (texto/ícono) sobre un fondo [exito]. Contraste AA (>= 4.5:1).
  final Color onExito;

  /// Alertas no destructivas: stock bajo, datos pendientes de revisar.
  final Color advertencia;

  /// Contenido (texto/ícono) sobre un fondo [advertencia]. Contraste AA.
  final Color onAdvertencia;

  /// Paleta usada en [AppTheme.light]. Verificada con contraste >= 4.5:1.
  static const AppColors light = AppColors(
    exito: Color(0xFF1B7F4D),
    onExito: Color(0xFFFFFFFF),
    advertencia: Color(0xFF8A5A00),
    onAdvertencia: Color(0xFFFFFFFF),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? exito,
    Color? onExito,
    Color? advertencia,
    Color? onAdvertencia,
  }) {
    return AppColors(
      exito: exito ?? this.exito,
      onExito: onExito ?? this.onExito,
      advertencia: advertencia ?? this.advertencia,
      onAdvertencia: onAdvertencia ?? this.onAdvertencia,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      exito: Color.lerp(exito, other.exito, t)!,
      onExito: Color.lerp(onExito, other.onExito, t)!,
      advertencia: Color.lerp(advertencia, other.advertencia, t)!,
      onAdvertencia: Color.lerp(onAdvertencia, other.onAdvertencia, t)!,
    );
  }
}

/// Acceso corto a [AppColors] desde cualquier `BuildContext`.
extension AppColorsContext on BuildContext {
  AppColors get appColors => AppColors.of(this);
}
