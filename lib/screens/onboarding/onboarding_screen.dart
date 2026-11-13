import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/onboarding/widgets/first_spark_card.dart';
import 'package:daily_spark/screens/onboarding/widgets/milestone_card.dart';
import 'package:daily_spark/screens/onboarding/widgets/streak_flow_card.dart';

/// PURE UI — onboarding flow (3 pages).
///
/// Layout is fully responsive: every block keeps the Figma proportions while
/// the typography, paddings and artwork scale with the device width, and the
/// leftover vertical space is absorbed by the flexible artwork band — so the
/// screen always fills the device with no letterboxing and no distortion.
///
/// Navigation: auto-advance (6 s per page) with a live progress indicator,
/// swipe control that pauses the timer, and a persistent Skip link.
/// Figma: nodes 126:13432 · 126:13517 · 126:14455.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.initialPage = 0,
    this.onSkip,
    this.onFinished,
    this.onFooterLogin,
    this.pageDuration = const Duration(seconds: 6),
  });

  final int initialPage;
  final VoidCallback? onSkip;
  final VoidCallback? onFinished;
  final VoidCallback? onFooterLogin;
  final Duration pageDuration;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _controller =
      PageController(initialPage: widget.initialPage);
  late int _index = widget.initialPage;
  late final AnimationController _timer = AnimationController(
    vsync: this,
    duration: widget.pageDuration,
  );

  /// The last page is the decision point: it never auto-advances.
  bool get _autoAdvances => _index < 2;

  @override
  void initState() {
    super.initState();
    _timer.addStatusListener(_onTimerStatus);
    if (_autoAdvances) _timer.forward();
  }

  @override
  void dispose() {
    _timer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTimerStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _next();
  }

  void _next() {
    if (_index >= 2) {
      widget.onFinished?.call();
      return;
    }
    _controller.animateToPage(
      _index + 1,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _timer
      ..reset()
      ..forward();
    if (index >= 2) _timer.reset();
  }

  void _pause() => _timer.stop();
  void _resume() {
    if (_autoAdvances && _timer.value < 1) _timer.forward();
  }

  @override
  Widget build(BuildContext context) {
    // One scale driver for the whole flow: 390 pt is the Figma reference width.
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / 390).clamp(0.86, 1.25);

    return Scaffold(
      backgroundColor: _Colors.canvas,
      body: Listener(
        onPointerDown: (_) => _pause(),
        onPointerUp: (_) => _resume(),
        onPointerCancel: (_) => _resume(),
        child: AnimatedBuilder(
          animation: _timer,
          builder: (context, _) => PageView(
            controller: _controller,
            onPageChanged: _onPageChanged,
            children: [
              _PageOne(
                scale: scale,
                progress: _index == 0 ? _timer.value : 0,
                onSkip: widget.onSkip,
              ),
              _PageTwo(
                scale: scale,
                progress: _index == 1 ? _timer.value : 0,
                onSkip: widget.onSkip,
              ),
              _PageThree(
                scale: scale,
                onSkip: widget.onSkip,
                onBegin: widget.onFinished,
                onLogin: widget.onFooterLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tokens used by the design
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

/// Places a design-sized block and scales it uniformly to [scale].
class _Scaled extends StatelessWidget {
  const _Scaled({
    required this.width,
    required this.height,
    required this.scale,
    required this.child,
  });

  final double width;
  final double height;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width * scale,
      height: height * scale,
      child: FittedBox(
        child: SizedBox(width: width, height: height, child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared pieces
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.scale, this.compact = false, this.onSkip});

  final double scale;
  final bool compact;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final logo = compact ? 32.0 : 32.0;
    final titleSize = compact ? 16.0 : 18.0;
    final top = (compact ? 16.0 : 50.0) * s;
    final left = (compact ? 16.0 : 24.0) * s;

    return Padding(
      padding: EdgeInsets.only(
        top: top,
        left: left,
        right: 20 * s,
        bottom: (compact ? 16.0 : 18.0) * s,
      ),
      child: Row(
        children: [
          _Scaled(
            width: logo,
            height: logo,
            scale: s,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0x1A9F3C16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, size: 15, color: _Colors.ember),
            ),
          ),
          SizedBox(width: (compact ? 4.0 : 8.0) * s),
          figmaText(
            'Daily Spark',
            size: titleSize * s,
            weight: FontWeight.w600,
            letterSpacing: (compact ? -0.4 : -0.45) * s,
            lineHeight: (compact ? 22 : 28) * s,
            color: _Colors.ink,
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSkip,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 8 * s),
              child: figmaText(
                'Skip',
                size: 14 * s,
                weight: compact ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: compact ? 0.14 * s : null,
                lineHeight: 18 * s,
                color: _Colors.warmGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.scale,
    this.width = 115,
  });

  final String label;
  final double scale;
  final double width;

  @override
  Widget build(BuildContext context) {
    return _Scaled(
      width: width,
      height: 28,
      scale: scale,
      child: Container(
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
              size: 11,
              weight: FontWeight.w600,
              letterSpacing: 0.55,
              lineHeight: 20,
              color: _Colors.stone,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepEyebrow extends StatelessWidget {
  const _StepEyebrow({
    required this.scale,
    required this.label,
    required this.width,
    required this.trailingLabel,
    required this.trailingColor,
    required this.trailingIcon,
  });

  final double scale;
  final String label;
  final double width;
  final String trailingLabel;
  final Color trailingColor;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Scaled(
            width: width,
            height: 20,
            scale: s,
            child: Container(
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
          Row(
            children: [
              Icon(trailingIcon, size: 13 * s, color: trailingColor),
              SizedBox(width: 4 * s),
              figmaText(
                trailingLabel,
                size: 12 * s,
                weight: FontWeight.w500,
                letterSpacing: 0.24 * s,
                lineHeight: 16 * s,
                color: trailingColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Page indicator. The active step doubles as a progress bar for the
/// auto-advance timer (it grows from 8 pt to the full 24 pt).
class _Dots extends StatelessWidget {
  const _Dots({
    required this.active,
    required this.progress,
    required this.scale,
  });

  final int active;
  final double progress;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 8 * s,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(width: 8 * s),
            if (i == active)
              Container(
                width: 24 * s,
                height: 8 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E5E4),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: (8 + 16 * progress.clamp(0.0, 1.0)) * s,
                    height: 8 * s,
                    decoration: BoxDecoration(
                      color: _Colors.ember,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 8 * s,
                height: 8 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E5E4),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    required this.scale,
    this.height = 48,
    this.radius = 12,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.letterSpacing = 0.35,
    this.sparkle = true,
  });

  final String label;
  final VoidCallback? onTap;
  final double scale;
  final double height;
  final double radius;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final bool sparkle;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: height * s,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius * s),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFFF8A54), Color(0xFFFF6B2C)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2 * s,
                offset: Offset(0, 1 * s),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              figmaText(
                label,
                size: fontSize * s,
                weight: fontWeight,
                letterSpacing: letterSpacing * s,
                lineHeight: 18 * s,
                color: Colors.white,
              ),
              if (sparkle) ...[
                SizedBox(width: 8 * s),
                Icon(Icons.auto_awesome, size: 14 * s, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MicroNote extends StatelessWidget {
  const _MicroNote({
    required this.icon,
    required this.text,
    required this.scale,
    this.color = const Color(0xFFA8A29E),
  });

  final IconData icon;
  final String text;
  final double scale;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 12 * s, color: color),
        SizedBox(width: 6 * s),
        figmaText(
          text,
          size: 12 * s,
          weight: FontWeight.w400,
          lineHeight: 16 * s,
          color: color,
        ),
      ],
    );
  }
}

/// Shared vertical rhythm — header, artwork band (flexible), copy, dots, footer.
class _PageLayout extends StatelessWidget {
  const _PageLayout({
    required this.scale,
    required this.header,
    required this.artwork,
    required this.copy,
    required this.dots,
    required this.footer,
    this.eyebrow,
    this.artworkWidth,
    this.artworkHeight,
  });

  final double scale;
  final Widget header;
  final Widget? eyebrow;
  final Widget artwork;
  final Widget copy;
  final Widget dots;
  final Widget footer;
  final double? artworkWidth;
  final double? artworkHeight;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SafeArea(
      child: Column(
        children: [
          header,
          if (eyebrow != null) ...[
            SizedBox(height: 6 * s),
            eyebrow!,
          ],
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6 * s),
                child: SizedBox(
                  width: (artworkWidth ?? 342) * s,
                  height: (artworkHeight ?? 364) * s,
                  child: FittedBox(child: artwork),
                ),
              ),
            ),
          ),
          copy,
          SizedBox(height: 18 * s),
          dots,
          SizedBox(height: 18 * s),
          footer,
          SizedBox(height: 14 * s),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 1 — Start Small
// ─────────────────────────────────────────────────────────────────────────────

class _PageOne extends StatelessWidget {
  const _PageOne({
    required this.scale,
    required this.progress,
    this.onSkip,
  });

  final double scale;
  final double progress;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ColoredBox(
      color: _Colors.canvas,
      child: _PageLayout(
        scale: s,
        header: _Header(scale: s, onSkip: onSkip),
        artwork: const SizedBox(
          width: 342,
          height: 364,
          child: FirstSparkCard(),
        ),
        artworkWidth: 342,
        artworkHeight: 364,
        copy: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Column(
            children: [
              _Chip(label: 'FOUNDATION', scale: s),
              SizedBox(height: 11 * s),
              figmaText(
                'Small habits.\nBig changes.',
                size: 30 * s,
                weight: FontWeight.w700,
                letterSpacing: -0.75 * s,
                lineHeight: 37.5 * s,
                color: _Colors.ink,
                align: TextAlign.center,
              ),
              SizedBox(height: 11 * s),
              figmaText(
                'Build simple daily rituals that fit naturally into your '
                'routine without overwhelming your schedule.',
                size: 14 * s,
                weight: FontWeight.w400,
                lineHeight: 22.75 * s,
                color: _Colors.muted,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
        dots: _Dots(active: 0, progress: progress, scale: s),
        footer: _MicroNote(
          icon: Icons.schedule_rounded,
          text: 'Takes less than 1 minute to personalize',
          scale: s,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 2 — Stay Consistent
// ─────────────────────────────────────────────────────────────────────────────

class _PageTwo extends StatelessWidget {
  const _PageTwo({
    required this.scale,
    required this.progress,
    this.onSkip,
  });

  final double scale;
  final double progress;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ColoredBox(
      color: _Colors.canvas,
      child: _PageLayout(
        scale: s,
        header: _Header(scale: s, compact: true, onSkip: onSkip),
        eyebrow: _StepEyebrow(
          scale: s,
          label: 'STEP 2 OF 3 · CONSISTENCY',
          width: 180,
          trailingLabel: 'Compound Rhythm',
          trailingColor: _Colors.deepEmber,
          trailingIcon: Icons.auto_awesome,
        ),
        artwork: const SizedBox(
          width: 358,
          height: 356,
          child: StreakFlowCard(),
        ),
        artworkWidth: 358,
        artworkHeight: 356,
        copy: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Column(
            children: [
              _Chip(label: 'MOMENTUM', scale: s, width: 107),
              SizedBox(height: 11 * s),
              figmaText(
                'Consistency creates\nmomentum.',
                size: 28 * s,
                weight: FontWeight.w700,
                letterSpacing: -0.7 * s,
                lineHeight: 35 * s,
                color: _Colors.ink,
                align: TextAlign.center,
              ),
              SizedBox(height: 11 * s),
              figmaText(
                'Keep your streak going and build daily rhythm one intentional '
                'ritual at a time.',
                size: 14 * s,
                weight: FontWeight.w400,
                lineHeight: 22.75 * s,
                color: _Colors.muted,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
        dots: _Dots(active: 1, progress: progress, scale: s),
        footer: _MicroNote(
          icon: Icons.verified_rounded,
          text: 'Builds lasting habits that stick',
          scale: s,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 3 — See Your Progress (decision point, no auto-advance)
// ─────────────────────────────────────────────────────────────────────────────

class _PageThree extends StatelessWidget {
  const _PageThree({
    required this.scale,
    this.onSkip,
    this.onBegin,
    this.onLogin,
  });

  final double scale;
  final VoidCallback? onSkip;
  final VoidCallback? onBegin;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ColoredBox(
      color: _Colors.canvas,
      child: _PageLayout(
        scale: s,
        header: _Header(scale: s, compact: true, onSkip: onSkip),
        eyebrow: _StepEyebrow(
          scale: s,
          label: 'STEP 3 OF 3 · FINAL STEP',
          width: 162,
          trailingLabel: 'Milestone Engine',
          trailingColor: const Color(0xFF3A6750),
          trailingIcon: Icons.workspace_premium_rounded,
        ),
        artwork: const SizedBox(
          width: 358,
          height: 326,
          child: MilestoneCard(),
        ),
        artworkWidth: 358,
        artworkHeight: 326,
        copy: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Column(
            children: [
              figmaText(
                'See how far you\u2019ve come.',
                size: 28 * s,
                weight: FontWeight.w700,
                letterSpacing: -0.7 * s,
                lineHeight: 35 * s,
                color: _Colors.ink,
                align: TextAlign.center,
              ),
              SizedBox(height: 11 * s),
              figmaText(
                'Track your deliberate progress and celebrate every ritual you '
                'forge into permanence.',
                size: 14 * s,
                weight: FontWeight.w400,
                lineHeight: 22.75 * s,
                color: _Colors.brown,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
        dots: _Dots(active: 2, progress: 1, scale: s),
        footer: Column(
          children: [
            _PrimaryButton(
              label: 'Begin Your Journey',
              onTap: onBegin,
              scale: s,
            ),
            SizedBox(height: 14 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                figmaText(
                  'Already have an account?',
                  size: 12 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.24 * s,
                  lineHeight: 16 * s,
                  color: _Colors.brown,
                ),
                SizedBox(width: 4 * s),
                GestureDetector(
                  onTap: onLogin,
                  behavior: HitTestBehavior.opaque,
                  child: figmaText(
                    'Log In',
                    size: 12 * s,
                    weight: FontWeight.w600,
                    letterSpacing: 0.24 * s,
                    lineHeight: 16 * s,
                    color: const Color(0xFFE05316),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
