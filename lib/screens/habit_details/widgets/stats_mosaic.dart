import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// 2 × 2 habit stats mosaic on Habit Details.
/// Figma: "Habit Stats Mosaic" 358 × 232 at (16, 1132).
class StatsMosaic extends StatelessWidget {
  StatsMosaic({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final cards = [
      ('CURRENT RUN', Icons.local_fire_department_rounded, p.ochre, '12 Days', 'Personal momentum'),
      ('BEST RECORD', Icons.emoji_events_rounded, p.emberDeep, '28 Days', 'Set in September'),
      ('TOTAL READ', Icons.menu_book_outlined, p.sage, '1,420 pgs', 'Approx. 5.6 books'),
      ('CONSISTENCY', Icons.check_circle_outline_rounded, p.pine, '88%', 'Lifetime success rate'),
    ];

    return SizedBox(
      width: 358 * s,
      height: 232 * s,
      child: Stack(
        children: [
          for (var i = 0; i < cards.length; i++)
            Positioned(
              left: (i.isEven ? 0 : 183) * s,
              top: (i < 2 ? 0 : 120) * s,
              child: _StatCard(
                scale: s,
                label: cards[i].$1,
                icon: cards[i].$2,
                iconColor: cards[i].$3,
                value: cards[i].$4,
                caption: cards[i].$5,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.scale,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.caption,
  });

  final double scale;
  final String label;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 175 * s,
      height: 112 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 16 * s,
            child: figmaText(
              label,
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: p.body,
            ),
          ),
          Positioned(
            right: 16 * s,
            top: 14 * s,
            child: Icon(icon, size: 15 * s, color: iconColor),
          ),
          Positioned(
            left: 16 * s,
            top: 51 * s,
            child: figmaText(
              value,
              size: 22 * s,
              weight: FontWeight.w700,
              letterSpacing: -0.33 * s,
              lineHeight: 28 * s,
              color: p.ink,
            ),
          ),
          Positioned(
            left: 16 * s,
            top: 80 * s,
            child: figmaText(
              caption,
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: p.body,
            ),
          ),
        ],
      ),
    );
  }
}
