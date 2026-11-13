import 'dart:ui';

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
    this.height = 56,
    this.horizontalPadding = 6,
    this.selectedHeight = 44,
    this.labelSize = 10,
    this.iconSize = 21,
    this.frosted = false,
    this.icons,
    this.onTap,
  });

  final double scale;
  final int selectedIndex;
  final List<String> labels;
  final double selectedWidth;
  final double height;
  final double horizontalPadding;
  final double selectedHeight;
  final double labelSize;
  final double iconSize;
  final bool frosted;
  final List<IconData>? icons;
  final ValueChanged<int>? onTap;

  static const _defaultIcons = [
    Icons.local_fire_department_rounded,
    Icons.checklist_rounded,
    Icons.insights_rounded,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final navIcons = icons ?? _defaultIcons;
    final card = Container(
      height: height * s,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: frosted ? 0.90 : 0.95),
        border: frosted
            ? Border.all(
                color: const Color(0xFFDEC0B5).withValues(alpha: 0.10),
                width: 1 * s,
              )
            : null,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding * s),
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
                      height: selectedHeight * s,
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
                          Icon(navIcons[i], size: 16 * s, color: Colors.white),
                          SizedBox(width: 5 * s),
                          figmaText(
                            labels[i],
                            size: labelSize * s,
                            weight: labelSize >= 12 ? FontWeight.w500 : FontWeight.w600,
                            letterSpacing: (labelSize >= 12 ? 0 : 0.25) * s,
                            lineHeight: (labelSize >= 12 ? 16 : 12) * s,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: 44 * s,
                      height: 44 * s,
                      child: Icon(
                        navIcons[i],
                        size: iconSize * s,
                        color: const Color(0xFF57423B),
                      ),
                    ),
            ),
        ],
      ),
    );
    if (!frosted) return card;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12 * s, sigmaY: 12 * s),
        child: card,
      ),
    );
  }
}
