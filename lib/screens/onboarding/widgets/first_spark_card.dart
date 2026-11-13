import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';
import 'package:daily_spark/design_system/widgets/app_pill.dart';

/// Onboarding step 1 visual — "Day 1: The First Spark".
class FirstSparkCard extends StatelessWidget {
  const FirstSparkCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final hairline = isDark ? AppColors.darkOutline : AppColors.surfaceContainer;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.outlineWarm;

    return SizedBox(
      width: 342,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: hairline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.sparkOrange.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.btn),
                  ),
                  child: const Icon(Icons.auto_awesome, size: 18, color: AppColors.sparkOrange),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day 1: The First Spark',
                        style: AppText.interactiveLabel.copyWith(color: muted),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Read 5 pages',
                        style: AppText.titlePrimary.copyWith(
                          fontSize: 15,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('30 pgs/day · Morning', style: AppText.bodySmall.copyWith(color: muted)),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.sageDark : AppColors.sageSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isDark ? AppColors.darkSuccess : AppColors.sage,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Row(
              children: [
                Text('COMMITMENT', style: AppText.eyebrow.copyWith(color: muted)),
                const Spacer(),
                Text('5 mins / day', style: AppText.captionMain.copyWith(color: muted)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          const AppPill('Atomic Spark', icon: Icons.auto_awesome, tone: PillTone.outline),
        ],
      ),
    );
  }
}
