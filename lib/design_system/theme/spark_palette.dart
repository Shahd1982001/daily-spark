import 'package:flutter/material.dart';

/// Semantic colour roles for Daily Spark, with light + dark variants taken
/// directly from the Figma file (light: 126:* frames, dark: 163:* frames).
///
/// Screens read the palette from the `SparkThemeScope` inherited widget, so a
/// screen's widget tree never hardcodes a theme-dependent colour.
@immutable
class SparkPalette {
  const SparkPalette({
    required this.dark,
    required this.canvas,
    required this.surface,
    required this.panel,
    required this.container,
    required this.bone,
    required this.border,
    required this.ink,
    required this.body,
    required this.muted,
    required this.faint,
    required this.metaText,
    required this.metaTextSoft,
    required this.syncText,
    required this.pillText,
    required this.ember,
    required this.emberLight,
    required this.emberDark,
    required this.emberDeep,
    required this.emberSoft,
    required this.gold,
    required this.ochre,
    required this.sage,
    required this.success,
    required this.mint,
    required this.pine,
    required this.haloStart,
    required this.haloMid,
    required this.haloEnd,
    required this.hazeStart,
    required this.hazeEnd,
    required this.iconPlate,
    required this.iconPlateSoft,
    required this.iconHaloStart,
    required this.iconHaloEnd,
    required this.iconBorder,
  });

  final bool dark;

  // Surfaces
  final Color canvas;
  final Color surface;
  final Color panel;
  final Color container;
  final Color bone;
  final Color border;

  // Text
  final Color ink;
  final Color body;
  final Color muted;
  final Color faint;
  final Color metaText;
  final Color metaTextSoft;
  final Color syncText;
  final Color pillText;

  // Ember accents
  final Color ember;
  final Color emberLight;
  final Color emberDark;
  final Color emberDeep;
  final Color emberSoft;

  // Support accents
  final Color gold;
  final Color ochre;
  final Color sage;
  final Color success;
  final Color mint;
  final Color pine;

  // Splash ambience
  final Color haloStart;
  final Color haloMid;
  final Color haloEnd;
  final Color hazeStart;
  final Color hazeEnd;

  // App icon plates
  final Color iconPlate;
  final Color iconPlateSoft;
  final Color iconHaloStart;
  final Color iconHaloEnd;
  final Color iconBorder;

  static const light = SparkPalette(
    dark: false,
    canvas: Color(0xFFF8FAF6),
    surface: Color(0xFFFFFFFF),
    panel: Color(0xFFF3F4F0),
    container: Color(0xFFEDEEEB),
    bone: Color(0xFFE7E9E5),
    border: Color(0xFFEDEEEB),
    ink: Color(0xFF191C1A),
    body: Color(0xFF57423B),
    muted: Color(0xFF8A726A),
    faint: Color(0xFF78716C),
    metaText: Color(0x6657423B),
    metaTextSoft: Color(0x9957423B),
    syncText: Color(0xB357423B),
    pillText: Color(0xFF57423B),
    ember: Color(0xFFFF6B2C),
    emberLight: Color(0xFFFF8A54),
    emberDark: Color(0xFFE05316),
    emberDeep: Color(0xFF9F3C16),
    emberSoft: Color(0xFFFFDBCF),
    gold: Color(0xFFFDBA54),
    ochre: Color(0xFF7E5300),
    sage: Color(0xFF3A6750),
    success: Color(0xFF10B981),
    mint: Color(0xFFBCEED1),
    pine: Color(0xFF406D56),
    haloStart: Color(0x40FDBA54),
    haloMid: Color(0x14FF8A54),
    haloEnd: Color(0x00F8FAF6),
    hazeStart: Color(0x33BCEED1),
    hazeEnd: Color(0x00F8FAF6),
    iconPlate: Color(0xFFFFFFFF),
    iconPlateSoft: Color(0xEBFFFFFF),
    iconHaloStart: Color(0x0D9F3C16),
    iconHaloEnd: Color(0x0A7E5300),
    iconBorder: Color(0x00000000),
  );

  static const dark2 = Color(0xFF121413);

  static const _dark = SparkPalette(
    dark: true,
    canvas: Color(0xFF121413),
    surface: Color(0xFF1A1C1B),
    panel: Color(0xFF222624),
    container: Color(0xFF2A2E2C),
    bone: Color(0xFF383D3A),
    border: Color(0xFF2E3230),
    ink: Color(0xFFF5F3EF),
    body: Color(0xFFA39E98),
    muted: Color(0xFF8E8A85),
    faint: Color(0xFF706C66),
    metaText: Color(0xFF706C66),
    metaTextSoft: Color(0xFF55524D),
    syncText: Color(0xFFA39E98),
    pillText: Color(0xFFD1CDC7),
    ember: Color(0xFFFF6B2C),
    emberLight: Color(0xFFFF8A54),
    emberDark: Color(0xFFE85D04),
    emberDeep: Color(0xFFFFB59A),
    emberSoft: Color(0x26FF6B2C),
    gold: Color(0xFFFDBA54),
    ochre: Color(0xFFFDBA54),
    sage: Color(0xFF4EDEA3),
    success: Color(0xFF10B981),
    mint: Color(0xFF4EDEA3),
    pine: Color(0xFF4EDEA3),
    haloStart: Color(0x1A9F3C16),
    haloMid: Color(0x26FDBA54),
    haloEnd: Color(0x00000000),
    hazeStart: Color(0x33BCEED1),
    hazeEnd: Color(0x00000000),
    iconPlate: Color(0xFF1A1C1B),
    iconPlateSoft: Color(0xFF1A1C1B),
    iconHaloStart: Color(0x33FF6B2C),
    iconHaloEnd: Color(0x1A10B981),
    iconBorder: Color(0xFF2A2E2C),
  );

  /// The dark palette instance (kept out of `const` list literals for clarity).
  static SparkPalette get darkPalette => _dark;

  static SparkPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SparkThemeScope>()?.palette ??
      light;
}

/// Provides the active palette to every screen below it.
class SparkThemeScope extends InheritedWidget {
  const SparkThemeScope({
    super.key,
    required this.palette,
    required super.child,
  });

  final SparkPalette palette;

  bool get isDark => palette.dark;

  static SparkPalette of(BuildContext context) => SparkPalette.of(context);

  @override
  bool updateShouldNotify(SparkThemeScope oldWidget) =>
      oldWidget.palette != palette;
}

extension SparkThemeContext on BuildContext {
  /// `context.spark.ink` — the active palette.
  SparkPalette get spark => SparkPalette.of(this);
}
