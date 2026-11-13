import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Progress · Weekly Rhythm — Figma 358 × 248, r16.
class WeeklyRhythmCard extends StatelessWidget {
  const WeeklyRhythmCard({super.key, required this.scale});

  final double scale;

  static const _brown = Color(0xFF57423B);
  static const _ink = Color(0xFF191C1A);

  // label, fill height, fill colour, weekday letter, letter weight
  static const _bars = <_BarData>[
    _BarData('85%', 105, Color(0xFF3A6750), 'M', FontWeight.w500,
        Color(0xFF57423B)),
    _BarData('70%', 87, Color(0xFF3A6750), 'T', FontWeight.w500,
        Color(0xFF57423B)),
    _BarData('100%', 124, Color(0xFF9F6A00), 'W', FontWeight.w700, _ink),
    _BarData('90%', 112, Color(0xFF3A6750), 'T', FontWeight.w500,
        Color(0xFF57423B)),
    _BarData('80%', 99, Color(0xFF9F3C16), 'F', FontWeight.w700,
        Color(0xFF9F3C16)),
    _BarData('60%', 74, Color(0xFFE1E3DF), 'S', FontWeight.w500, _brown),
    _BarData('75%', 93, Color(0xFFE1E3DF), 'S', FontWeight.w500, _brown),
  ];

  static const _columnLeft = <double>[4, 51, 97, 144, 190, 237, 283];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 248 * s,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F0),
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
                isToday: i == 4,
                isPeak: i == 2,
              ),
            ),
          // NOW chip
          Positioned(
            left: 211 * s,
            top: 21 * s,
            child: Container(
              width: 30 * s,
              height: 13 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF9F3C16),
                borderRadius: BorderRadius.circular(4 * s),
              ),
              child: figmaText(
                'NOW',
                size: 9 * s,
                weight: FontWeight.w400,
                letterSpacing: 0.45 * s,
                lineHeight: 11 * s,
                color: Colors.white,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12 * s),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 13 * s, color: const Color(0xFF9F3C16)),
                  SizedBox(width: 6 * s),
                  figmaText(
                    'Friday (Today)',
                    size: 12 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: _ink,
                  ),
                  const Spacer(),
                  figmaText(
                    '4 of 5 habits fulfilled',
                    size: 12 * s,
                    weight: FontWeight.w600,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: const Color(0xFF9F3C16),
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
                        size: 12 * s, color: const Color(0xFF7E5300)),
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
                        ? const Color(0xFF9F3C16)
                        : const Color(0xFF57423B),
                  ),
                ),
        ),
        SizedBox(
          width: 39 * s,
          height: 128 * s,
          child: Stack(
            children: [
              if (isToday)
                Positioned(
                  left: -4 * s,
                  top: -4 * s,
                  child: Container(
                    width: 47 * s,
                    height: 136 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9F3C16),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(23.5 * s),
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
                        ? const Color(0xFFFFDBCF)
                        : const Color(0xFFEDEEEB),
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
