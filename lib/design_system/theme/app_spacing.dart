/// Design tokens — Spacing & Radii (8pt rhythm from Figma).
class AppSpacing {
  AppSpacing._();
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16; // master anchor
  static const double s20 = 20; // screen outer margin
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;

  /// Horizontal margin used on every screen.
  static const double screenMargin = 20;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double btn = 12; // rounded-xl
  static const double card = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double full = 9999;
}

class AppSizes {
  AppSizes._();
  static const double buttonHeight = 48;
  static const double inputHeight = 52;
  static const double dockHeight = 64;
  static const double habitCardHeight = 80;
  static const double tapTarget = 48;
}
