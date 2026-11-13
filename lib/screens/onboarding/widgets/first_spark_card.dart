import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// PAGE 1 visual — "The First Spark" card floating over concentric orbits.
/// Figma: node 126:13432, visual area 342 × 364 at (24, 153).
class FirstSparkCard extends StatelessWidget {
  FirstSparkCard({super.key});

  static Color get _ink => p.ink;
  static Color get _brown => p.body;
  static Color get _ember => p.ember;
  static Color get _deepEmber => p.emberDeep;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 342,
      height: 364,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Warm ambient glow
          Positioned(
            left: 59,
            top: 58,
            child: _circle(224, p.emberSoft.withValues(alpha: 0.349)),
          ),
          // Concentric orbit rings
          Positioned(
            left: 26,
            top: 25,
            child: _circle(290, p.panel.withValues(alpha: 0.6)),
          ),
          Positioned(
            left: 56,
            top: 55,
            child: _circle(230, p.container.withValues(alpha: 0.702)),
          ),
          Positioned(
            left: 86,
            top: 85,
            child: _circle(170, p.bone.withValues(alpha: 0.502)),
          ),

          // Floating badge — momentum (tilted +2° in the design)
          Positioned(
            left: 177.3,
            top: 21,
            child: Transform.rotate(
              angle: 0.0349066,
              child: _badge(
              width: 113.4,
              height: 20,
              background: p.mintSoft,
              icon: Icons.trending_up_rounded,
              iconSize: 10,
              iconColor: p.sage,
              label: '+1% Momentum',
            ),
            ),
          ),

          // Floating badge — atomic scale (tilted −3° in the design)
          Positioned(
            left: 72.45,
            top: 268.6,
            child: Transform.rotate(
              angle: -0.0523599,
              child: _badge(
              width: 100.1,
              height: 19.8,
              background: Colors.white,
              icon: Icons.bolt_rounded,
              iconSize: 13,
              iconColor: p.ochre,
              label: 'Atomic scale',
            ),
            ),
          ),

          // The habit card
          Positioned(
            left: 31,
            top: 100,
            child: Container(
              width: 280,
              height: 140,
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Day tag
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      width: 146,
                      height: 20,
                      decoration: BoxDecoration(
                        color: p.chipEmber,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Icon(Icons.local_fire_department_rounded,
                              size: 10, color: _deepEmber),
                          SizedBox(width: 5),
                          figmaText(
                            'Day 1 · The First Spark',
                            size: 10,
                            weight: FontWeight.w600,
                            letterSpacing: 0.4,
                            lineHeight: 12,
                            color: p.onEmberSoft,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: figmaText(
                      'Morning',
                      size: 10,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4,
                      lineHeight: 12,
                      color: p.sage,
                    ),
                  ),

                  // Habit row
                  Positioned(
                    left: 16,
                    top: 48,
                    child: _avatar(),
                  ),
                  Positioned(
                    left: 80,
                    top: 48,
                    child: figmaText(
                      'Read 5 pages',
                      size: 16,
                      weight: FontWeight.w600,
                      letterSpacing: -0.08,
                      lineHeight: 22,
                      color: _ink,
                    ),
                  ),
                  Positioned(
                    left: 80,
                    top: 70,
                    child: figmaText(
                      'Quiet morning ritual',
                      size: 12,
                      weight: FontWeight.w400,
                      letterSpacing: 0.12,
                      lineHeight: 16,
                      color: _brown,
                    ),
                  ),

                  // Done check
                  Positioned(
                    left: 232,
                    top: 56,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: p.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),

                  // Commitment footer
                  Positioned(
                    left: 16,
                    top: 108,
                    child: figmaText(
                      'Commitment',
                      size: 10,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4,
                      lineHeight: 12,
                      color: _brown,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 108,
                    child: figmaText(
                      '5 mins / day',
                      size: 10,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4,
                      lineHeight: 12,
                      color: _deepEmber,
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

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _avatar() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: p.chipEmber, width: 2),
            ),
          ),
          Icon(Icons.menu_book_rounded, size: 18, color: _deepEmber),
        ],
      ),
    );
  }

  Widget _badge({
    required double width,
    required double height,
    required Color background,
    required IconData icon,
    required double iconSize,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 5),
          figmaText(
            label,
            size: 10,
            weight: FontWeight.w500,
            letterSpacing: 0.4,
            lineHeight: 12,
            color: _brown,
          ),
        ],
      ),
    );
  }
}
