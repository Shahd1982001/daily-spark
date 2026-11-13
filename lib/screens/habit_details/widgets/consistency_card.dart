import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// "November Consistency" calendar card on Habit Details.
/// Figma: 358 × 390 at (16, 718).
class ConsistencyCard extends StatelessWidget {
  ConsistencyCard({super.key, required this.scale});

  final double scale;

  static Color get _ink => p.ink;
  static Color get _brown => p.body;

  /// day label, background, text colour, bold
  static List<List<Object>> _days = [
    ['28', p.panel, p.body.withValues(alpha: 0.4), false],
    ['29', p.panel, p.body.withValues(alpha: 0.4), false],
    ['30', p.panel, p.body.withValues(alpha: 0.4), false],
    ['1', p.emberDeep, Colors.white, false],
    ['2', p.emberDeep, Colors.white, false],
    ['3', p.container, p.body, false],
    ['4', p.emberDeep, Colors.white, false],
    ['5', p.emberDeep, Colors.white, false],
    ['6', p.emberDeep, Colors.white, false],
    ['7', p.emberDeep, Colors.white, false],
    ['8', p.emberDeep, Colors.white, false],
    ['9', p.container, p.body, false],
    ['10', p.emberDeep, Colors.white, false],
    ['11', p.emberDeep, Colors.white, false],
    ['12', p.emberDeep, Colors.white, false],
    ['13', p.emberDeep, Colors.white, false],
    ['14', p.emberDeep, Colors.white, false],
    ['15', p.emberDeep, Colors.white, false],
    ['16', p.emberDeep, Colors.white, false],
    ['17', p.emberDeep, Colors.white, false],
    ['18', p.emberDeep, Colors.white, false],
    ['19', p.emberDeep, Colors.white, false],
    ['20', p.emberDeep, Colors.white, false],
    ['21', p.emberDeep, Colors.white, false],
    ['22', p.emberDeep, Colors.white, false],
    ['23', p.emberDeep, Colors.white, false],
    ['24', p.sage, Colors.white, true],
    ['25', p.panel, p.ink, false],
    ['26', p.panel, p.ink, false],
    ['27', p.panel, p.ink, false],
    ['28', p.panel, p.ink, false],
    ['29', p.panel, p.ink, false],
    ['30', p.panel, p.ink, false],
    ['1', p.panel, p.body.withValues(alpha: 0.4), false],
    ['2', p.panel, p.body.withValues(alpha: 0.4), false],
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 390 * s,
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
                _LegendDot(scale: s, color: p.emberDeep),
                SizedBox(width: 6 * s),
                _legendText(s, 'Completed'),
                SizedBox(width: 30 * s),
                _LegendDot(scale: s, color: p.sage),
                SizedBox(width: 6 * s),
                _legendText(s, 'Today'),
                SizedBox(width: 30 * s),
                _LegendDot(scale: s, color: p.container),
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
        color: p.body,
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
