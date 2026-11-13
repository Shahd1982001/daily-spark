import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// PAGE 2 visual — "7-Day Streak In Flow" card with orbit badges.
/// Figma: node 126:13517, visual area 358 × 356 at (16, 96).
class StreakFlowCard extends StatelessWidget {
  const StreakFlowCard({super.key});

  static const _ink = Color(0xFF191C1A);
  static const _brown = Color(0xFF57423B);
  static const _ember = Color(0xFFFF6B2C);
  static const _deepEmber = Color(0xFF9F3C16);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 358,
      height: 356,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Warm ambient glow
          Positioned(
            left: 59,
            top: 58,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                color: Color(0x4DFFDBCF),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Concentric orbit rings (hairline borders)
          Positioned(
            left: 24,
            top: 22,
            child: _ring(310, 311),
          ),
          Positioned(
            left: 59,
            top: 58,
            child: _ring(240, 241),
          ),

          // Top floating micro-badge
          Positioned(
            left: 165,
            top: 16,
            child: _floatingBadge(
              width: 143,
              height: 33,
              icon: Icons.local_fire_department_rounded,
              iconSize: 9,
              iconColor: _deepEmber,
              label: 'Day 7 · Streak Master',
              labelSize: 11,
            ),
          ),

          // Bottom floating micro-badge
          Positioned(
            left: 76,
            top: 273,
            child: _floatingBadge(
              width: 120,
              height: 32,
              icon: Icons.link_rounded,
              iconSize: 13,
              iconColor: const Color(0xFF3A6750),
              label: 'Unbroken chain',
              labelSize: 11,
            ),
          ),

          // Main card
          Positioned(
            left: 21,
            top: 81,
            child: Container(
              width: 316,
              height: 194,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Header tags
                  Positioned(
                    left: 16,
                    top: 18,
                    child: Container(
                      width: 143,
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
                            '7-Day Streak In Flow',
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
                    child: Container(
                      width: 109,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.trending_up_rounded,
                              size: 10, color: Color(0xFF3A6750)),
                          const SizedBox(width: 4),
                          figmaText(
                            '+18% vs Last Wk',
                            size: 10,
                            weight: FontWeight.w600,
                            lineHeight: 20,
                            color: const Color(0xFF10B981),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Week timeline
                  const Positioned(left: 16, top: 60, child: _WeekRow()),

                  // Ritual strip
                  Positioned(
                    left: 16,
                    top: 132,
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEEEB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.nightlight_round,
                              size: 15, color: _deepEmber),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 186,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              figmaText(
                                'Evening Reading & Wind-down',
                                size: 12,
                                weight: FontWeight.w600,
                                letterSpacing: 0.24,
                                lineHeight: 15,
                                color: _ink,
                              ),
                              figmaText(
                                'Daily ritual · 20 mins complete',
                                size: 11,
                                weight: FontWeight.w400,
                                lineHeight: 20,
                                color: _brown,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: figmaText(
                            'Locked',
                            size: 11,
                            weight: FontWeight.w600,
                            lineHeight: 20,
                            color: const Color(0xFF3A6750),
                          ),
                        ),
                      ],
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

  Widget _ring(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x228A726A), width: 1),
      ),
    );
  }

  Widget _floatingBadge({
    required double width,
    required double height,
    required IconData icon,
    required double iconSize,
    required Color iconColor,
    required String label,
    required double labelSize,
  }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            size: labelSize,
            weight: FontWeight.w500,
            lineHeight: 20,
            color: _brown,
          ),
        ],
      ),
    );
  }
}

/// Seven day nodes: 28 px ember circles with white checks, "Today" last.
class _WeekRow extends StatelessWidget {
  const _WeekRow();

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 284,
      height: 68,
      child: Stack(
        children: [
          // Connector line
          Positioned(
            left: 14,
            top: 50,
            child: Container(width: 256, height: 2, color: const Color(0xFFEDEEEB)),
          ),
          for (var i = 0; i < 7; i++)
            Positioned(
              left: i * 41.0,
              top: 0,
              child: SizedBox(
                width: 37,
                child: Column(
                  children: [
                    if (i == 6)
                      Text(
                        'Today',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 2,
                          color: Color(0xFF9F3C16),
                          decoration: TextDecoration.none,
                        ),
                      )
                    else
                      Text(
                        _letters[i],
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 2,
                          color: Color(0xFF57423B),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B2C),
                        shape: BoxShape.circle,
                      ),
                      child: i == 6
                          ? const Icon(Icons.arrow_forward_rounded,
                              size: 13, color: Colors.white)
                          : const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white),
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
