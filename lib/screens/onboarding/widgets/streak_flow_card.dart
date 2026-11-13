import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';
import 'package:daily_spark/design_system/widgets/app_pill.dart';

/// Onboarding step 2 visual — "7-Day Streak in Flow".
class StreakFlowCard extends StatelessWidget {
  const StreakFlowCard({super.key});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _completed = [true, true, true, true, true, false, false];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final hairline = isDark ? AppColors.darkOutline : AppColors.surfaceContainer;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.outlineWarm;
    final ink = isDark ? AppColors.darkTextPrimary : AppColors.onSurfaceVariant;

    return SizedBox(
      width: 342,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('7-Day Streak in Flow', style: AppText.titlePrimary.copyWith(color: ink)),
                const Spacer(),
                const AppPill('+18% vs last wk', tone: PillTone.sage, icon: Icons.trending_up_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_days.length, (i) {
                return _DayDot(
                  label: _days[i],
                  state: _completed[i]
                      ? _DayState.done
                      : (i == 5 ? _DayState.today : _DayState.pending),
                  isDark: isDark,
                );
              }),
            ),
            const SizedBox(height: AppSpacing.s16),
            Divider(color: hairline),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.sparkOrange.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.nights_stay_outlined, size: 15, color: AppColors.sparkOrange),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evening Reading & Wind-down',
                        style: AppText.captionMain.copyWith(
                          color: ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('Target: 10 pages', style: AppText.bodySmall.copyWith(color: muted)),
                    ],
                  ),
                ),
                Icon(Icons.lock_outline_rounded, size: 14, color: muted),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            AppPill('0d · Unbroken chain', tone: PillTone.soft),
          ],
        ),
      ),
    );
  }
}

enum _DayState { done, today, pending }

class _DayDot extends StatelessWidget {
  const _DayDot({required this.label, required this.state, required this.isDark});

  final String label;
  final _DayState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppColors.darkTextMuted : AppColors.outlineWarm;

    Color bg;
    Color fg;
    Border? border;
    switch (state) {
      case _DayState.done:
        bg = isDark ? AppColors.sageDark : AppColors.sageSoft;
        fg = isDark ? AppColors.darkSuccess : AppColors.sage;
      case _DayState.today:
        bg = Colors.transparent;
        fg = AppColors.sparkOrange;
        border = Border.all(color: AppColors.sparkOrange);
      case _DayState.pending:
        bg = isDark ? AppColors.darkSurfaceHigh : AppColors.surfaceLow;
        fg = muted;
    }

    return Column(
      children: [
        Text(label, style: AppText.eyebrow.copyWith(color: muted, fontSize: 9)),
        const SizedBox(height: 6),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: border),
          child: Icon(
            state == _DayState.done ? Icons.check_rounded : Icons.circle_outlined,
            size: state == _DayState.done ? 15 : 9,
            color: fg,
          ),
        ),
      ],
    );
  }
}
