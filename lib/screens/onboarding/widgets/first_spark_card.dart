import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// PAGE 1 visual — "The First Spark" card floating over concentric orbits.
/// Figma: node 126:13432, visual area 342 × 364 at (24, 153).
class FirstSparkCard extends StatelessWidget {
  const FirstSparkCard({super.key});

  static const _ink = Color(0xFF191C1A);
  static const _brown = Color(0xFF57423B);
  static const _ember = Color(0xFFFF6B2C);
  static const _deepEmber = Color(0xFF9F3C16);

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
            child: _circle(224, const Color(0x59FFDBCF)),
          ),
          // Concentric orbit rings
          Positioned(
            left: 26,
            top: 25,
            child: _circle(290, const Color(0x99F3F4F0)),
          ),
          Positioned(
            left: 56,
            top: 55,
            child: _circle(230, const Color(0xB3EDEEEB)),
          ),
          Positioned(
            left: 86,
            top: 85,
            child: _circle(170, const Color(0x80E7E9E5)),
          ),

          // Floating badge — momentum
          Positioned(
            left: 177,
            top: 19,
            child: _badge(
              width: 114,
              height: 24,
              background: const Color(0xFFD1FAE5),
              icon: Icons.trending_up_rounded,
              iconSize: 10,
              iconColor: const Color(0xFF3A6750),
              label: '+1% Momentum',
            ),
          ),

          // Floating badge — atomic scale
          Positioned(
            left: 72,
            top: 266,
            child: _badge(
              width: 101,
              height: 25,
              background: Colors.white,
              icon: Icons.bolt_rounded,
              iconSize: 13,
              iconColor: const Color(0xFF7E5300),
              label: 'Atomic scale',
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
                color: Colors.white,
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
                        color: const Color(0xFFFFDBCF),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Icon(Icons.local_fire_department_rounded,
                              size: 10, color: _deepEmber),
                          const SizedBox(width: 5),
                          figmaText(
                            'Day 1 · The First Spark',
                            size: 10,
                            weight: FontWeight.w600,
                            letterSpacing: 0.4,
                            lineHeight: 12,
                            color: const Color(0xFF390C00),
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
                      color: const Color(0xFF3A6750),
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
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
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
              border: Border.all(color: const Color(0xFFFFDBCF), width: 2),
            ),
          ),
          const Icon(Icons.menu_book_rounded, size: 18, color: _deepEmber),
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
