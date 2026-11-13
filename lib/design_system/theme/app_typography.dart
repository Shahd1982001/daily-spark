import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';

/// Design tokens — Typography (Plus Jakarta Sans).
class AppText {
  AppText._();

  static const fontFamily = 'PlusJakartaSans';

  static const displayXL = TextStyle(
    fontFamily: fontFamily, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700, letterSpacing: -0.5,
  );
  static const displayL = TextStyle(
    fontFamily: fontFamily, fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w700, letterSpacing: -0.4,
  );
  static const headingH1 = TextStyle(
    fontFamily: fontFamily, fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, letterSpacing: -0.3,
  );
  static const headingH2 = TextStyle(
    fontFamily: fontFamily, fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, letterSpacing: -0.2,
  );
  static const headingH3 = TextStyle(
    fontFamily: fontFamily, fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600,
  );
  static const titlePrimary = TextStyle(
    fontFamily: fontFamily, fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600,
  );
  static const subtitleRegular = TextStyle(
    fontFamily: fontFamily, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400,
  );
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400,
  );
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400,
  );
  static const bodySmall = TextStyle(
    fontFamily: fontFamily, fontSize: 12, height: 18 / 12, fontWeight: FontWeight.w400,
  );
  static const captionMain = TextStyle(
    fontFamily: fontFamily, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );
  static const buttonLabel = TextStyle(
    fontFamily: fontFamily, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600, letterSpacing: 0.1,
  );
  static const interactiveLabel = TextStyle(
    fontFamily: fontFamily, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, letterSpacing: 0.2,
  );
  /// The tiny uppercase eyebrow used across the design (e.g. "EST. 2024").
  static const eyebrow = TextStyle(
    fontFamily: fontFamily, fontSize: 10, height: 14 / 10, fontWeight: FontWeight.w600, letterSpacing: 1.4,
  );
  /// Kicker line above headlines (e.g. "STEP 2 OF 3 · CONSISTENCY").
  static const kicker = TextStyle(
    fontFamily: fontFamily, fontSize: 10, height: 14 / 10, fontWeight: FontWeight.w600, letterSpacing: 1.2,
  );
}

/// Semantic text themes resolved from the active brightness.
class AppTextTheme {
  static TextTheme of(Brightness b) {
    final primary = b == Brightness.dark ? AppColors.darkTextPrimary : AppColors.onBackground;
    final secondary = b == Brightness.dark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;
    return TextTheme(
      displayLarge: AppText.displayXL.copyWith(color: primary),
      displayMedium: AppText.displayL.copyWith(color: secondary),
      headlineLarge: AppText.headingH1.copyWith(color: secondary),
      headlineMedium: AppText.headingH2.copyWith(color: secondary),
      headlineSmall: AppText.headingH3.copyWith(color: secondary),
      titleMedium: AppText.titlePrimary.copyWith(color: secondary),
      bodyLarge: AppText.bodyLarge.copyWith(color: secondary),
      bodyMedium: AppText.bodyMedium.copyWith(color: secondary),
      bodySmall: AppText.bodySmall.copyWith(color: secondary),
      labelMedium: AppText.captionMain.copyWith(color: secondary),
      labelSmall: AppText.interactiveLabel.copyWith(color: secondary),
    );
  }
}
