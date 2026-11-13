import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Profile · Habit statistics tile — Figma 114 × 96, r16.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.scale,
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.overlayColor,
  });

  final double scale;
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 114 * s,
      height: 96 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 43 * s,
            top: 14 * s,
            child: Container(
              width: 28 * s,
              height: 28 * s,
              decoration: BoxDecoration(
                color: overlayColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14 * s, color: iconColor),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 40 * s,
            child: Center(
              child: figmaText(
                value,
                size: 18 * s,
                weight: FontWeight.w700,
                letterSpacing: -0.18 * s,
                lineHeight: 22 * s,
                color: p.ink,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 67 * s,
            child: Center(
              child: figmaText(
                label,
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.4 * s,
                lineHeight: 12 * s,
                color: p.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile · Level & mastery card — Figma 358 × 88, r16.
class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 88 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 20 * s,
            child: Container(
              width: 48 * s,
              height: 48 * s,
              decoration: BoxDecoration(
                color: p.emberTile,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Center(
                child: SizedBox(
                  width: 24.5 * s,
                  height: 24.5 * s,
                  child: CustomPaint(
                    painter:
                        StarburstBadgePainter(color: p.ember),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 80 * s,
            top: 14 * s,
            child: figmaText(
              'Level 4 Explorer',
              size: 16 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.08 * s,
              lineHeight: 22 * s,
              color: p.ink,
            ),
          ),
          Positioned(
            right: 16 * s,
            top: 19 * s,
            child: figmaText(
              '94%',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.4 * s,
              lineHeight: 12 * s,
              color: p.emberDeep,
            ),
          ),
          Positioned(
            left: 80 * s,
            top: 42 * s,
            child: Container(
              width: 262 * s,
              height: 8 * s,
              decoration: BoxDecoration(
                color: p.bone,
                borderRadius: BorderRadius.circular(999 * s),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 246.3 * s,
                  height: 8 * s,
                  decoration: BoxDecoration(
                    color: p.ember,
                    borderRadius: BorderRadius.circular(999 * s),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 80 * s,
            top: 56 * s,
            child: figmaText(
              'Consistency Score',
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: p.body,
            ),
          ),
          Positioned(
            right: 16 * s,
            top: 58 * s,
            child: figmaText(
              'Next: 14d Streak',
              size: 10 * s,
              weight: FontWeight.w500,
              letterSpacing: 0.4 * s,
              lineHeight: 12 * s,
              color: p.emberDeep,
            ),
          ),
        ],
      ),
    );
  }
}


/// Figma's "level" glyph: an 8-point starburst badge with a white star inside.
class StarburstBadgePainter extends CustomPainter {
  StarburstBadgePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final rOuter = size.width / 2;
    final rInner = rOuter * 0.78;
    const points = 8;

    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? rOuter : rInner;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);

    // white 5-point star
    final star = Path();
    final rStar = size.width * 0.26;
    final rStarIn = rStar * 0.45;
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? rStar : rStarIn;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i == 0) {
        star.moveTo(p.dx, p.dy);
      } else {
        star.lineTo(p.dx, p.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant StarburstBadgePainter old) => old.color != color;
}
