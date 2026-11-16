import 'package:daily_spark/l10n/strings.dart';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Hero momentum card on Habit Details.
/// Figma: "Habit Visual Momentum Hero" 358 × 208 at (16, 202).
class DetailsHeroCard extends StatelessWidget {
  const DetailsHeroCard({
    super.key,
    required this.scale,
    required this.weekPercent,
    required this.streak,
    required this.headline,
    required this.subline,
    required this.trendLabel,
    required this.anchorLabel,
    required this.primeTag,
    required this.isEvening,
  });

  final double scale;

  /// 0–100 completion of the last seven scheduled days.
  final int weekPercent;
  final int streak;
  final String headline;
  final String subline;
  final String trendLabel;

  /// `8:00 AM · Morning ritual` or `Anytime during the day`.
  final String anchorLabel;

  /// `PRIME TIME` / `FLEXIBLE`.
  final String primeTag;
  final bool isEvening;

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
                  painter: _GaugePainter(
                    stroke: 8.96 * s,
                    percent: weekPercent,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        figmaText(
                          '$weekPercent%',
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
                      tr('{n} Day Streak', {'n': '$streak'}),
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
                headline,
                size: 16 * s,
                weight: FontWeight.w600,
                letterSpacing: -0.08 * s,
                lineHeight: 22 * s,
                color: _ink,
                width: 198 * s,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 136 * s,
              top: 92 * s,
              child: figmaText(
                subline,
                size: 12 * s,
                weight: FontWeight.w400,
                letterSpacing: 0.12 * s,
                lineHeight: 16 * s,
                color: _brown,
                width: 198 * s,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                    trendLabel,
                    size: 10 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.4 * s,
                    lineHeight: 12 * s,
                    color: p.sage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      isEvening
                          ? Icons.nightlight_round
                          : Icons.wb_sunny_outlined,
                      size: 15 * s,
                      color: p.body,
                    ),
                    SizedBox(width: 8 * s),
                    figmaText(
                      anchorLabel,
                      width: 170 * s,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      size: 12 * s,
                      weight: FontWeight.w400,
                      letterSpacing: 0.12 * s,
                      lineHeight: 16 * s,
                      color: _brown,
                    ),
                    Spacer(),
                    figmaText(
                      primeTag,
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
  _GaugePainter({required this.stroke, required this.percent});

  final double stroke;

  /// 0–100.
  final int percent;

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
    if (percent <= 0) return;
    final sweep = math.pi * 2 * (percent.clamp(0, 100) / 100);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.stroke != stroke || oldDelegate.percent != percent;
}
