import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Hero momentum card on Habit Details.
/// Figma: "Habit Visual Momentum Hero" 358 × 208 at (16, 202).
class DetailsHeroCard extends StatelessWidget {
  DetailsHeroCard({super.key, required this.scale});

  final double scale;

  static Color get _ink => p.ink;
  static Color get _brown => p.body;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * s),
      child: Container(
        width: 358 * s,
        height: 208 * s,
        color: p.surface,
        child: Stack(
          children: [
            // ambient glow (clipped by the card)
            Positioned(
              left: 262 * s,
              top: -48 * s,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 40 * s, sigmaY: 40 * s),
                child: Container(
                  width: 144 * s,
                  height: 144 * s,
                  decoration: BoxDecoration(
                    color: p.emberDeep.withValues(alpha: 0.051),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // gauge
            Positioned(
              left: 24 * s,
              top: 24 * s,
              child: SizedBox(
                width: 112 * s,
                height: 112 * s,
                child: CustomPaint(
                  painter: _GaugePainter(stroke: 8.96 * s),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        figmaText(
                          '76%',
                          size: 18 * s,
                          weight: FontWeight.w600,
                          letterSpacing: -0.45 * s,
                          lineHeight: 24 * s,
                          color: _ink,
                        ),
                        figmaText(
                          'WEEK',
                          size: 10 * s,
                          weight: FontWeight.w600,
                          letterSpacing: 0.5 * s,
                          lineHeight: 12 * s,
                          color: _brown,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // streak pill
            Positioned(
              left: 136 * s,
              top: 36 * s,
              child: Container(
                height: 24 * s,
                padding: EdgeInsets.symmetric(horizontal: 8 * s),
                decoration: BoxDecoration(
                  color: p.emberTile,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 13 * s,
                      color: p.ochre,
                    ),
                    SizedBox(width: 6 * s),
                    figmaText(
                      '12 Day Streak',
                      size: 12 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.24 * s,
                      lineHeight: 16 * s,
                      color: p.ember,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 136 * s,
              top: 68 * s,
              child: figmaText(
                'In your flow state',
                size: 16 * s,
                weight: FontWeight.w600,
                letterSpacing: -0.08 * s,
                lineHeight: 22 * s,
                color: _ink,
              ),
            ),
            Positioned(
              left: 136 * s,
              top: 92 * s,
              child: figmaText(
                '12 days compound momentum',
                size: 12 * s,
                weight: FontWeight.w400,
                letterSpacing: 0.12 * s,
                lineHeight: 16 * s,
                color: _brown,
              ),
            ),
            Positioned(
              left: 136 * s,
              top: 112 * s,
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 13 * s,
                    color: p.sage,
                  ),
                  SizedBox(width: 4 * s),
                  figmaText(
                    '+3 days longer than last month',
                    size: 10 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.4 * s,
                    lineHeight: 12 * s,
                    color: p.sage,
                  ),
                ],
              ),
            ),
            // quick mood strip
            Positioned(
              left: 24 * s,
              top: 152 * s,
              child: Container(
                width: 310 * s,
                height: 32 * s,
                decoration: BoxDecoration(
                  color: p.panel.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 16 * s),
                    Icon(
                      Icons.nightlight_round,
                      size: 15 * s,
                      color: p.body,
                    ),
                    SizedBox(width: 8 * s),
                    figmaText(
                      'Evening wind-down ritual',
                      size: 12 * s,
                      weight: FontWeight.w400,
                      letterSpacing: 0.12 * s,
                      lineHeight: 16 * s,
                      color: _brown,
                    ),
                    Spacer(),
                    figmaText(
                      'PRIME TIME',
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.5 * s,
                      lineHeight: 12 * s,
                      color: p.emberDeep,
                    ),
                    SizedBox(width: 16 * s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.stroke});

  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2 - 5.5;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = p.container;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = p.ember;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * 0.76, false, progress);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.stroke != stroke;
}
