import 'package:flutter/material.dart';
import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';
import 'package:daily_spark/design_system/widgets/app_background.dart';
import 'package:daily_spark/design_system/widgets/app_pill.dart';
import 'package:daily_spark/design_system/widgets/spark_logo.dart';

/// PURE UI — no state, no navigation, no business logic.
/// Figma: "Daily Spark - Splash Screen" (node 126:13378, 390 × 884).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.outlineWarm;
    final ink = isDark ? AppColors.darkTextPrimary : AppColors.onSurfaceVariant;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.s8),

                // ── Top status line ──────────────────────────────
                Row(
                  children: [
                    Text(
                      'EST. 2024',
                      style: AppText.eyebrow.copyWith(color: muted),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: AppColors.sparkOrange.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    Text(
                      'Synced Ready',
                      style: AppText.captionMain.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                // ── Brand lockup ─────────────────────────────────
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SparkLogo(size: 104),
                        const SizedBox(height: AppSpacing.s24),
                        Text(
                          'Daily Spark',
                          style: AppText.displayL.copyWith(color: ink),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          'Small steps compound daily',
                          style: AppText.bodySmall.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Streak pill ──────────────────────────────────
                AppPill(
                  'Igniting Day 14',
                  tone: PillTone.soft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.sparkOrange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      size: 9,
                      color: AppColors.sparkOrange,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // ── Footer ───────────────────────────────────────
                Divider(
                  color: isDark
                      ? AppColors.darkOutline
                      : AppColors.surfaceContainer,
                ),
                const SizedBox(height: AppSpacing.s12),
                Row(
                  children: [
                    Text(
                      'ARCHITECTURE OF DAILY RITUALS',
                      style: AppText.eyebrow.copyWith(
                        color: muted,
                        letterSpacing: 1.0,
                        fontSize: 8,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'v2.4.0',
                      style: AppText.eyebrow.copyWith(
                        color: muted,
                        letterSpacing: 0.6,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
