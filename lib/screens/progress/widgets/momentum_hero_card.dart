import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Progress · hero momentum card — Figma 358 × 304, r24.
class MomentumHeroCard extends StatelessWidget {
  const MomentumHeroCard({
    super.key,
    required this.scale,
    this.percent = 0.78,
  });

  final double scale;
  final double percent;

  static Color get _brown => p.body;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24 * s),
      child: Container(
        width: 358 * s,
        height: 304 * s,
        color: p.panel,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ambient blobs
            Positioned(
              left: 214 * s,
              top: 24 * s,
              child: _Blob(size: 192 * s, color: p.emberDeep),
            ),
            Positioned(
              left: -48 * s,
              top: 264 * s,
              child: _Blob(size: 192 * s, color: p.ochre),
            ),
            // gauge
            Positioned(
              left: 91 * s,
              top: 28 * s,
              child: SizedBox(
                width: 176 * s,
                height: 176 * s,
                child: Stack(
                  children: [
                    Positioned(
                      left: 15.5 * s,
                      top: 15.5 * s,
                      child: CustomPaint(
                        size: Size(145 * s, 145 * s),
                        painter: _GaugePainter(progress: percent, scale: s),
                      ),
                    ),
                    Positioned(
                      top: 44 * s,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: figmaText(
                          'spark',
                          size: 16 * s,
                          weight: FontWeight.w400,
                          lineHeight: 20 * s,
                          color: p.gold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 64 * s,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          figmaText(
                            '78',
                            size: 40 * s,
                            weight: FontWeight.w700,
                            letterSpacing: -2 * s,
                            lineHeight: 46 * s,
                            color: p.ink,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16 * s),
                            child: figmaText(
                              '%',
                              size: 22 * s,
                              weight: FontWeight.w600,
                              lineHeight: 26 * s,
                              color: p.emberDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 112 * s,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: figmaText(
                          'WEEKLY HIT',
                          size: 10 * s,
                          weight: FontWeight.w600,
                          letterSpacing: 0.5 * s,
                          lineHeight: 12 * s,
                          color: _brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // streak badge
            Positioned(
              left: 79 * s,
              top: 216 * s,
              child: Container(
                height: 24 * s,
                padding: EdgeInsets.symmetric(horizontal: 12 * s),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(999 * s),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8 * s,
                      offset: Offset(0, 2 * s),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 14 * s,
                      color: p.emberDeep,
                    ),
                    SizedBox(width: 5 * s),
                    figmaText(
                      'On fire · 28 of 35 habits hit',
                      size: 12 * s,
                      weight: FontWeight.w600,
                      lineHeight: 16 * s,
                      color: p.ink,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16 * s,
              top: 248 * s,
              width: 326 * s,
              child: figmaText(
                "You've built remarkable momentum this week. Steady\n"
                'heat turns small rituals into second nature.',
                size: 12 * s,
                weight: FontWeight.w400,
                lineHeight: 16 * s,
                align: TextAlign.center,
                color: _brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.16),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress, required this.scale});

  final double progress;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 13.2 * scale;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = p.container;
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = p.ember;

    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fill);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.scale != scale;
}
