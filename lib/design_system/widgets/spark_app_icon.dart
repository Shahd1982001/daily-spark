import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';


/// The layered Daily Spark app mark used on the splash screen.
///
/// Figma spec (node 126:13378):
///  • 144 × 144 blurred ember gradient plate  (radius 24)
///  • 128 × 128 white plate at 80% opacity     (radius 24)
///  • 112 × 112 pure white plate + shadow      (radius 24)
///  •  72 ×  72  spark glyph on top
class SparkAppIcon extends StatelessWidget {
  const SparkAppIcon({super.key, this.size = 144});

  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.spark;
    final unit = size / 144;
    final radius = 24.0 * unit;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ember halo plate
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 16 * unit, sigmaY: 16 * unit),
              child: Container(
                width: 144 * unit,
                height: 144 * unit,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [p.iconHaloStart, p.iconHaloEnd],
                  ),
                ),
              ),
            ),
            // Soft white plate
            Container(
              width: 128 * unit,
              height: 128 * unit,
              decoration: BoxDecoration(
                color: p.dark
                    ? p.iconPlateSoft
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            // Main white tile
            Container(
              width: 112 * unit,
              height: 112 * unit,
              decoration: BoxDecoration(
                color: p.iconPlate,
                borderRadius: BorderRadius.circular(radius),
                border: p.dark
                    ? Border.all(
                        color: p.iconBorder,
                        width: 1 * (unit < 0.6 ? 0.6 : unit),
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 10 * unit,
                    offset: Offset(0, 8 * unit),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 25 * unit,
                    offset: Offset(0, 20 * unit),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/brand/spark_mark.png',
                  width: 72 * unit,
                  height: 72 * unit,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Daily Spark mark: four ember petals with four bright inner petals
/// and a small white centre dot — built exactly as the Figma SVG group.
class SparkGlyphPainter extends CustomPainter {
  SparkGlyphPainter();

  static Color get _ember => p.ember;

  /// One arm of the star: wide base at the centre, sharp tip, concave sides.
  Path _petal(double cx, double cy, double r, double w) {
    return Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx + w, cy - r * 0.04, cx + w * 0.42, cy - r * 0.80, cx, cy - r)
      ..cubicTo(cx - w * 0.42, cy - r * 0.80, cx - w, cy - r * 0.04, cx, cy)
      ..close();
  }

  void _fourPetals(
    Canvas canvas,
    Size size,
    double scale,
    Paint paint, {
    double outwardShift = 0,
  }) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.43 * scale;
    final w = r * 0.60;
    final shift = size.width * 0.43 * outwardShift;

    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(i * 1.5707963267948966);
      canvas.translate(0, -shift);
      canvas.drawPath(_petal(0, 0, r, w), paint);
      canvas.restore();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Ember petals
    _fourPetals(
      canvas,
      size,
      1.0,
      Paint()
        ..isAntiAlias = true
        ..color = _ember,
    );

    // Bright inner petals (full white, pushed a touch outward so an ember
    // cross stays visible between them — exactly like the Figma SVG).
    _fourPetals(
      canvas,
      size,
      0.68,
      Paint()
        ..isAntiAlias = true
        ..color = Colors.white,
      outwardShift: 0.10,
    );

    // Centre dot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.032,
      Paint()
        ..isAntiAlias = true
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant SparkGlyphPainter oldDelegate) => false;
}
