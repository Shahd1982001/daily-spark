import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Editorial inspiration card (current book) on Habit Details.
/// Figma: 358 × 226 at (16, 1896).
class EditorialCard extends StatelessWidget {
  const EditorialCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 226 * s,
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── cover art placeholder (real asset to be dropped in) ──
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: 176 * s,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7B3F1C), Color(0xFF3B2417)],
                ),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 26 * s),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 96 * s,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
            ),
          ),
          // bottom white fade
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: 176 * s,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // chips
          Positioned(
            left: 16 * s,
            top: 144 * s,
            child: Row(
              children: [
                _GlassChip(scale: s, label: 'Current Read'),
                SizedBox(width: 68 * s),
                _GlassChip(scale: s, label: 'Marcus Aurelius \u00b7 Meditations'),
              ],
            ),
          ),
          // quote row
          Positioned(
            left: 16 * s,
            top: 176 * s,
            child: SizedBox(
              width: 326 * s,
              height: 50 * s,
              child: Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 15 * s,
                    color: p.emberDeep,
                  ),
                  SizedBox(width: 8 * s),
                  figmaText(
                    '\u201cQuiet minds grasp deep truths.\u201d',
                    size: 12 * s,
                    weight: FontWeight.w400,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: p.ink,
                  ),
                  Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18 * s,
                    color: p.body,
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

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.scale, required this.label});

  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 20 * s,
      padding: EdgeInsets.symmetric(horizontal: 10 * s),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: figmaText(
          label,
          size: 10 * s,
          weight: FontWeight.w500,
          letterSpacing: 0.4 * s,
          lineHeight: 12 * s,
          color: p.ink,
        ),
      ),
    );
  }
}
