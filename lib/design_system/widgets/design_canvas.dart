import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Every screen is drawn on a fixed 390 × 884 canvas (the exact Figma frame)
/// and then uniformly scaled to the device viewport. This guarantees the
/// layout ratios stay identical to the design on every phone.
class DesignCanvas extends StatelessWidget {
  const DesignCanvas({
    super.key,
    required this.child,
    this.background = const Color(0xFFF8FAF6),
  });

  static const double width = 390;
  static const double height = 884;

  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            constraints.maxWidth / width,
            constraints.maxHeight / height,
          );
          return Center(
            child: SizedBox(
              width: width * scale,
              height: height * scale,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Convenience text builder that mirrors a Figma text style 1:1.
Widget figmaText(
  String text, {
  required double size,
  required FontWeight weight,
  required Color color,
  double? letterSpacing,
  double? lineHeight,
  TextAlign align = TextAlign.left,
  double? width,
  int? maxLines,
}) {
  final style = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: lineHeight == null ? null : lineHeight / size,
    color: color,
    decoration: TextDecoration.none,
  );
  final child = Text(text, style: style, textAlign: align, maxLines: maxLines);
  return width == null ? child : SizedBox(width: width, child: child);
}
