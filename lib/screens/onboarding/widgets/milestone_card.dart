import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// PAGE 3 visual — the milestone dashboard.
/// Figma: node 126:14455, card 358 × 326 at (16, 111).
class MilestoneCard extends StatelessWidget {
  const MilestoneCard({super.key});

  static const _ink = Color(0xFF191C1A);
  static const _brown = Color(0xFF57423B);
  static const _ember = Color(0xFFFF6B2C);
  static const _deepEmber = Color(0xFF9F3C16);
  static const _sage = Color(0xFF3A6750);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 358,
      height: 326,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 358,
            height: 326,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),

          // Subtle architectural spiral, top-right (clipped by the card)
          Positioned(
            left: 182,
            top: -48,
            child: Opacity(
              opacity: 0.06,
              child: CustomPaint(
                size: const Size(224, 224),
                painter: _SpiralPainter(),
              ),
            ),
          ),

          // Milestone banner
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              width: 189,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.auto_awesome_rounded,
                      size: 13, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  figmaText(
                    'Century Spark Achieved',
                    size: 12,
                    weight: FontWeight.w600,
                    letterSpacing: 0.24,
                    lineHeight: 16,
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 280,
            top: 22,
            child: figmaText(
              'RITUAL LOG',
              size: 10,
              weight: FontWeight.w500,
              letterSpacing: 0.5,
              lineHeight: 12,
              color: const Color(0xFF8A726A),
            ),
          ),

          // Radial progress
          Positioned(
            left: 115,
            top: 52,
            child: SizedBox(
              width: 128,
              height: 128,
              child: CustomPaint(painter: _RingPainter()),
            ),
          ),
          Positioned(
            left: 140,
            top: 78,
            child: SizedBox(
              width: 78,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  figmaText(
                    '88',
                    size: 30,
                    weight: FontWeight.w700,
                    letterSpacing: -0.75,
                    lineHeight: 37.5,
                    color: _ink,
                  ),
                  const SizedBox(width: 2),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(Icons.percent_rounded, size: 13, color: _deepEmber),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 140,
            top: 115,
            child: SizedBox(
              width: 78,
              child: Text(
                'CONSISTENCY',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  height: 2,
                  color: _brown,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),

          // Micro milestone banner
          Positioned(
            left: 86,
            top: 188,
            child: Container(
              width: 187,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEEEB),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _ember,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  figmaText(
                    '100 Days of Sustained Focus',
                    size: 10,
                    weight: FontWeight.w500,
                    letterSpacing: 0.4,
                    lineHeight: 12,
                    color: _ink,
                  ),
                ],
              ),
            ),
          ),

          // Stat capsules
          Positioned(
            left: 16,
            top: 231,
            child: _StatCapsule(
              label: 'TOTAL',
              value: '142',
              suffix: 'd',
              caption: 'In Flow',
              captionColor: _sage,
            ),
          ),
          Positioned(
            left: 127,
            top: 231,
            child: _StatCapsule(
              label: 'RITUALS',
              value: '6',
              suffix: 'act',
              caption: 'No Delays',
              captionColor: _deepEmber,
            ),
          ),
          Positioned(
            left: 239,
            top: 231,
            child: _StatCapsule(
              label: 'SPARK',
              value: '24',
              suffix: '',
              caption: 'Week High',
              captionColor: _brown,
              valueColor: _ember,
              showFlame: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCapsule extends StatelessWidget {
  const _StatCapsule({
    required this.label,
    required this.value,
    required this.suffix,
    required this.caption,
    required this.captionColor,
    this.valueColor = const Color(0xFF191C1A),
    this.showFlame = false,
  });

  final String label;
  final String value;
  final String suffix;
  final String caption;
  final Color captionColor;
  final Color valueColor;
  final bool showFlame;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 103,
      height: 79,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 2,
              color: Color(0xFF57423B),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showFlame)
                const Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(Icons.auto_awesome,
                      size: 9, color: Color(0xFFFF6B2C)),
                ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.18,
                  height: 24 / 18,
                  color: valueColor,
                  decoration: TextDecoration.none,
                ),
              ),
              if (suffix.isNotEmpty)
                Text(
                  suffix,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.18,
                    height: 24 / 10,
                    color: Color(0xFF8A726A),
                    decoration: TextDecoration.none,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            caption,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 2,
              color: captionColor,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// 88% ember arc with a soft track.
class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xFFEDEEEB),
    );

    const start = -0.9075712; // -52° — where the ember marker sits
    const sweep = math.pi * 2 * 0.88;
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + sweep,
          colors: [Color(0xFF34D399), Color(0xFF10B981)],
        ).createShader(rect),
    );

    // Ember end-cap marker
    const endAngle = start; // marker marks the arc start (top-right)
    final center = rect.center;
    final marker = Offset(
      center.dx + rect.width / 2 * math.cos(endAngle),
      center.dy + rect.height / 2 * math.sin(endAngle),
    );
    canvas.drawCircle(marker, 5, Paint()..color = const Color(0xFF9F3C16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Faint concentric spiral used as background architecture on page 3.
class _SpiralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF191C1A);

    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, size.width / 2 * (i / 4), paint);
    }
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
