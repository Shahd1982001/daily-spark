import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart';
import 'package:daily_spark/screens/onboarding/widgets/first_spark_card.dart';
import 'package:daily_spark/screens/onboarding/widgets/milestone_card.dart';
import 'package:daily_spark/screens/onboarding/widgets/streak_flow_card.dart';

/// PURE UI — onboarding flow (3 pages), laid out on the exact Figma canvas.
/// Figma: nodes 126:13432 · 126:13517 · 126:14455 (390 × 884 each).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.initialPage = 0,
    this.onSkip,
    this.onFinished,
    this.onFooterLogin,
  });

  final int initialPage;
  final VoidCallback? onSkip;
  final VoidCallback? onFinished;
  final VoidCallback? onFooterLogin;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller =
      PageController(initialPage: widget.initialPage);
  late int _index = widget.initialPage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index >= 2) {
      widget.onFinished?.call();
      return;
    }
    _controller.animateToPage(
      _index + 1,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesignCanvas(
      child: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _index = i),
        children: [
          _PageOne(onNext: _next, onSkip: widget.onSkip),
          _PageTwo(onNext: _next, onSkip: widget.onSkip),
          _PageThree(
            onNext: _next,
            onSkip: widget.onSkip,
            onLogin: widget.onFooterLogin,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared pieces
// ─────────────────────────────────────────────────────────────────────────────

class _Colors {
  static const canvas = Color(0xFFF8FAF6);
  static const ink = Color(0xFF191C1A);
  static const brown = Color(0xFF57423B);
  static const muted = Color(0xFF78716C);
  static const stone = Color(0xFF57534E);
  static const warmGrey = Color(0xFFA8A29E);
  static const ember = Color(0xFFFF6B2C);
  static const deepEmber = Color(0xFF9F3C16);
}

/// Page 1 header — 32 px logo mark + 18 px wordmark, "Skip" on the right.
class _HeaderLarge extends StatelessWidget {
  const _HeaderLarge({this.onSkip});

  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          Positioned(left: 24, top: 50, child: const _LogoMark()),
          Positioned(
            left: 64,
            top: 52,
            child: figmaText('Daily Spark',
                size: 18,
                weight: FontWeight.w600,
                letterSpacing: -0.45,
                lineHeight: 28,
                color: _Colors.ink),
          ),
          Positioned(
            right: 24,
            top: 53,
            child: GestureDetector(
              onTap: onSkip,
              behavior: HitTestBehavior.opaque,
              child: figmaText('Skip',
                  size: 14,
                  weight: FontWeight.w500,
                  lineHeight: 20,
                  color: _Colors.warmGrey),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pages 2 & 3 header — compact 64 px variant.
class _HeaderCompact extends StatelessWidget {
  const _HeaderCompact({this.onSkip});

  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: _Colors.canvas.withValues(alpha: 0.8),
      child: Stack(
        children: [
          Positioned(left: 16, top: 16, child: const _LogoMark()),
          Positioned(
            left: 52,
            top: 21,
            child: figmaText('Daily Spark',
                size: 16,
                weight: FontWeight.w600,
                letterSpacing: -0.4,
                lineHeight: 22,
                color: _Colors.ink),
          ),
          Positioned(
            right: 20,
            top: 24,
            child: GestureDetector(
              onTap: onSkip,
              behavior: HitTestBehavior.opaque,
              child: figmaText('Skip',
                  size: 14,
                  weight: FontWeight.w600,
                  letterSpacing: 0.14,
                  lineHeight: 18,
                  color: _Colors.warmGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0x1A9F3C16),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.auto_awesome,
        size: 15,
        color: _Colors.ember,
      ),
    );
  }
}

/// "● FOUNDATION" style chip (page 1) and "● STEP 2 OF 3 · …" eyebrow rows.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.width = 115, this.size = 11});

  final String label;
  final double width;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEEB),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _Colors.ember,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          figmaText(
            label,
            size: size,
            weight: FontWeight.w600,
            letterSpacing: 0.55,
            lineHeight: 20,
            color: _Colors.stone,
          ),
        ],
      ),
    );
  }
}

class _StepEyebrow extends StatelessWidget {
  const _StepEyebrow({
    required this.label,
    required this.width,
    required this.trailingLabel,
    required this.trailingColor,
    required this.trailingIcon,
  });

  final String label;
  final double width;
  final String trailingLabel;
  final Color trailingColor;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 358,
      height: 32,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: width,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E9E5),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _Colors.deepEmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  figmaText(
                    label,
                    size: 10,
                    weight: FontWeight.w600,
                    letterSpacing: 0.5,
                    lineHeight: 12,
                    color: _Colors.brown,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: Row(
              children: [
                Icon(trailingIcon, size: 13, color: trailingColor),
                const SizedBox(width: 4),
                figmaText(
                  trailingLabel,
                  size: 12,
                  weight: FontWeight.w500,
                  letterSpacing: 0.24,
                  lineHeight: 16,
                  color: trailingColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.active, required this.top});

  final int active;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (390 - 56) / 2,
      top: top,
      child: SizedBox(
        width: 56,
        height: 8,
        child: Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Container(
                width: i == active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == active ? _Colors.ember : const Color(0xFFE7E5E4),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.left = 24,
    this.width = 342,
    this.height = 56,
    this.radius = 16,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.letterSpacing,
    this.sparkle = false,
  });

  final String label;
  final VoidCallback? onTap;
  final double left;
  final double width;
  final double height;
  final double radius;
  final double fontSize;
  final FontWeight fontWeight;
  final double? letterSpacing;
  final bool sparkle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFFF8A54), Color(0xFFFF6B2C)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            figmaText(
              label,
              size: fontSize,
              weight: fontWeight,
              letterSpacing: letterSpacing,
              lineHeight: fontSize * 1.5,
              color: Colors.white,
            ),
            if (sparkle) ...[
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

class _MicroNote extends StatelessWidget {
  const _MicroNote({
    required this.icon,
    required this.text,
    required this.top,
    this.color = const Color(0xFFA8A29E),
  });

  final IconData icon;
  final String text;
  final double top;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: top,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          figmaText(
            text,
            size: 12,
            weight: FontWeight.w400,
            lineHeight: 16,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 1 — Start Small
// ─────────────────────────────────────────────────────────────────────────────

class _PageOne extends StatelessWidget {
  const _PageOne({this.onNext, this.onSkip});

  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: _Colors.canvas)),
        Positioned(top: 0, left: 0, right: 0, child: _HeaderLarge(onSkip: onSkip)),
        const Positioned(left: 24, top: 153, child: FirstSparkCard()),

        const Positioned(left: 137, top: 517, child: _Chip(label: 'FOUNDATION')),

        Positioned(
          left: 40,
          top: 556,
          width: 310,
          child: figmaText(
            'Small habits.\nBig changes.',
            size: 30,
            weight: FontWeight.w700,
            letterSpacing: -0.75,
            lineHeight: 37.5,
            color: _Colors.ink,
            align: TextAlign.center,
          ),
        ),
        Positioned(
          left: 51,
          top: 643,
          width: 288,
          child: figmaText(
            'Build simple daily rituals that fit naturally into your routine '
            'without overwhelming your schedule.',
            size: 14,
            weight: FontWeight.w400,
            lineHeight: 22.75,
            color: _Colors.muted,
            align: TextAlign.center,
          ),
        ),

        const _Dots(active: 0, top: 736),
        Positioned(
          left: 24,
          top: 768,
          child: _PrimaryButton(
            label: 'Continue →',
            onTap: onNext,
          ),
        ),
        const _MicroNote(
          icon: Icons.schedule_rounded,
          text: 'Takes less than 1 minute to personalize',
          top: 836,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 2 — Stay Consistent
// ─────────────────────────────────────────────────────────────────────────────

class _PageTwo extends StatelessWidget {
  const _PageTwo({this.onNext, this.onSkip});

  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: _Colors.canvas)),
        Positioned(top: 0, left: 0, right: 0, child: _HeaderCompact(onSkip: onSkip)),
        const Positioned(
          left: 16,
          top: 64,
          child: _StepEyebrow(
            label: 'STEP 2 OF 3 · CONSISTENCY',
            width: 180,
            trailingLabel: 'Compound Rhythm',
            trailingColor: _Colors.deepEmber,
            trailingIcon: Icons.auto_awesome,
          ),
        ),
        const Positioned(left: 16, top: 96, child: StreakFlowCard()),

        const Positioned(left: 142, top: 460, child: _Chip(label: 'MOMENTUM', width: 107)),

        Positioned(
          left: 24,
          top: 495,
          width: 342,
          child: figmaText(
            'Consistency creates\nmomentum.',
            size: 28,
            weight: FontWeight.w700,
            letterSpacing: -0.7,
            lineHeight: 35,
            color: _Colors.ink,
            align: TextAlign.center,
          ),
        ),
        Positioned(
          left: 46,
          top: 573,
          width: 298,
          child: figmaText(
            'Keep your streak going and build daily rhythm one intentional '
            'ritual at a time.',
            size: 14,
            weight: FontWeight.w400,
            lineHeight: 22.75,
            color: _Colors.muted,
            align: TextAlign.center,
          ),
        ),

        const _Dots(active: 1, top: 740),
        Positioned(
          left: 16,
          top: 768,
          child: _PrimaryButton(
            label: 'Next →',
            onTap: onNext,
            left: 16,
            width: 358,
          ),
        ),
        const _MicroNote(
          icon: Icons.verified_rounded,
          text: 'Builds lasting habits that stick',
          top: 842,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 3 — See Your Progress
// ─────────────────────────────────────────────────────────────────────────────

class _PageThree extends StatelessWidget {
  const _PageThree({this.onNext, this.onSkip, this.onLogin});

  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: _Colors.canvas)),
        Positioned(top: 0, left: 0, right: 0, child: _HeaderCompact(onSkip: onSkip)),
        const Positioned(
          left: 16,
          top: 64,
          child: _StepEyebrow(
            label: 'STEP 3 OF 3 · FINAL STEP',
            width: 162,
            trailingLabel: 'Milestone Engine',
            trailingColor: Color(0xFF3A6750),
            trailingIcon: Icons.workspace_premium_rounded,
          ),
        ),
        const Positioned(left: 16, top: 111, child: MilestoneCard()),

        Positioned(
          left: 24,
          top: 460,
          width: 342,
          child: figmaText(
            'See how far you\u2019ve come.',
            size: 28,
            weight: FontWeight.w700,
            letterSpacing: -0.7,
            lineHeight: 35,
            color: _Colors.ink,
            align: TextAlign.center,
          ),
        ),
        Positioned(
          left: 47,
          top: 502,
          width: 296,
          child: figmaText(
            'Track your deliberate progress and celebrate every ritual you '
            'forge into permanence.',
            size: 14,
            weight: FontWeight.w400,
            lineHeight: 22.75,
            color: _Colors.brown,
            align: TextAlign.center,
          ),
        ),

        const _Dots(active: 2, top: 744),
        Positioned(
          left: 16,
          top: 772,
          child: _PrimaryButton(
            label: 'Begin Your Journey',
            onTap: onNext,
            left: 16,
            width: 358,
            height: 48,
            radius: 12,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.35,
            sparkle: true,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 836,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              figmaText('Already have an account?',
                  size: 12,
                  weight: FontWeight.w500,
                  letterSpacing: 0.24,
                  lineHeight: 16,
                  color: _Colors.brown),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onLogin,
                behavior: HitTestBehavior.opaque,
                child: figmaText('Log In',
                    size: 12,
                    weight: FontWeight.w600,
                    letterSpacing: 0.24,
                    lineHeight: 16,
                    color: const Color(0xFFE05316)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
