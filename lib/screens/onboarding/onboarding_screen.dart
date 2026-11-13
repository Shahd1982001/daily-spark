import 'package:flutter/material.dart';
import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';
import 'package:daily_spark/design_system/widgets/app_background.dart';
import 'package:daily_spark/design_system/widgets/app_button.dart';
import 'package:daily_spark/design_system/widgets/app_pill.dart';
import 'package:daily_spark/design_system/widgets/page_dots.dart';
import 'package:daily_spark/design_system/widgets/spark_logo.dart';
import 'package:daily_spark/screens/onboarding/widgets/first_spark_card.dart';
import 'package:daily_spark/screens/onboarding/widgets/milestone_card.dart';
import 'package:daily_spark/screens/onboarding/widgets/streak_flow_card.dart';

/// PURE UI — onboarding flow (3 pages).
/// No business logic: the parent decides what "skip" and "finish" mean.
/// Figma: nodes 126:13432 · 126:13517 · 126:14455.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onSkip,
    this.onFinished,
    this.onFooterLogin,
    this.initialPage = 0,
  });

  final VoidCallback? onSkip;
  final VoidCallback? onFinished;
  final VoidCallback? onFooterLogin;
  final int initialPage;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 3;
  late int _index = widget.initialPage;
  late final PageController _controller =
      PageController(initialPage: widget.initialPage);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index >= _pageCount - 1) {
      widget.onFinished?.call();
      return;
    }
    _controller.animateToPage(
      _index + 1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
            ),
            child: Column(
              children: [
                _OnboardingHeader(onSkip: widget.onSkip),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      // ── STEP 1 ────────────────────────────────
                      _PageShell(
                        index: _index,
                        pageCount: _pageCount,
                        visual: const FirstSparkCard(),
                        chip: 'FOUNDATION',
                        headline: 'Small habits.\nBig changes.',
                        body:
                            'Build simple daily rituals that fit naturally into your routine without overwhelming your schedule.',
                        ctaLabel: 'Continue',
                        ctaIcon: Icons.arrow_forward_rounded,
                        footer: 'Takes less than 1 minute to personalize',
                        centered: true,
                        onCta: _next,
                      ),
                      // ── STEP 2 ────────────────────────────────
                      _PageShell(
                        index: _index,
                        pageCount: _pageCount,
                        kicker: 'STEP 2 OF 3 · CONSISTENCY',
                        badge: 'Compound Rhythm',
                        badgeIcon: Icons.auto_awesome,
                        visual: const StreakFlowCard(),
                        chip: 'MOMENTUM',
                        headline: 'Consistency creates\nmomentum.',
                        body:
                            'Keep your streak going and build daily rhythm one intentional ritual at a time.',
                        ctaLabel: 'Next',
                        ctaIcon: Icons.arrow_forward_rounded,
                        footer: 'Build lasting habits that stick',
                        onCta: _next,
                      ),
                      // ── STEP 3 ────────────────────────────────
                      _PageShell(
                        index: _index,
                        pageCount: _pageCount,
                        kicker: 'STEP 3 OF 3 · FINAL STEP',
                        badge: 'Milestone Engine',
                        badgeIcon: Icons.change_history_rounded,
                        visual: const MilestoneCard(),
                        chip: 'MOMENTUM',
                        headline: 'See how far\nyou’ve come.',
                        body:
                            'Track your deliberate progress and celebrate every ritual you forge into permanence.',
                        ctaLabel: 'Begin Your Journey',
                        ctaIcon: Icons.auto_awesome,
                        footer: 'Already have an account?  Log In',
                        onCta: _next,
                        onFooterTap: widget.onFooterLogin,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header: brand + Skip
// ─────────────────────────────────────────────────────────────
class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({this.onSkip});

  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.s8,
        bottom: AppSpacing.s12,
      ),
      child: Row(
        children: [
          const SparkLogo(size: 20, showTile: false),
          const SizedBox(width: AppSpacing.s8),
          Text(
            'Daily Spark',
            style: AppText.titlePrimary.copyWith(
              fontSize: 14,
              color: isDark ? AppColors.darkTextPrimary : AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSkip,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'Skip',
                style: AppText.captionMain.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared page skeleton
// ─────────────────────────────────────────────────────────────
class _PageShell extends StatelessWidget {
  const _PageShell({
    required this.index,
    required this.pageCount,
    required this.visual,
    required this.chip,
    required this.headline,
    required this.body,
    required this.ctaLabel,
    required this.onCta,
    this.ctaIcon,
    this.footer,
    this.onFooterTap,
    this.kicker,
    this.badge,
    this.badgeIcon,
    this.centered = false,
  });

  final int index;
  final int pageCount;
  final Widget visual;
  final String chip;
  final String headline;
  final String body;
  final String ctaLabel;
  final IconData? ctaIcon;
  final String? footer;
  final VoidCallback? onFooterTap;
  final VoidCallback onCta;
  final String? kicker;
  final String? badge;
  final IconData? badgeIcon;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.outlineWarm;
    final ink = isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;
    final align = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kicker + badge (steps 2 & 3 only)
        SizedBox(
          height: 28,
          child: kicker == null
              ? null
              : Row(
                  children: [
                    Text(kicker!, style: AppText.kicker.copyWith(color: muted)),
                    const Spacer(),
                    if (badge != null)
                      AppPill(
                        badge!,
                        tone: PillTone.ember,
                        icon: badgeIcon,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                  ],
                ),
        ),

        // Visual
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              child: FittedBox(fit: BoxFit.scaleDown, child: visual),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.s20),

        // Copy block
        Column(
          crossAxisAlignment: align,
          children: [
            AppPill(
              chip,
              tone: PillTone.outline,
              icon: Icons.auto_awesome,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              headline,
              textAlign: textAlign,
              style: AppText.displayL.copyWith(color: ink, height: 1.22),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              body,
              textAlign: textAlign,
              style: AppText.bodySmall.copyWith(
                color: muted,
                fontSize: 12.5,
                height: 1.6,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.s20),
        PageDots(count: pageCount, index: index),
        const SizedBox(height: AppSpacing.s20),

        AppButton(
          label: ctaLabel,
          trailingIcon: ctaIcon,
          onPressed: onCta,
        ),
        const SizedBox(height: AppSpacing.s12),

        if (footer != null)
          GestureDetector(
            onTap: onFooterTap,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Text(
                footer!,
                style: AppText.captionMain.copyWith(color: muted),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.s16),
      ],
    );
  }
}
