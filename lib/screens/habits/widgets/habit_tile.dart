import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Habit row used on the Habits screen (Figma: 358 × 76, radius 12).
class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.scale,
    required this.title,
    required this.meta,
    required this.streak,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.completed,
    this.streakHighlighted = false,
    this.showStreakPill = true,
    this.nextUp = false,
    this.onToggle,
    this.onTap,
  });

  final double scale;
  final String title;
  final String meta;
  final String streak;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool completed;
  final bool streakHighlighted;
  final bool showStreakPill;
  final bool nextUp;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

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
          borderRadius: BorderRadius.circular(12 * s),
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
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: Icon(icon, size: 19 * s, color: iconColor),
              ),
            ),
            // Title + streak pill / next-up badge
            Positioned(
              left: 72 * s,
              top: 19 * s,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: (nextUp ? 183 : 200) * s),
                    child: figmaText(
                      title,
                      size: 16 * s,
                      weight: FontWeight.w600,
                      letterSpacing: -0.08 * s,
                      lineHeight: 22 * s,
                      color: p.ink,
                    ),
                  ),
                  if (showStreakPill) ...[
                    SizedBox(width: 6 * s),
                    Container(
                      height: 16 * s,
                      padding: EdgeInsets.symmetric(horizontal: 6 * s),
                      decoration: BoxDecoration(
                        color: p.goldSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 10 * s,
                            color: p.ochre,
                          ),
                          SizedBox(width: 2 * s),
                          figmaText(
                            streak,
                            size: 10 * s,
                            weight: FontWeight.w600,
                            letterSpacing: 0.4 * s,
                            lineHeight: 12 * s,
                            color: p.onGold,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (nextUp) ...[
                    SizedBox(width: 2 * s),
                    Container(
                      height: 16 * s,
                      padding: EdgeInsets.symmetric(horizontal: 5 * s),
                      decoration: BoxDecoration(
                        color: p.mint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: figmaText(
                          'Next up',
                          size: 10 * s,
                          weight: FontWeight.w600,
                          letterSpacing: 0.4 * s,
                          lineHeight: 12 * s,
                          color: p.pineDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Meta line
            Positioned(
              left: 72 * s,
              top: 41 * s,
              child: Row(
                children: [
                  figmaText(
                    meta,
                    size: 12 * s,
                    weight: FontWeight.w400,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: p.body,
                  ),
                  if (streakHighlighted) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6 * s),
                      child: figmaText(
                        '\u00b7',
                        size: 14 * s,
                        weight: FontWeight.w400,
                        lineHeight: 20 * s,
                        color: p.muted,
                      ),
                    ),
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 11 * s,
                      color: p.ember,
                    ),
                    SizedBox(width: 2 * s),
                    figmaText(
                      '$streak streak',
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4 * s,
                      lineHeight: 12 * s,
                      color: p.ember,
                    ),
                  ],
                ],
              ),
            ),
            // Toggle
            Positioned(
              left: 298 * s,
              top: 16 * s,
              child: GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 44 * s,
                  height: 44 * s,
                  decoration: BoxDecoration(
                    color: completed ? p.success : p.container,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    completed
                        ? Icons.check_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: completed ? 18 * s : 20 * s,
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
