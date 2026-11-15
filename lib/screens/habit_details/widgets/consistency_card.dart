import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/state/details_providers.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Month consistency calendar on Habit Details.
/// Figma: 358 × 390 at (16, 718) — the height follows the number of weeks in
/// the month so a six-week month never spills past the legend.
class ConsistencyCard extends StatelessWidget {
  const ConsistencyCard({
    super.key,
    required this.scale,
    required this.detail,
  });

  final double scale;
  final HabitDetail detail;

  static Color get _ink => p.ink;
  static Color get _brown => p.body;

  static const _cell = 39.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final rows = ((detail.monthStartOffset + detail.monthDays.length) / 7).ceil();
    final gridTop = 114.0;
    final legendTop = gridTop + rows * (_cell + _gap) - _gap + 16;
    final height = legendTop + 40;

    return Container(
      width: 358 * s,
      height: height * s,
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
              '${detail.monthLabel} Consistency',
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
              detail.monthScheduled == 0
                  ? 'No scheduled days yet this month'
                  : '${detail.monthCompleted} completed '
                      '${detail.monthCompleted == 1 ? 'day' : 'days'} '
                      '(${detail.monthPercent}% consistency)',
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
              '${detail.year}',
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
            top: gridTop * s,
            child: SizedBox(
              width: 310 * s,
              child: Wrap(
                spacing: _gap * s,
                runSpacing: _gap * s,
                children: [
                  for (var i = 0; i < detail.monthStartOffset; i++)
                    _cellBox(s, null),
                  for (final day in detail.monthDays) _cellBox(s, day),
                ],
              ),
            ),
          ),
          // legend
          Positioned(
            left: 24 * s,
            top: legendTop * s,
            child: Row(
              children: [
                _LegendDot(scale: s, color: p.dark ? p.ember : p.emberDeep),
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

  Widget _cellBox(double s, DetailDay? day) {
    if (day == null) {
      return SizedBox(width: _cell * s, height: _cell * s);
    }

    final Color background;
    final Color textColour;
    final FontWeight weight;

    if (day.isToday) {
      background = p.sage;
      textColour = Colors.white;
      weight = FontWeight.w700;
    } else if (day.completed) {
      // Light: deep ember. Dark: the brighter ember so the cell still reads
      // against the near-black card (same as the Figma dark frame).
      background = p.dark ? p.ember : p.emberDeep;
      textColour = Colors.white;
      weight = FontWeight.w600;
    } else if (day.beforeStart || day.inFuture) {
      background = p.panel;
      textColour = p.body.withValues(alpha: 0.4);
      weight = FontWeight.w600;
    } else if (day.scheduled) {
      background = p.container;
      textColour = p.body;
      weight = FontWeight.w600;
    } else {
      background = p.panel;
      textColour = p.ink;
      weight = FontWeight.w600;
    }

    return Container(
      width: _cell * s,
      height: _cell * s,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8 * s),
      ),
      child: Center(
        child: figmaText(
          '${day.day}',
          size: 10 * s,
          weight: weight,
          letterSpacing: 0.4 * s,
          lineHeight: 12 * s,
          color: textColour,
        ),
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
