import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';


/// The progress arc used for "Consistency", "Daily Pulse", "Target" rings.
class SparkRing extends StatelessWidget {
  const SparkRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.colors,
    this.trackColor,
    this.child,
    this.startAngle = -math.pi / 2,
    this.sweepMultiplier = 1.0,
  });

  /// 0.0 → 1.0
  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color>? colors;
  final Color? trackColor;
  final Widget? child;
  final double startAngle;
  final double sweepMultiplier;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          colors: colors ?? [p.ember, p.emberDeep],
          track: trackColor ?? (isDark ? p.panel : p.container),
          startAngle: startAngle,
          sweepMultiplier: sweepMultiplier,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
    required this.track,
    required this.startAngle,
    required this.sweepMultiplier,
  });

  final double progress;
  final double strokeWidth;
  final List<Color> colors;
  final Color track;
  final double startAngle;
  final double sweepMultiplier;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = track;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (progress <= 0) return;

    final sweep = math.pi * 2 * progress * sweepMultiplier;
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + math.pi * 2,
        colors: [...colors, colors.first],
        transform: GradientRotation(startAngle),
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.colors != colors || old.track != track;
}
