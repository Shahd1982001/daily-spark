import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Progress · Streak card — Figma 358 × 199, r24, ember gradient.
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24 * s),
      child: Container(
        width: 358 * s,
        height: 199 * s,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8A54), Color(0xFFFF6B2C)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 230 * s,
              top: 71 * s,
              child: Container(
                width: 160 * s,
                height: 160 * s,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x4DFDBA54),
                ),
              ),
            ),
            // icon tile
            Positioned(
              left: 24 * s,
              top: 24 * s,
              child: Container(
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16 * s),
                ),
                child: Icon(Icons.local_fire_department_rounded,
                    size: 22 * s, color: const Color(0xFFFFDBCF)),
              ),
            ),
            Positioned(
              left: 80 * s,
              top: 22 * s,
              child: Row(
                children: [
                  figmaText(
                    '12-Day Streak',
                    size: 22 * s,
                    weight: FontWeight.w600,
                    letterSpacing: -0.33 * s,
                    lineHeight: 28 * s,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4 * s),
                  Icon(Icons.auto_awesome_rounded,
                      size: 16 * s, color: const Color(0xFFFDBA54)),
                ],
              ),
            ),
            Positioned(
              left: 80 * s,
              top: 52 * s,
              child: figmaText(
                'Personal best: 18 days · 6 days to record!',
                size: 12 * s,
                weight: FontWeight.w500,
                letterSpacing: 0.24 * s,
                lineHeight: 16 * s,
                color: const Color(0xFFFFB59C),
              ),
            ),
            // pathway
            Positioned(
              left: 40 * s,
              top: 88 * s,
              child: SizedBox(
                width: 310 * s,
                height: 51 * s,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 24 * s,
                      top: 24 * s,
                      child: Container(
                        width: 262 * s,
                        height: 4 * s,
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    Positioned(
                      left: 24 * s,
                      top: 24 * s,
                      child: Container(
                        width: 192 * s,
                        height: 4 * s,
                        color: const Color(0xFFFDBA54),
                      ),
                    ),
                    _step(s, left: 8, top: 2, size: 28, label: 'Day 7',
                        done: true),
                    _step(s, left: 95, top: 2, size: 28, label: 'Day 10',
                        done: true),
                    _step(
                      s,
                      left: 182,
                      top: 0,
                      size: 32,
                      label: 'Today',
                      active: true,
                      labelColor: Colors.white,
                      labelWeight: FontWeight.w700,
                    ),
                    _step(s, left: 273, top: 2, size: 28, label: 'Day 14',
                        trophy: true, labelColor: const Color(0xFFFFB59C)),
                  ],
                ),
              ),
            ),
            // quote
            Positioned(
              left: 24 * s,
              top: 155 * s,
              child: Row(
                children: [
                  Icon(Icons.format_quote_rounded,
                      size: 15 * s, color: const Color(0xFFFDBA54)),
                  SizedBox(width: 8 * s),
                  figmaText(
                    '"Consistency is your quiet superpower."',
                    size: 12 * s,
                    weight: FontWeight.w400,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(
    double s, {
    required double left,
    required double top,
    required double size,
    required String label,
    bool done = false,
    bool active = false,
    bool trophy = false,
    Color labelColor = const Color(0xFFFFDBCF),
    FontWeight labelWeight = FontWeight.w400,
  }) {
    const labelWidth = 46.0;
    return Positioned(
      left: (left - (labelWidth - size) / 2) * s,
      top: top * s,
      width: labelWidth * s,
      child: Column(
        children: [
          Center(
            child: Container(
              width: size * s,
              height: size * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? Colors.white
                    : done
                        ? const Color(0xFFFDBA54)
                        : Colors.white.withValues(alpha: 0.20),
              ),
              child: Icon(
                active
                    ? Icons.local_fire_department_rounded
                    : done
                        ? Icons.check_rounded
                        : Icons.emoji_events_rounded,
                size: (active ? 14 : done ? 12 : 11) * s,
                color: active
                    ? const Color(0xFF9F3C16)
                    : done
                        ? const Color(0xFF291800)
                        : Colors.white,
              ),
            ),
          ),
          SizedBox(height: 4 * s),
          figmaText(
            label,
            size: 10 * s,
            weight: labelWeight,
            lineHeight: 15 * s,
            color: labelColor,
          ),
        ],
      ),
    );
  }
}
