import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';

/// Onboarding page indicator: the active item stretches into an ember pill.
class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: active ? 22 : 6,
          decoration: BoxDecoration(
            color: active
                ? AppColors.sparkOrange
                : (isDark ? AppColors.darkOutline : AppColors.surfaceContainer),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
