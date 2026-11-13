import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// Profile · Identity card — Figma 358 × 264.5, r16.
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({
    super.key,
    required this.scale,
    this.name = 'Shahd',
    this.bio = 'Building better habits, one deliberate day at a time.',
    this.status = 'Mindful Builder · Since Oct 2023',
  });

  final double scale;
  final String name;
  final String bio;
  final String status;

  static Color get _brown => p.body;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 264.5 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * s),
        child: Stack(
          children: [
            // top accent bar
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 6 * s,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [p.ember, Color(0xFFFF8550)],
                  ),
                ),
              ),
            ),
            // avatar
            Positioned(
              left: 139 * s,
              top: 28 * s,
              child: Container(
                width: 80 * s,
                height: 80 * s,
                decoration: BoxDecoration(
                  color: p.panel,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4 * s,
                      offset: Offset(0, 2 * s),
                      spreadRadius: -1 * s,
                    ),
                  ],
                ),
                child: Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/brand/avatar_shahd_lg.png',
                      width: 72 * s,
                      height: 72 * s,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
            // spark indicator
            Positioned(
              left: 195 * s,
              top: 84 * s,
              child: Container(
                width: 24 * s,
                height: 24 * s,
                decoration: BoxDecoration(
                  color: p.ember,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: p.ember.withValues(alpha: 0.35),
                      blurRadius: 6 * s,
                      offset: Offset(0, 2 * s),
                    ),
                  ],
                ),
                child: Icon(Icons.local_fire_department_rounded,
                    size: 12 * s, color: Colors.white),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 121 * s,
              child: Center(
                child: figmaText(
                  name,
                  size: 22 * s,
                  weight: FontWeight.w600,
                  letterSpacing: -0.55 * s,
                  lineHeight: 28 * s,
                  color: p.ink,
                ),
              ),
            ),
            Positioned(
              left: 28 * s,
              top: 155.4 * s,
              width: 302 * s,
              child: figmaText(
                bio,
                size: 14 * s,
                weight: FontWeight.w500,
                lineHeight: 23 * s,
                align: TextAlign.center,
                color: _brown,
              ),
            ),
            // status pill
            Positioned(
              left: 75.7 * s,
              top: 217.5 * s,
              child: Container(
                width: 202 * s,
                height: 20.5 * s,
                padding: EdgeInsets.symmetric(horizontal: 12 * s),
                decoration: BoxDecoration(
                  color: p.dark
                      ? p.ember.withValues(alpha: 0.16)
                      : p.emberSoft.withValues(alpha: 0.50),
                  borderRadius: BorderRadius.circular(999 * s),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded,
                        size: 13 * s, color: p.emberDeep),
                    SizedBox(width: 6 * s),
                    figmaText(
                      status,
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.25 * s,
                      lineHeight: 12 * s,
                      color: p.emberDeep,
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
