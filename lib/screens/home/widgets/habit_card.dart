import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// One habit row inside the Home routine stack.
/// Figma: node 126:15685 → "Card n", 358 × 76.
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.scale,
    required this.title,
    required this.meta,
    required this.streak,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.completed,
    this.showNextBadge = false,
    this.onToggle,
    this.onTap,
  });

  final double scale;
  final String title;
  final List<String> meta;
  final String streak;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool completed;
  final bool showNextBadge;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  static Color get _ink => p.ink;
  static Color get _brown => p.body;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 358 * s,
        height: 76 * s,
        decoration: BoxDecoration(
          color: p.surface,
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
            // Icon tile
            Positioned(
              left: 16 * s,
              top: 16 * s,
              child: Container(
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16 * s),
                ),
                child: Icon(icon, size: 19 * s, color: iconColor),
              ),
            ),
            // Title
            Positioned(
              left: 68 * s,
              top: 18 * s,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  figmaText(
                    title,
                    size: 16 * s,
                    weight: FontWeight.w600,
                    letterSpacing: -0.08 * s,
                    lineHeight: 22 * s,
                    color: _ink,
                    width: showNextBadge ? null : 230 * s,
                  ),
                  if (showNextBadge) ...[
                    SizedBox(width: 6 * s),
                    Container(
                      margin: EdgeInsets.only(top: 5 * s),
                      padding: EdgeInsets.symmetric(horizontal: 6 * s),
                      height: 12 * s,
                      decoration: BoxDecoration(
                        color: p.emberTile,
                        borderRadius: BorderRadius.circular(6 * s),
                      ),
                      child: Center(
                        child: figmaText(
                          'Next',
                          size: 10 * s,
                          weight: FontWeight.w600,
                          letterSpacing: 0.4 * s,
                          lineHeight: 12 * s,
                          color: p.emberDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Meta line
            Positioned(
              left: 68 * s,
              top: 40 * s,
              child: Row(
                children: [
                  for (var i = 0; i < meta.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 4 * s,
                        height: 4 * s,
                        margin: EdgeInsets.symmetric(horizontal: 6 * s),
                        decoration: BoxDecoration(
                          color: p.warmBorder,
                          shape: BoxShape.circle,
                        ),
                      ),
                    figmaText(
                      meta[i],
                      size: 12 * s,
                      weight: FontWeight.w400,
                      letterSpacing: 0.12 * s,
                      lineHeight: 16 * s,
                      color: _brown,
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.only(left: 6 * s),
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 12 * s,
                      color: p.ochre,
                    ),
                  ),
                  figmaText(
                    streak,
                    size: 12 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: p.ochre,
                  ),
                ],
              ),
            ),
            // Complete toggle
            Positioned(
              left: 302 * s,
              top: 18 * s,
              child: GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40 * s,
                  height: 40 * s,
                  decoration: BoxDecoration(
                    color: completed ? p.success : p.container,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16 * s,
                    color: completed ? Colors.white : p.body,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
