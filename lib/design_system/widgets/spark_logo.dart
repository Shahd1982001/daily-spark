import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';

/// Daily Spark brand mark: a soft squircle holding the ember spark glyph.
class SparkLogo extends StatelessWidget {
  const SparkLogo({
    super.key,
    this.size = 96,
    this.showTile = true,
  });

  final double size;
  final bool showTile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glyph = CustomPaint(
      size: Size(size * 0.42, size * 0.42),
      painter: _SparkGlyphPainter(
        color: AppColors.sparkOrange,
      ),
    );

    if (!showTile) return glyph;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMid : Colors.white,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : Colors.white,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.sparkOrange.withValues(alpha: 0.10),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(child: glyph),
    );
  }
}

/// A four-point concave star — the "spark".
class _SparkGlyphPainter extends CustomPainter {
  const _SparkGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Signature 4-point sparkle: straight tips on the axes, concave sides.
    final path = Path()
      ..moveTo(cx, 0)
      ..cubicTo(cx + w * 0.085, cy - h * 0.24, cx + w * 0.26, cy - h * 0.085, w, cy)
      ..cubicTo(cx + w * 0.26, cy + h * 0.085, cx + w * 0.085, cy + h * 0.24, cx, h)
      ..cubicTo(cx - w * 0.085, cy + h * 0.24, cx - w * 0.26, cy + h * 0.085, 0, cy)
      ..cubicTo(cx - w * 0.26, cy - h * 0.085, cx - w * 0.085, cy - h * 0.24, cx, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sparkOrange, AppColors.primaryEmber],
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkGlyphPainter oldDelegate) => oldDelegate.color != color;
}
