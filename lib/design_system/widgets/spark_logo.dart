import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';


/// Daily Spark brand mark: a soft squircle holding the spark logo artwork
/// (`assets/brand/spark_logo.png`, supplied by the brand owner).
class SparkLogo extends StatelessWidget {
  const SparkLogo({
    super.key,
    this.size = 96,
    this.showTile = true,
  });

  final double size;
  final bool showTile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glyph = Image.asset(
      'assets/brand/spark_logo.png',
      width: size * 0.62,
      height: size * 0.62,
      filterQuality: FilterQuality.high,
    );

    if (!showTile) return glyph;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? p.panel : Colors.white,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: isDark ? p.bone : Colors.white,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: p.ember.withValues(alpha: 0.10),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(child: glyph),
    );
  }
}
