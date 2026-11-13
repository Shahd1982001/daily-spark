import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// "Today's completion" card on Habit Details.
/// Figma: 358 × 260 at (16, 434).
class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({
    super.key,
    required this.scale,
    this.onDecrement,
    this.onPlusFive,
    this.onPlusTen,
    this.onToggleComplete,
  });

  final double scale;
  final VoidCallback? onDecrement;
  final VoidCallback? onPlusFive;
  final VoidCallback? onPlusTen;
  final VoidCallback? onToggleComplete;

  static Color get _ink => p.ink;
  static Color get _brown => p.body;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 260 * s,
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
              "TODAY'S PROGRESS",
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: _brown,
            ),
          ),
          Positioned(
            left: 24 * s,
            top: 38 * s,
            width: 200 * s,
            child: figmaText(
              'Target: 20 Pages',
              size: 18 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.18 * s,
              lineHeight: 24 * s,
              color: _ink,
            ),
          ),
          Positioned(
            left: 235 * s,
            top: 43 * s,
            child: Container(
              width: 99 * s,
              height: 24 * s,
              decoration: BoxDecoration(
                color: p.mint,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 13 * s,
                    height: 13 * s,
                    decoration: BoxDecoration(
                      color: p.pineDark,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded, size: 9 * s, color: Colors.white),
                  ),
                  SizedBox(width: 6 * s),
                  figmaText(
                    'Complete!',
                    size: 12 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.24 * s,
                    lineHeight: 16 * s,
                    color: p.pineDark,
                  ),
                ],
              ),
            ),
          ),
          // progress bar
          Positioned(
            left: 24 * s,
            top: 102 * s,
            child: Container(
              width: 310 * s,
              height: 10 * s,
              decoration: BoxDecoration(
                color: p.container,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: p.sage,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          // stepper
          Positioned(
            left: 24 * s,
            top: 128 * s,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                figmaText(
                  '20',
                  size: 22 * s,
                  weight: FontWeight.w700,
                  letterSpacing: -0.33 * s,
                  lineHeight: 28 * s,
                  color: _ink,
                ),
                SizedBox(width: 4 * s),
                figmaText(
                  '/ 20 pages',
                  size: 14 * s,
                  weight: FontWeight.w400,
                  lineHeight: 20 * s,
                  color: _brown,
                ),
              ],
            ),
          ),
          Positioned(
            left: 172 * s,
            top: 132 * s,
            child: _StepperButton(
              scale: s,
              width: 40,
              onTap: onDecrement,
              child: Icon(Icons.remove_rounded, size: 16 * s, color: _ink),
            ),
          ),
          Positioned(
            left: 216 * s,
            top: 132 * s,
            child: _StepperButton(
              scale: s,
              width: 32,
              onTap: onPlusFive,
              child: figmaText(
                '+5',
                size: 12 * s,
                weight: FontWeight.w500,
                letterSpacing: 0.24 * s,
                lineHeight: 16 * s,
                color: _ink,
              ),
            ),
          ),
          Positioned(
            left: 252 * s,
            top: 132 * s,
            child: _StepperButton(
              scale: s,
              width: 38,
              onTap: onPlusTen,
              child: figmaText(
                '+10',
                size: 12 * s,
                weight: FontWeight.w500,
                letterSpacing: 0.24 * s,
                lineHeight: 16 * s,
                color: _ink,
              ),
            ),
          ),
          Positioned(
            left: 294 * s,
            top: 132 * s,
            child: GestureDetector(
              onTap: onToggleComplete,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 40 * s,
                height: 40 * s,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF16C48C), p.success],
                  ),
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: Icon(Icons.check_rounded, size: 18 * s, color: Colors.white),
              ),
            ),
          ),
          // spark insight
          Positioned(
            left: 24 * s,
            top: 188 * s,
            child: Container(
              width: 310 * s,
              height: 48 * s,
              decoration: BoxDecoration(
                color: p.panel,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Row(
                children: [
                  SizedBox(width: 8 * s),
                  SizedBox(
                    width: 60 * s,
                    child: Center(
                      child: figmaText(
                        'spark',
                        size: 20 * s,
                        weight: FontWeight.w400,
                        lineHeight: 24 * s,
                        color: p.sage,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: figmaText(
                      'Goal achieved today! 20 pages absorbed with pure presence.',
                      size: 12 * s,
                      weight: FontWeight.w400,
                      letterSpacing: 0.12 * s,
                      lineHeight: 16 * s,
                      color: p.pine,
                    ),
                  ),
                  SizedBox(width: 12 * s),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.scale,
    required this.width,
    required this.child,
    this.onTap,
  });

  final double scale;
  final double width;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width * s,
        height: 40 * s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.container,
          borderRadius: BorderRadius.circular(12 * s),
        ),
        child: child,
      ),
    );
  }
}
