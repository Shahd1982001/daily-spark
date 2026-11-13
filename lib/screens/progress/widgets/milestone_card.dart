import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Progress · Milestone & Rewards — Figma 358 × 186, r24.
class MilestoneCard extends StatelessWidget {
  const MilestoneCard({super.key, required this.scale, this.onShare});

  final double scale;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 186 * s,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F0),
        borderRadius: BorderRadius.circular(24 * s),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 16 * s,
            child: Container(
              width: 48 * s,
              height: 48 * s,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDDB2),
                borderRadius: BorderRadius.circular(16 * s),
              ),
              child: Icon(Icons.emoji_events_rounded,
                  size: 24 * s, color: const Color(0xFF291800)),
            ),
          ),
          Positioned(
            left: 80 * s,
            top: 13 * s,
            child: figmaText(
              'Century Spark',
              size: 16 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.08 * s,
              lineHeight: 22 * s,
              color: const Color(0xFF191C1A),
            ),
          ),
          Positioned(
            left: 196 * s,
            top: 19 * s,
            child: Container(
              width: 76 * s,
              height: 15 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDDB2),
                borderRadius: BorderRadius.circular(999 * s),
              ),
              child: figmaText(
                '100 LOGGED',
                size: 10 * s,
                weight: FontWeight.w700,
                lineHeight: 12 * s,
                color: const Color(0xFF291800),
              ),
            ),
          ),
          Positioned(
            left: 80 * s,
            top: 42 * s,
            width: 246 * s,
            child: figmaText(
              "You've logged 100 habits since joining Daily Spark. Your "
              'consistency rate places you in the top 5% of mindful builders '
              'this month.',
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: const Color(0xFF57423B),
            ),
          ),
          Positioned(
            left: 80 * s,
            top: 152 * s,
            child: GestureDetector(
              onTap: onShare,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  figmaText(
                    'Share Achievement',
                    size: 12 * s,
                    weight: FontWeight.w600,
                    letterSpacing: 0.24 * s,
                    lineHeight: 16 * s,
                    color: const Color(0xFF9F3C16),
                  ),
                  SizedBox(width: 4 * s),
                  Icon(Icons.arrow_forward_rounded,
                      size: 12 * s, color: const Color(0xFF9F3C16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
