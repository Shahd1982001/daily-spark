import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';

/// Builds the light & dark [ThemeData] from the Figma tokens.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scaffold = isDark ? AppColors.darkCanvas : AppColors.canvas;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final surfaceHigh = isDark ? AppColors.darkSurfaceHigh : AppColors.warmBone;
    final outline = isDark ? AppColors.darkOutline : AppColors.surfaceContainer;
    final onSurface = isDark ? AppColors.darkTextPrimary : AppColors.onBackground;
    final muted = isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.sparkOrange,
      onPrimary: Colors.white,
      primaryContainer: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryAccent,
      onPrimaryContainer: Colors.white,
      secondary: isDark ? AppColors.darkSuccess : AppColors.sage,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? AppColors.darkSurfaceHighest : AppColors.sageSoft,
      onSecondaryContainer: isDark ? AppColors.darkSuccess : AppColors.sageDark,
      tertiary: AppColors.ochre,
      onTertiary: Colors.white,
      error: AppColors.crimson,
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
          backgroundColor: AppColors.sparkOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.btn)),
          textStyle: AppText.buttonLabel,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          textStyle: AppText.captionMain,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
          minimumSize: const Size(0, 40),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.onBackground,
        contentTextStyle: AppText.bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.btn)),
      ),
    );
  }
}
