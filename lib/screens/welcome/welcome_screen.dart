import 'package:flutter/material.dart';
import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';
import 'package:daily_spark/design_system/widgets/app_background.dart';
import 'package:daily_spark/design_system/widgets/app_button.dart';
import 'package:daily_spark/design_system/widgets/app_pill.dart';
import 'package:daily_spark/design_system/widgets/spark_logo.dart';
import 'package:daily_spark/design_system/widgets/spark_ring.dart';

/// PURE UI — auth gateway screen.
/// Figma: "Welcome & Authentication Choice" (node 126:14784, 390 × 884).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    this.onBack,
    this.onGetStarted,
    this.onLogin,
    this.onGuest,
  });

  final VoidCallback? onBack;
  final VoidCallback? onGetStarted;
  final VoidCallback? onLogin;
  final VoidCallback? onGuest;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.outlineWarm;
    final ink = isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.s8),

                // ── Top bar: back + mini logo ────────────────
                Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: onBack,
                    ),
                    const Spacer(),
                    const SparkLogo(size: 34),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),

                // ── Brand + headline ─────────────────────────
                const SparkLogo(size: 54),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'WELCOME TO DAILY SPARK',
                  style: AppText.eyebrow.copyWith(color: muted),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  'Make every day count.',
                  textAlign: TextAlign.center,
                  style: AppText.displayL.copyWith(color: ink, height: 1.2),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Build habits, stay consistent, and see your progress grow.',
                  textAlign: TextAlign.center,
                  style: AppText.bodySmall.copyWith(color: muted, height: 1.5),
                ),
                const SizedBox(height: AppSpacing.s24),

                // ── Momentum card ────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: const AppPill(
                    '1% Better Daily',
                    tone: PillTone.sage,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                const _MomentumCard(),
                const SizedBox(height: AppSpacing.s24),

                // ── Actions ──────────────────────────────────
                AppButton(
                  label: "Get Started — It's Free",
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: onGetStarted,
                ),
                const SizedBox(height: AppSpacing.s12),
                GestureDetector(
                  onTap: onLogin,
                  behavior: HitTestBehavior.opaque,
                  child: Text.rich(
                    TextSpan(
                      style: AppText.captionMain.copyWith(color: muted),
                      children: [
                        const TextSpan(text: 'I already have an account · '),
                        TextSpan(
                          text: 'Log In',
                          style: AppText.captionMain.copyWith(
                            color: AppColors.sparkOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Row(
                  children: [
                    Expanded(child: Divider(color: _hairline(isDark))),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                      ),
                      child: Text(
                        'OR CONTINUE SEAMLESSLY',
                        style: AppText.eyebrow.copyWith(
                          color: muted,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: _hairline(isDark))),
                  ],
                ),
                const SizedBox(height: AppSpacing.s20),
                AppButton(
                  label: 'Explore as Guest',
                  variant: AppButtonVariant.soft,
                  icon: Icons.explore_outlined,
                  onPressed: onGuest,
                ),
                const SizedBox(height: AppSpacing.s20),
                Text.rich(
                  TextSpan(
                    style: AppText.bodySmall.copyWith(
                      color: muted,
                      fontSize: 10.5,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' & '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _hairline(bool isDark) =>
      isDark ? AppColors.darkOutline : AppColors.surfaceContainer;
}

// ─────────────────────────────────────────────────────────────
class _MomentumCard extends StatelessWidget {
  const _MomentumCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.outlineWarm;
    final ink = isDark ? AppColors.darkTextPrimary : AppColors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.surfaceContainer,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Day 21', style: AppText.headingH2.copyWith(color: ink)),
                const SizedBox(height: 2),
                Text(
                  'Unlimited Access',
                  style: AppText.bodySmall.copyWith(color: muted),
                ),
                const SizedBox(height: AppSpacing.s12),
                const AppPill(
                  'Momentum Unlocked',
                  tone: PillTone.ochre,
                  icon: Icons.auto_awesome,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          SparkRing(
            progress: 0.21,
            size: 86,
            strokeWidth: 8,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.sparkOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 15,
                color: AppColors.sparkOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.darkOutline : AppColors.surfaceContainer,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.darkTextPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
