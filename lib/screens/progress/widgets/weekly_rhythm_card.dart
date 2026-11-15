import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/state/progress_providers.dart' show RhythmDay;

/// Progress · Weekly Rhythm — Figma 358 × 248, r16.
class WeeklyRhythmCard extends StatelessWidget {
  WeeklyRhythmCard({super.key, required this.scale, this.days = const []});

  final double scale;

  /// Last 7 days, oldest first (index 6 = today).
  final List<RhythmDay> days;

  static Color get _brown => p.body;
  static Color get _ink => p.ink;

  // label, fill height, fill colour, weekday letter, letter weight
  // Bar artwork keeps the same pigment in both themes (dark frame 163:3760).
  static const _barSage = Color(0xFF3A6750);
  static const _barGold = Color(0xFF9F6A00);
  static const _barEmber = Color(0xFF9F3C16);

  /// Light cream wells in dark mode, warm grey wells in light mode.
  static Color get _well => p.dark ? const Color(0xFFEDEEEB) : p.container;
  static Color get _wellToday => p.dark ? const Color(0xFFFFDBCF) : p.emberSoft;

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  List<_BarData> get _bars => [
        for (final day in days)
          _BarData(
            '${day.percent}%',
            74 + (day.percent / 100).clamp(0.0, 1.0) * 50,
            day.percent >= 90
                ? _barGold
                : day.percent >= 70
                    ? _barSage
                    : day.percent >= 40
                        ? _barEmber
                        : _well,
            _letters[day.day.weekday - 1],
            day.isToday ? FontWeight.w700 : FontWeight.w500,
            day.isToday
                ? p.emberDeep
                : (day.percent >= 90 ? p.ink : p.body),
          ),
      ];

  int get _peakIndex {
    if (days.isEmpty) return -1;
    var best = 0;
    for (var i = 1; i < days.length; i++) {
      if (days[i].percent > days[best].percent) best = i;
    }
    return days[best].percent > 0 ? best : -1;
  }

  static const _columnLeft = <double>[4, 51, 97, 144, 190, 237, 283];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 248 * s,
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < _bars.length; i++)
            Positioned(
              left: (16 + _columnLeft[i]) * s,
              top: 32 * s,
              width: 39 * s,
              height: 171 * s,
              child: _Column(
                data: _bars[i],
                scale: s,
                isToday: i == _bars.length - 1,
                isPeak: i == _peakIndex,
              ),
            ),
          // NOW chip
          Positioned(
            left: (16 + _columnLeft[(_bars.length - 1).clamp(0, 6)]) * s,
            top: 21 * s,
            child: Container(
              width: 30 * s,
              height: 13 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.dark ? const Color(0xFFF5F3EF) : p.emberDeep,
                borderRadius: BorderRadius.circular(4 * s),
              ),
              child: figmaText(
                'NOW',
                size: 9 * s,
                weight: FontWeight.w400,
                letterSpacing: 0.45 * s,
                lineHeight: 11 * s,
                color: p.dark ? _barEmber : p.surface,
              ),
            ),
          ),
          // micro ribbon
          Positioned(
            left: 16 * s,
            top: 200 * s,
            width: 326 * s,
            height: 32 * s,
            child: Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12 * s),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 13 * s, color: p.emberDeep),
                  SizedBox(width: 6 * s),
                  figmaText(
                    days.isEmpty
                        ? 'Today'
                        : '${_weekdayName(days.last.day)} (Today)',
                    size: 12 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: _ink,
                  ),
                  Spacer(),
                  figmaText(
                    days.isEmpty || days.last.percent == 0
                        ? 'Nothing completed yet today'
                        : '${days.last.percent}% of today fulfilled',
                    size: 12 * s,
                    weight: FontWeight.w600,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: p.emberDeep,
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

String _weekdayName(DateTime day) => const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][day.weekday - 1];

class _BarData {
  const _BarData(this.label, this.height, this.fill, this.letter, this.weight,
      this.letterColor);

  final String label;
  final double height;
  final Color fill;
  final String letter;
  final FontWeight weight;
  final Color letterColor;
}

class _Column extends StatelessWidget {
  const _Column({
    required this.data,
    required this.scale,
    required this.isToday,
    required this.isPeak,
  });

  final _BarData data;
  final double scale;
  final bool isToday;
  final bool isPeak;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 19 * s,
          child: isPeak
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 7 * s),
                    child: Icon(Icons.star_rounded,
                        size: 12 * s, color: p.ochre),
                  ),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: figmaText(
                    data.label,
                    size: 10 * s,
                    weight: isToday ? FontWeight.w600 : FontWeight.w400,
                    lineHeight: 15 * s,
                    color: isToday
                        ? p.emberDeep
                        : p.body,
                  ),
                ),
        ),
        SizedBox(
          width: 39 * s,
          height: 128 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (isToday)
                Positioned(
                  left: -4 * s,
                  top: -4 * s,
                  child: Container(
                    width: 47 * s,
                    height: 136 * s,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(23.5 * s),
                      ),
                      border: Border.all(
                        color: p.emberDeep,
                        width: 2.5 * s,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 39 * s,
                  height: 128 * s,
                  decoration: BoxDecoration(
                    color: isToday
                        ? WeeklyRhythmCard._wellToday
                        : WeeklyRhythmCard._well,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(19.5 * s),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 2 * s,
                bottom: 2 * s,
                child: Container(
                  width: 35 * s,
                  height: data.height * s,
                  decoration: BoxDecoration(
                    color: data.fill,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(17.5 * s),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 24 * s,
          child: Padding(
            padding: EdgeInsets.only(top: 8 * s),
            child: figmaText(
              data.letter,
              size: 12 * s,
              weight: data.weight,
              letterSpacing: 0.24 * s,
              lineHeight: 16 * s,
              color: data.letterColor,
            ),
          ),
        ),
      ],
    );
  }
}
