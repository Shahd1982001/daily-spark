import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/widgets/spark_app_icon.dart';

/// PURE UI — no state, no navigation, no business logic.
/// Figma: "Daily Spark - Splash Screen" (node 126:13378, 390 × 884).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.onTap});

  /// Preview-only hook: tap anywhere to continue. Real routing comes later.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
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
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: Color(0x6657423B),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.emerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sync Ready',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Color(0xB357423B),
                        ),
                      ),
                    ],
                  ),

                  // ── Brand lockup ──────────────────────────────
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SparkAppIcon(size: 144),
                          SizedBox(height: 16),
                          Text(
                            'Daily Spark',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 26,
                              height: 32 / 26,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.65,
                              color: Color(0xFF191C1A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Small steps compound daily.',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              height: 20 / 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF57423B),
                            ),
                          ),
                          SizedBox(height: 32),
                          _StreakPill(),
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
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0x9957423B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v2.4.0',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: Color(0x6657423B),
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
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        gradient: RadialGradient(
          center: Alignment(-0.40, 0.05),
          radius: 0.62,
          colors: [Color(0x40FDBA54), Color(0x14FF8A54), Color(0x00F8FAF6)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.64, -0.11),
            radius: 0.55,
            colors: [Color(0x33BCEED1), Color(0x00F8FAF6)],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

/// "🔥 Igniting Day 14" — 114 × 24, radius full, #F3F4F0.
class _StreakPill extends StatelessWidget {
  const _StreakPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F0),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            color: AppColors.sparkOrange,
          ),
          const SizedBox(width: 5),
          const Text(
            'Igniting Day 14',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              height: 12 / 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: Color(0xFF57423B),
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
    return Container(
      width: 128,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFE1E3DF),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 72,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8A54), Color(0xFFFF6B2C)],
            ),
          ),
        ),
      ),
    );
  }
}
