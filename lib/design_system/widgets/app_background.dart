import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

/// The signature Daily Spark background: warm cream canvas with a soft
/// ember glow bleeding from the top of the screen (no hard edges).
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.glow = true,
  });

  final Widget child;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [Color(0xFF171A19), p.canvas]
                    : [Color(0xFFFFFCF8), p.canvas],
              ),
            ),
          ),
        ),
        if (glow)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1.15),
                    radius: 1.45,
                    colors: [
                      p.ember.withValues(alpha: isDark ? 0.16 : 0.13),
                      p.emberSoft.withValues(alpha: isDark ? 0.06 : 0.16),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),
          ),
        Positioned.fill(child: child),
      ],
    );
  }
}
