import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Progress · Habit Consistency row — Figma 358 × 88, r16.
class ConsistencyRow extends StatelessWidget {
  const ConsistencyRow({
    super.key,
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.accent,
    required this.fill,
    required this.fillWidth,
    required this.icon,
  });

  final double scale;
  final String title;
  final String subtitle;
  final String percent;
  final Color accent;
  final Color fill;
  final double fillWidth;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 88 * s,
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 16 * s,
            child: Container(
              width: 40 * s,
              height: 40 * s,
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(12 * s),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6 * s,
                    offset: Offset(0, 2 * s),
                  ),
                ],
              ),
              child: Icon(icon, size: 19 * s, color: accent),
            ),
          ),
          Positioned(
            left: 64 * s,
            top: 15 * s,
            child: figmaText(
              title,
              size: 16 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.08 * s,
              lineHeight: 22 * s,
              color: p.ink,
            ),
          ),
          Positioned(
            left: 64 * s,
            top: 39 * s,
            child: figmaText(
              subtitle,
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: p.body,
            ),
          ),
          Positioned(
            right: 16 * s,
            top: 24 * s,
            child: figmaText(
              percent,
              size: 16 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.08 * s,
              lineHeight: 22 * s,
              color: accent,
            ),
          ),
          Positioned(
            left: 16 * s,
            top: 64 * s,
            child: Container(
              width: 326 * s,
              height: 8 * s,
              decoration: BoxDecoration(
                color: p.container,
                borderRadius: BorderRadius.circular(999 * s),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: fillWidth * s,
                  height: 8 * s,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(999 * s),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
