import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Top part of the Home screen — the daily pulse & streak card.
/// Figma: node 126:15685 → "2. Motivation & Streak Bar", 358 × 168 at (16, 170).
class PulseCard extends StatelessWidget {
  const PulseCard({super.key, required this.scale});

  final double scale;

  static const _ink = Color(0xFF191C1A);
  static const _brown = Color(0xFF57423B);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 168 * s,
      decoration: BoxDecoration(
        color: Colors.white,
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
          // ── Radial progress ───────────────────────────────────────
          Positioned(
            left: 16 * s,
            top: 18 * s,
            child: SizedBox(
              width: 56 * s,
              height: 56 * s,
              child: CustomPaint(
                painter: _PulseRingPainter(stroke: 5.25 * s),
                child: Center(
                  child: figmaText(
                    '60%',
                    size: 12 * s,
                    weight: FontWeight.w700,
                    letterSpacing: 0.24 * s,
                    lineHeight: 16 * s,
                    color: _ink,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 80 * s,
            top: 22 * s,
            child: figmaText(
              'DAILY PULSE',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: _brown,
            ),
          ),
          Positioned(
            left: 80 * s,
            top: 34 * s,
            child: figmaText(
              '3 of 5',
              size: 16 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.4 * s,
              lineHeight: 22 * s,
              color: _ink,
            ),
          ),
          Positioned(
            left: 80 * s,
            top: 58 * s,
            child: Row(
              children: [
                Container(
                  width: 6 * s,
                  height: 6 * s,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4 * s),
                figmaText(
                  'On track',
                  size: 10 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.4 * s,
                  lineHeight: 12 * s,
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
          ),

          // ── Momentum / streak marker ──────────────────────────────
          Positioned(
            left: 187 * s,
            top: 16 * s,
            child: Container(
              width: 155 * s,
              height: 60 * s,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F0).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 8 * s,
                    top: 10 * s,
                    child: Container(
                      width: 40 * s,
                      height: 40 * s,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2EB),
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: 20 * s,
                        color: const Color(0xFFFF6B2C),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 56 * s,
                    top: 5 * s,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        figmaText(
                          '7',
                          size: 18 * s,
                          weight: FontWeight.w700,
                          letterSpacing: -0.18 * s,
                          lineHeight: 18 * s,
                          color: _ink,
                        ),
                        SizedBox(width: 4 * s),
                        figmaText(
                          'Days',
                          size: 10 * s,
                          weight: FontWeight.w600,
                          letterSpacing: 0.4 * s,
                          lineHeight: 12 * s,
                          color: const Color(0xFFE05316),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 56 * s,
                    top: 25 * s,
                    child: figmaText(
                      'Record: 14d',
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4 * s,
                      lineHeight: 24 * s,
                      color: _brown,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Weekly heat rhythm strip ──────────────────────────────
          Positioned(
            left: 16 * s,
            top: 92 * s,
            child: Container(
              width: 326 * s,
              height: 60 * s,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F0).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12 * s),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 8 * s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++)
                    _DayCell(
                      scale: s,
                      label: const ['Th', 'Fr', 'Sa', 'Su', 'Mo', 'Tu', 'We'][i],
                      isToday: i == 6,
                      index: i,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.scale,
    required this.label,
    required this.isToday,
    required this.index,
  });

  final double scale;
  final String label;
  final bool isToday;
  final int index;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    // The 2nd day (Fr) carries the tall "high" bar in the design.
    final highlighted = index == 1;
    return SizedBox(
      width: 28 * s,
      height: 44 * s,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (highlighted)
            Positioned(
              top: 2 * s,
              child: Container(
                width: 28 * s,
                height: 39 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(14 * s),
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              figmaText(
                label,
                size: 10 * s,
                weight: isToday ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.4 * s,
                lineHeight: 12 * s,
                color: isToday ? const Color(0xFFE05316) : const Color(0xFF57423B),
                align: TextAlign.center,
                width: 28 * s,
              ),
              SizedBox(height: 4 * s),
              Container(
                width: 28 * s,
                height: 28 * s,
                decoration: BoxDecoration(
                  color: isToday ? null : const Color(0xFFD1FAE5),
                  gradient: isToday
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF8A54), Color(0xFFFF6B2C)],
                        )
                      : null,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 12 * s,
                    color: isToday ? Colors.white : const Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  _PulseRingPainter({required this.stroke});

  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFEDEEEB);
    canvas.drawArc(rect, 0, 6.2832, false, track);

    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF10B981);
    canvas.drawArc(rect, -1.5708, 6.2832 * 0.6, false, progress);
  }

  @override
  bool shouldRepaint(covariant _PulseRingPainter oldDelegate) =>
      oldDelegate.stroke != stroke;
}
