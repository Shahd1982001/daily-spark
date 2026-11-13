import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';

/// Builds the light & dark [ThemeData] from the Figma tokens.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(SparkPalette.light);
  static ThemeData get dark => _build(SparkPalette.darkPalette);

  static ThemeData _build(SparkPalette p) {
    final isDark = p.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final scaffold = isDark ? p.canvas : p.canvas;
    final surface = isDark ? p.surface : p.surface;
    final surfaceHigh = isDark ? p.panel : p.bone;
    final outline = isDark ? p.bone : p.container;
    final onSurface = isDark ? p.ink : p.ink;
    final muted = isDark ? p.body : p.body;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.ember,
      onPrimary: Colors.white,
      primaryContainer: isDark ? p.emberDeep : p.emberDeep,
      onPrimaryContainer: Colors.white,
      secondary: isDark ? p.success : p.sage,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? p.panel : p.mintSoft,
      onSecondaryContainer: isDark ? p.success : p.pineDark,
      tertiary: p.ochre,
      onTertiary: Colors.white,
      error: p.error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceHigh,
      onSurfaceVariant: muted,
      outline: outline,
      outlineVariant: outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppText.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: AppTextTheme.of(brightness),
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.ember,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.btn)),
          textStyle: AppText.buttonLabel,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.emberDeep,
          textStyle: AppText.captionMain,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
          minimumSize: const Size(0, 40),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? p.panel : p.ink,
        contentTextStyle: AppText.bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.btn)),
      ),
    );
  }
}
