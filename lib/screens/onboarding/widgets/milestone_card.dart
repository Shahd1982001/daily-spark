import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';
import 'package:daily_spark/design_system/widgets/app_pill.dart';
import 'package:daily_spark/design_system/widgets/spark_ring.dart';

/// Onboarding step 3 visual — "Century Spark" milestone + stats.
class MilestoneCard extends StatelessWidget {
  const MilestoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.outlineWarm;
    final ink = isDark ? AppColors.darkTextPrimary : AppColors.onSurfaceVariant;

    return SizedBox(
      width: 342,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppPill('Century Spark Achieved', icon: Icons.auto_awesome, tone: PillTone.sage),
          const SizedBox(height: AppSpacing.s20),
          SparkRing(
            progress: 0.88,
            size: 172,
            strokeWidth: 14,
            colors: isDark
                ? const [AppColors.darkPeach, AppColors.sparkOrange]
                : const [AppColors.sparkOrange, AppColors.primaryEmber],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '88%',
                  style: AppText.displayL.copyWith(color: ink, fontSize: 30),
                ),
                const SizedBox(height: 2),
                Text('CONSISTENT', style: AppText.eyebrow.copyWith(color: muted, fontSize: 8)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: isDark ? AppColors.darkOutline : AppColors.surfaceContainer,
                ),
              ),
            ),
            child: Row(
              children: [
                _Stat(value: '142', label: 'TOTAL', caption: 'in flow', isDark: isDark),
                _Divider(isDark: isDark),
                _Stat(value: '6', label: 'RITUALS', caption: 'not daily', isDark: isDark),
                _Divider(isDark: isDark),
                _Stat(value: '24', label: 'SPARK', caption: 'wk high', isDark: isDark, highlight: true),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          const AppPill('100 Days of Sustained Focus', tone: PillTone.outline),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.caption,
    required this.isDark,
    this.highlight = false,
  });

  final String value;
  final String label;
  final String caption;
  final bool isDark;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppColors.darkTextMuted : AppColors.outlineWarm;
    final ink = isDark ? AppColors.darkTextPrimary : AppColors.onSurfaceVariant;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppText.headingH2.copyWith(
              color: highlight ? AppColors.sparkOrange : ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppText.eyebrow.copyWith(color: muted, fontSize: 8)),
          const SizedBox(height: 2),
          Text(caption, style: AppText.bodySmall.copyWith(color: muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.darkOutline : AppColors.surfaceContainer,
    );
  }
}
