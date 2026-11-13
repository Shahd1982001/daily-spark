import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Floating bottom navigation shared by the app shell screens.
/// Figma: 358 × 56 pill, 4 slots — the selected slot expands into a gradient pill.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.scale,
    required this.selectedIndex,
    this.labels = const ['Home', 'Habits', 'Progress', 'Profile'],
    this.selectedWidth = 88,
    this.onTap,
  });

  final double scale;
  final int selectedIndex;
  final List<String> labels;
  final double selectedWidth;
  final ValueChanged<int>? onTap;

  static const _icons = [
    Icons.local_fire_department_rounded,
    Icons.checklist_rounded,
    Icons.insights_rounded,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 56 * s,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 6 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 4; i++)
            GestureDetector(
              onTap: () => onTap?.call(i),
              behavior: HitTestBehavior.opaque,
              child: i == selectedIndex
                  ? Container(
                      width: selectedWidth * s,
                      height: 44 * s,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF8A54), Color(0xFFFF6B2C)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_icons[i], size: 16 * s, color: Colors.white),
                          SizedBox(width: 5 * s),
                          figmaText(
                            labels[i],
                            size: 10 * s,
                            weight: FontWeight.w600,
                            letterSpacing: 0.25 * s,
                            lineHeight: 12 * s,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: 44 * s,
                      height: 44 * s,
                      child: Icon(
                        _icons[i],
                        size: 21 * s,
                        color: const Color(0xFF57423B),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
