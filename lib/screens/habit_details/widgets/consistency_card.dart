import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// "November Consistency" calendar card on Habit Details.
/// Figma: 358 × 390 at (16, 718).
class ConsistencyCard extends StatelessWidget {
  const ConsistencyCard({super.key, required this.scale});

  final double scale;

  static const _ink = Color(0xFF191C1A);
  static const _brown = Color(0xFF57423B);

  /// day label, background, text colour, bold
  static const List<List<Object>> _days = [
    ['28', Color(0xFFF3F4F0), Color(0x6657423B), false],
    ['29', Color(0xFFF3F4F0), Color(0x6657423B), false],
    ['30', Color(0xFFF3F4F0), Color(0x6657423B), false],
    ['1', Color(0xFF9F3C16), Colors.white, false],
    ['2', Color(0xFF9F3C16), Colors.white, false],
    ['3', Color(0xFFEDEEEB), Color(0xFF57423B), false],
    ['4', Color(0xFF9F3C16), Colors.white, false],
    ['5', Color(0xFF9F3C16), Colors.white, false],
    ['6', Color(0xFF9F3C16), Colors.white, false],
    ['7', Color(0xFF9F3C16), Colors.white, false],
    ['8', Color(0xFF9F3C16), Colors.white, false],
    ['9', Color(0xFFEDEEEB), Color(0xFF57423B), false],
    ['10', Color(0xFF9F3C16), Colors.white, false],
    ['11', Color(0xFF9F3C16), Colors.white, false],
    ['12', Color(0xFF9F3C16), Colors.white, false],
    ['13', Color(0xFF9F3C16), Colors.white, false],
    ['14', Color(0xFF9F3C16), Colors.white, false],
    ['15', Color(0xFF9F3C16), Colors.white, false],
    ['16', Color(0xFF9F3C16), Colors.white, false],
    ['17', Color(0xFF9F3C16), Colors.white, false],
    ['18', Color(0xFF9F3C16), Colors.white, false],
    ['19', Color(0xFF9F3C16), Colors.white, false],
    ['20', Color(0xFF9F3C16), Colors.white, false],
    ['21', Color(0xFF9F3C16), Colors.white, false],
    ['22', Color(0xFF9F3C16), Colors.white, false],
    ['23', Color(0xFF9F3C16), Colors.white, false],
    ['24', Color(0xFF3A6750), Colors.white, true],
    ['25', Color(0xFFF3F4F0), Color(0xFF191C1A), false],
    ['26', Color(0xFFF3F4F0), Color(0xFF191C1A), false],
    ['27', Color(0xFFF3F4F0), Color(0xFF191C1A), false],
    ['28', Color(0xFFF3F4F0), Color(0xFF191C1A), false],
    ['29', Color(0xFFF3F4F0), Color(0xFF191C1A), false],
    ['30', Color(0xFFF3F4F0), Color(0xFF191C1A), false],
    ['1', Color(0xFFF3F4F0), Color(0x6657423B), false],
    ['2', Color(0xFFF3F4F0), Color(0x6657423B), false],
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 390 * s,
      decoration: BoxDecoration(
        color: Colors.white,
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
            left: 24 * s,
            top: 24 * s,
            child: figmaText(
              'November Consistency',
              size: 16 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.08 * s,
              lineHeight: 22 * s,
              color: _ink,
            ),
          ),
          Positioned(
            left: 24 * s,
            top: 46 * s,
            child: figmaText(
              '26 completed days (84% consistency)',
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: _brown,
            ),
          ),
          Positioned(
            left: 302 * s,
            top: 35 * s,
            child: figmaText(
              '2024',
              size: 12 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.24 * s,
              lineHeight: 16 * s,
              color: _brown,
            ),
          ),
          // weekday header
          Positioned(
            left: 24 * s,
            top: 78 * s,
            child: SizedBox(
              width: 310 * s,
              height: 20 * s,
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    SizedBox(
                      width: 41 * s,
                      child: figmaText(
                        const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                        size: 10 * s,
                        weight: FontWeight.w600,
                        letterSpacing: 0.5 * s,
                        lineHeight: 12 * s,
                        align: TextAlign.center,
                        width: 41 * s,
                        color: _brown,
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          // day grid
          Positioned(
            left: 24 * s,
            top: 114 * s,
            child: SizedBox(
              width: 310 * s,
              child: Wrap(
                spacing: 6 * s,
                runSpacing: 6 * s,
                children: [
                  for (final day in _days)
                    Container(
                      width: 39 * s,
                      height: 39 * s,
                      decoration: BoxDecoration(
                        color: day[1] as Color,
                        borderRadius: BorderRadius.circular(8 * s),
                      ),
                      child: Center(
                        child: figmaText(
                          day[0] as String,
                          size: 10 * s,
                          weight: day[3] == true ? FontWeight.w700 : FontWeight.w600,
                          letterSpacing: 0.4 * s,
                          lineHeight: 12 * s,
                          color: day[2] as Color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // legend
          Positioned(
            left: 24 * s,
            top: 350 * s,
            child: Row(
              children: [
                _LegendDot(scale: s, color: const Color(0xFF9F3C16)),
                SizedBox(width: 6 * s),
                _legendText(s, 'Completed'),
                SizedBox(width: 30 * s),
                _LegendDot(scale: s, color: const Color(0xFF3A6750)),
                SizedBox(width: 6 * s),
                _legendText(s, 'Today'),
                SizedBox(width: 30 * s),
                _LegendDot(scale: s, color: const Color(0xFFEDEEEB)),
                SizedBox(width: 6 * s),
                _legendText(s, 'Missed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendText(double s, String text) => figmaText(
        text,
        size: 10 * s,
        weight: FontWeight.w600,
        letterSpacing: 0.4 * s,
        lineHeight: 12 * s,
        color: const Color(0xFF57423B),
      );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.scale, required this.color});

  final double scale;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10 * scale,
      height: 10 * scale,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2 * scale),
      ),
    );
  }
}
