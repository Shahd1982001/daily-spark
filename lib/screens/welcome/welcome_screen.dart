import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// PURE UI — Welcome & authentication choice.
/// No routing, no state: the parent decides what each button means.
/// Figma: node 126:14784 (390 × 884).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    this.onGetStarted,
    this.onLogin,
    this.onGuest,
  });

  /// "Get Started — It's Free" → Sign Up (no account yet).
  final VoidCallback? onGetStarted;

  /// "I already have an account · Log In".
  final VoidCallback? onLogin;

  /// "Explore as Guest".
  final VoidCallback? onGuest;

  static Color get _canvas => p.canvas;
  static Color get _ink => p.ink;
  static Color get _brown => p.body;
  static Color get _ember => p.ember;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Column(
          children: [
            // ── Brand + welcome copy ────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16 * s, 4 * s, 16 * s, 0),
              child: Column(
                children: [
                  _Emblem(scale: s),
                  SizedBox(height: 4 * s),
                  _WelcomeChip(scale: s),
                  SizedBox(height: 8 * s),
                  figmaText(
                    'Make every day count.',
                    size: 26 * s,
                    weight: FontWeight.w600,
                    letterSpacing: -0.65 * s,
                    lineHeight: 32 * s,
                    color: _ink,
                    align: TextAlign.center,
                  ),
                  SizedBox(height: 5 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 39 * s),
                    child: figmaText(
                      'Build habits, stay consistent, and see your progress grow.',
                      size: 14 * s,
                      weight: FontWeight.w400,
                      lineHeight: 22.75 * s,
                      color: _brown,
                      align: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // ── Centre visual ───────────────────────────────────────
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, -4 * s),
                  child: SizedBox(
                    width: 358 * s,
                    height: 412 * s,
                    child: const FittedBox(child: _CentreVisual()),
                  ),
                ),
              ),
            ),

            // ── Authentication actions ──────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              child: Column(
                children: [
                  SizedBox(height: 8 * s),
                  _PrimaryCta(scale: s, onTap: onGetStarted),
                  SizedBox(height: 12 * s),
                  _SecondaryCta(scale: s, onTap: onLogin),
                  SizedBox(height: 12 * s),
                  _GuestEntry(scale: s, onTap: onGuest),
                ],
              ),
            ),
            SizedBox(height: 12 * s),

            // ── Legal note ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30 * s),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12 * s,
                    height: 16 / 12,
                    letterSpacing: 0.12 * s,
                    color: _brown,
                    decoration: TextDecoration.none,
                  ),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: _ink,
                        decoration: TextDecoration.underline,
                        decorationColor: _ink.withValues(alpha: 0.5),
                      ),
                    ),
                    const TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: _ink,
                        decoration: TextDecoration.underline,
                        decorationColor: _ink.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32 * s),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header emblem
// ─────────────────────────────────────────────────────────────────────────────

class _Emblem extends StatelessWidget {
  const _Emblem({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80 * scale,
      height: 80 * scale,
      child: FittedBox(
        child: SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft halo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: p.chipEmber,
                  shape: BoxShape.circle,
                ),
              ),
              // White tile
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/brand/spark_mark.png',
                        width: 22,
                        height: 22,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Daily Spark',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 6.4,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: Color(0xFFC2410C),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeChip extends StatelessWidget {
  const _WelcomeChip({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: p.emberTile,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: figmaText(
        'WELCOME TO DAILY SPARK',
        size: 10 * scale,
        weight: FontWeight.w600,
        letterSpacing: 0.5 * scale,
        lineHeight: 12 * scale,
        color: WelcomeScreen._ember,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Centre visual — 358 × 412 design canvas
// ─────────────────────────────────────────────────────────────────────────────

class _CentreVisual extends StatelessWidget {
  const _CentreVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 358,
      height: 412,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Concentric rhythm rings (offset from the design's centre block)
          Positioned(
            left: 35,
            top: 62,
            child: _circle(288, p.container.withValues(alpha: 0.6)),
          ),
          Positioned(
            left: 67,
            top: 94,
            child: _circle(224, p.bone.withValues(alpha: 0.4)),
          ),
          Positioned(
            left: 99,
            top: 126,
            child: _circle(160, p.emberSoft.withValues(alpha: 0.2)),
          ),

          // Central focus node card
          Positioned(
            left: 91,
            top: 118,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Mini daily rings + flame
                  Positioned(
                    left: 56,
                    top: 20,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(64, 64),
                            painter: _MiniRingsPainter(),
                          ),
                          Icon(Icons.local_fire_department_rounded,
                              size: 15, color: WelcomeScreen._ember),
                        ],
                      ),
                    ),
                  ),
                  // Day 21
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 98,
                    child: figmaText(
                      'Day 21',
                      size: 18,
                      weight: FontWeight.w600,
                      letterSpacing: -0.18,
                      lineHeight: 22.5,
                      color: WelcomeScreen._ink,
                      align: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 122,
                    child: figmaText(
                      'Unbroken Focus',
                      size: 10,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4,
                      lineHeight: 12,
                      color: WelcomeScreen._brown,
                      align: TextAlign.center,
                    ),
                  ),
                  // Progress bar
                  Positioned(
                    left: 16,
                    top: 154,
                    child: Container(
                      width: 144,
                      height: 6,
                      decoration: BoxDecoration(
                        color: p.panel,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 112,
                          height: 6,
                          decoration: BoxDecoration(
                            color: WelcomeScreen._ember,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating micro-badge — top left (tilted −3° in the design)
          Positioned(
            left: 31.5,
            top: 97,
            child: Transform.rotate(
              angle: -0.0523599,
              child: _floatBadge(
                width: 119,
                height: 28,
                icon: Icons.auto_awesome,
                iconColor: p.ochre,
                label: '1% Better Daily',
              ),
            ),
          ),

          // Floating micro-badge — right (tilted +3° in the design)
          Positioned(
            left: 245.5,
            top: 140.5,
            child: Transform.rotate(
              angle: 0.0523599,
              child: _floatBadge(
                width: 96.5,
                height: 28,
                icon: Icons.eco_rounded,
                iconColor: p.sage,
                label: 'Pure Focus',
              ),
            ),
          ),

          // Momentum pill (tilted +1° in the design)
          Positioned(
            left: 16,
            top: 294,
            child: Transform.rotate(
              angle: 0.017453,
              child: Container(
              width: 156,
              height: 24.5,
              decoration: BoxDecoration(
                color: p.emberTile,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.bolt_rounded, size: 13, color: p.emberDark),
                  SizedBox(width: 6),
                  figmaText(
                    'Momentum Unleashed',
                    size: 10,
                    weight: FontWeight.w600,
                    letterSpacing: 0.4,
                    lineHeight: 12,
                    color: p.emberDark,
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _floatBadge({
    required double width,
    required double height,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 5),
          figmaText(
            label,
            size: 10,
            weight: FontWeight.w600,
            letterSpacing: 0.4,
            lineHeight: 12,
            color: WelcomeScreen._ink,
          ),
        ],
      ),
    );
  }
}

/// Two concentric focus rings around the flame, exactly as in the Figma
/// "Mini Daily Rings Graphic": deep-ember outer ring + sage inner ring.
class _MiniRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    void ring({
      required double radius,
      required double stroke,
      required Color color,
      required double startDeg,
      required double sweepDeg,
    }) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        startDeg * 3.14159265 / 180,
        sweepDeg * 3.14159265 / 180,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }

    // Brighter track behind the arcs
    canvas.drawCircle(
      center,
      26.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = p.container,
    );

    // Outer — deep ember
    ring(radius: 26.5, stroke: 5, color: p.emberDeep, startDeg: 240, sweepDeg: 330);
    // Inner — sage
    ring(radius: 19, stroke: 4, color: p.sage, startDeg: 250, sweepDeg: 320);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Actions
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * s),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [p.emberLight, p.ember],
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
              'Get Started — It\u2019s Free',
              size: 14 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.14 * s,
              lineHeight: 18 * s,
              color: p.surface,
            ),
            SizedBox(width: 8 * s),
            Icon(Icons.arrow_forward_rounded, size: 14 * s, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SecondaryCta extends StatelessWidget {
  const _SecondaryCta({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50 * s,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(12 * s),
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
              'I already have an account · Log In',
              size: 14 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.14 * s,
              lineHeight: 18 * s,
              color: WelcomeScreen._ink,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestEntry extends StatelessWidget {
  const _GuestEntry({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52 * s,
        padding: EdgeInsets.symmetric(horizontal: 16 * s),
        decoration: BoxDecoration(
          color: p.panel,
          borderRadius: BorderRadius.circular(12 * s),
        ),
        child: Row(
          children: [
            Container(
              width: 32 * s,
              height: 32 * s,
              decoration: BoxDecoration(
                color: p.bone,
                borderRadius: BorderRadius.circular(8 * s),
              ),
              child: Icon(Icons.explore_outlined,
                  size: 16 * s, color: WelcomeScreen._brown),
            ),
            SizedBox(width: 12 * s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                figmaText(
                  'Explore as Guest',
                  size: 12 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.24 * s,
                  lineHeight: 16 * s,
                  color: WelcomeScreen._ink,
                ),
                figmaText(
                  'No account needed to start',
                  size: 10 * s,
                  weight: FontWeight.w600,
                  letterSpacing: 0.4 * s,
                  lineHeight: 12 * s,
                  color: WelcomeScreen._brown,
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 18 * s, color: WelcomeScreen._brown),
          ],
        ),
      ),
    );
  }
}
