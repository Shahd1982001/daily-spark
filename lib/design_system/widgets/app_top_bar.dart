import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Frosted floating top bar shared by the app shell screens.
/// Figma: 390 × 64, brand lockup on the left, avatar on the right.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.scale,
    required this.title,
    this.brandColor = const Color(0xFF57423B),
    this.showBell = false,
    this.onBell,
    this.onProfile,
  });

  final double scale;
  final String title;
  final Color brandColor;
  final bool showBell;
  final VoidCallback? onBell;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12 * s, sigmaY: 12 * s),
        child: Container(
          height: 64 * s,
          color: const Color(0xFFF8FAF6).withValues(alpha: 0.85),
          child: Stack(
            children: [
              Positioned(
                left: 16 * s,
                top: 16 * s,
                child: Image.asset(
                  'assets/brand/home_logo.png',
                  width: 32 * s,
                  height: 32 * s,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                left: 56 * s,
                top: 15 * s,
                child: figmaText(
                  'DAILY SPARK',
                  size: 10 * s,
                  weight: FontWeight.w600,
                  letterSpacing: 0.5 * s,
                  lineHeight: 12 * s,
                  color: brandColor,
                ),
              ),
              Positioned(
                left: 56 * s,
                top: 27 * s,
                child: figmaText(
                  title,
                  size: 16 * s,
                  weight: FontWeight.w600,
                  letterSpacing: -0.08 * s,
                  lineHeight: 22 * s,
                  color: const Color(0xFF191C1A),
                ),
              ),
              if (showBell)
                Positioned(
                  left: 282 * s,
                  top: 10 * s,
                  child: GestureDetector(
                    onTap: onBell,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 44 * s,
                      height: 44 * s,
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 20 * s,
                        color: const Color(0xFF57423B),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 330 * s,
                top: 10 * s,
                child: GestureDetector(
                  onTap: onProfile,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 44 * s,
                    height: 44 * s,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 6 * s,
                          top: 6 * s,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/brand/avatar_shahd.png',
                              width: 32 * s,
                              height: 32 * s,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 28 * s,
                          top: 6 * s,
                          child: Container(
                            width: 10 * s,
                            height: 10 * s,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9F3C16),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5 * s),
                            ),
                          ),
                        ),
                      ],
                    ),
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
