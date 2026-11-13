import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/app_colors.dart';

/// The signature Daily Spark background: warm cream canvas with a soft
/// ember glow bleeding from the top of the screen.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.glow = true,
    this.glowAlignment = Alignment.topCenter,
  });

  final Widget child;
  final bool glow;
  final Alignment glowAlignment;

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
                    ? const [Color(0xFF171A19), AppColors.darkCanvas]
                    : const [Color(0xFFFFFCF8), AppColors.canvas],
              ),
            ),
          ),
        ),
        if (glow)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: glowAlignment,
                child: FractionallySizedBox(
                  heightFactor: 0.45,
                  widthFactor: 1.4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.75,
                        colors: [
                          AppColors.sparkOrange.withValues(alpha: isDark ? 0.14 : 0.11),
                          AppColors.peachSoft.withValues(alpha: isDark ? 0.05 : 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
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
