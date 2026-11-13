import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// PAGE 2 visual — "7-Day Streak In Flow" card with orbit badges.
/// Figma: node 126:13517, visual area 358 × 356 at (16, 96).
class StreakFlowCard extends StatelessWidget {
  StreakFlowCard({super.key});

  static Color get _ink => p.ink;
  static Color get _brown => p.body;
  static Color get _ember => p.ember;
  static Color get _deepEmber => p.emberDeep;

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
              decoration: BoxDecoration(
                color: p.chipEmber,
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

          // Top floating micro-badge (tilted +2° in the design)
          Positioned(
            left: 165.45,
            top: 18.5,
            child: Transform.rotate(
              angle: 0.0349066,
              child: _floatingBadge(
              width: 142.1,
              height: 28,
              icon: Icons.local_fire_department_rounded,
              iconSize: 9,
              iconColor: _deepEmber,
              label: 'Day 7 · Streak Master',
              labelSize: 11,
            ),
            ),
          ),

          // Bottom floating micro-badge (tilted −2° in the design)
          Positioned(
            left: 76.45,
            top: 275,
            child: Transform.rotate(
              angle: -0.0349066,
              child: _floatingBadge(
              width: 119.1,
              height: 27.9,
              icon: Icons.link_rounded,
              iconSize: 13,
              iconColor: p.sage,
              label: 'Unbroken chain',
              labelSize: 11,
            ),
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
                color: p.surface,
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
                            '7-Day Streak In Flow',
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
                    child: Container(
                      width: 109,
                      height: 24,
                      decoration: BoxDecoration(
                        color: p.mintSoft,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.trending_up_rounded,
                              size: 10, color: p.sage),
                          SizedBox(width: 4),
                          figmaText(
                            '+18% vs Last Wk',
                            size: 10,
                            weight: FontWeight.w600,
                            lineHeight: 20,
                            color: p.success,
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
                            color: p.container,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.nightlight_round,
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
                        SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: figmaText(
                            'Locked',
                            size: 11,
                            weight: FontWeight.w600,
                            lineHeight: 20,
                            color: p.sage,
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
        border: Border.all(color: p.muted.withValues(alpha: 0.133), width: 1),
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
        color: p.surface,
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
            child: Container(width: 256, height: 2, color: p.container),
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
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 2,
                          color: p.emberDeep,
                          decoration: TextDecoration.none,
                        ),
                      )
                    else
                      Text(
                        _letters[i],
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 2,
                          color: p.body,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: p.ember,
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
