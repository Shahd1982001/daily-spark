import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/design_system/widgets/spark_app_icon.dart';

/// PURE UI — no state, no navigation, no business logic.
/// Figma: "Daily Spark - Splash Screen" (light 126:13378 · dark 163:2560).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.onTap});

  /// Preview-only hook: tap anywhere to continue. Real routing comes later.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.spark;
    return Scaffold(
      backgroundColor: p.canvas,
      body: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            const Positioned.fill(child: _SplashBackdrop()),
            SafeArea(
              minimum: const EdgeInsets.only(top: 32, bottom: 32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // ── Status line ───────────────────────────────
                    Row(
                      children: [
                        Text(
                          'EST. 2024',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: p.metaText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: p.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sync Ready',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: p.syncText,
                          ),
                        ),
                      ],
                    ),

                    // ── Brand lockup ──────────────────────────────
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SparkAppIcon(size: 144),
                              const SizedBox(height: 16),
                              Text(
                                'Daily Spark',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 26,
                                  height: 32 / 26,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.65,
                                  color: p.ink,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Small steps compound daily.',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  height: 20 / 14,
                                  fontWeight: FontWeight.w400,
                                  color: p.body,
                                ),
                              ),
                              const SizedBox(height: 32),
                              const _StreakPill(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Boot progress ─────────────────────────────
                    const _BootProgress(),
                    const SizedBox(height: 16),
                    Text(
                      'ARCHITECTURE OF DAILY RITUALS',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: p.metaTextSoft,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v2.4.0',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: p.metaText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Warm ember halo on the left, mint haze on the right — exactly as in the
/// Figma background layers (`Gradient+Blur` + `Overlay+Blur`).
class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) {
    final p = context.spark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.canvas,
        gradient: RadialGradient(
          center: const Alignment(-0.40, 0.05),
          radius: 0.62,
          colors: [p.haloStart, p.haloMid, p.haloEnd],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.64, -0.11),
            radius: 0.55,
            colors: [p.hazeStart, p.hazeEnd],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

/// "🔥 Igniting Day 14" — 116 × 26, radius full.
class _StreakPill extends StatelessWidget {
  const _StreakPill();

  @override
  Widget build(BuildContext context) {
    final p = context.spark;
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: p.dark ? p.panel : const Color(0xFFF3F4F0),
        borderRadius: BorderRadius.circular(9999),
        border: p.dark ? Border.all(color: p.border) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: p.dark ? 0.35 : 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 11,
            color: p.ember,
          ),
          const SizedBox(width: 5),
          Text(
            'Igniting Day 14',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              height: 12 / 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: p.pillText,
            ),
          ),
        ],
      ),
    );
  }
}

/// 128 × 6 track with a 72 px ember fill.
class _BootProgress extends StatelessWidget {
  const _BootProgress();

  @override
  Widget build(BuildContext context) {
    final p = context.spark;
    return Container(
      width: 128,
      height: 6,
      decoration: BoxDecoration(
        color: p.dark ? p.panel : const Color(0xFFE1E3DF),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 72,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            gradient: LinearGradient(
              colors: [p.emberLight, p.ember],
            ),
          ),
        ),
      ),
    );
  }
}
