import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// "Habit Loop Configuration" card on Habit Details.
/// Figma: 358 × 484 at (16, 1388).
class HabitLoopCard extends StatelessWidget {
  const HabitLoopCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 484 * s,
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
              'Habit Loop Configuration',
              size: 16 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.08 * s,
              lineHeight: 22 * s,
              color: p.ink,
            ),
          ),
          Positioned(
            right: 24 * s,
            top: 27 * s,
            child: Icon(
              Icons.info_outline_rounded,
              size: 15 * s,
              color: p.body,
            ),
          ),
          _row(
            s,
            top: 66,
            height: 110,
            icon: Icons.repeat_rounded,
            label: 'CADENCE',
            value: 'Every Day (Daily Ritual)',
          ),
          _row(
            s,
            top: 184,
            height: 90,
            icon: Icons.schedule_rounded,
            label: 'SCHEDULED ANCHOR',
            value: '08:30 PM \u00b7 Bedside Lamp loop',
          ),
          _row(
            s,
            top: 282,
            height: 70,
            icon: Icons.flag_outlined,
            label: 'TARGET DOSAGE',
            value: '20 pages / day',
          ),
          // stacking cue
          Positioned(
            left: 24 * s,
            top: 360 * s,
            child: Container(
              width: 310 * s,
              height: 96 * s,
              decoration: BoxDecoration(
                color: p.creamSoft,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20 * s, 17 * s, 20 * s, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 14 * s,
                          color: p.emberDeep,
                        ),
                        SizedBox(width: 6 * s),
                        figmaText(
                          'Habit Stacking Implementation Cue',
                          size: 12 * s,
                          weight: FontWeight.w600,
                          letterSpacing: 0.24 * s,
                          lineHeight: 16 * s,
                          color: p.emberDeep,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20 * s, 6 * s, 20 * s, 0),
                    child: figmaText(
                      '\u201cRight after I turn off the bedside lamp, I will read '
                      '20 pages.\u201d',
                      size: 14 * s,
                      weight: FontWeight.w400,
                      lineHeight: 20 * s,
                      color: p.emberDeep,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    double s, {
    required double top,
    required double height,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Positioned(
      left: 24 * s,
      top: top * s,
      child: Container(
        width: 310 * s,
        height: height * s,
        decoration: BoxDecoration(
          color: p.panel,
          borderRadius: BorderRadius.circular(12 * s),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8 * s, top: 8 * s),
              child: Container(
                width: 36 * s,
                height: 36 * s,
                decoration: BoxDecoration(
                  color: p.container,
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                child: Icon(icon, size: 17 * s, color: p.body),
              ),
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 8 * s, right: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    figmaText(
                      label,
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.5 * s,
                      lineHeight: 12 * s,
                      color: p.body,
                    ),
                    SizedBox(height: 4 * s),
                    figmaText(
                      value,
                      size: 14 * s,
                      weight: FontWeight.w600,
                      lineHeight: 20 * s,
                      color: p.ink,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
