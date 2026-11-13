import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/app_bottom_nav.dart';
import 'package:daily_spark/design_system/widgets/app_top_bar.dart';
import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/progress/widgets/consistency_row.dart';
import 'package:daily_spark/screens/progress/widgets/milestone_card.dart';
import 'package:daily_spark/screens/progress/widgets/momentum_hero_card.dart';
import 'package:daily_spark/screens/progress/widgets/streak_card.dart';
import 'package:daily_spark/screens/progress/widgets/weekly_rhythm_card.dart';

/// PURE UI — Progress & Momentum.
/// No state container, no network: taps are reported to the parent.
/// Figma: node 126:15950 — 390 × 844 viewport, 1883 of content.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    this.onProfile,
    this.onBell,
    this.onTimeframeSelected,
    this.onShare,
    this.onNavTap,
  });

  final VoidCallback? onProfile;
  final VoidCallback? onBell;
  final ValueChanged<int>? onTimeframeSelected;
  final VoidCallback? onShare;
  final ValueChanged<int>? onNavTap;

  static const _ink = Color(0xFF191C1A);
  static const _brown = Color(0xFF57423B);

  static const _timeframes = ['This Week', 'This Month', 'All Time'];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF6),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 64 * s, bottom: 152 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _headerBlock(s),
                  SizedBox(height: 24 * s),
                  MomentumHeroCard(scale: s),
                  _weeklyRhythmBlock(s),
                  _streakBlock(s),
                  _consistencyBlock(s),
                  _milestoneBlock(s),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppTopBar(
              scale: s,
              title: 'Progress',
              brandColor: const Color(0xFF9F3C16),
              showBell: true,
              onBell: onBell,
              onProfile: onProfile,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24 * s,
            child: Center(
              child: SizedBox(
                width: 350 * s,
                child: AppBottomNav(
                  scale: s,
                  selectedIndex: 2,
                height: 62,
                horizontalPadding: 13,
                selectedWidth: 108,
                selectedHeight: 36,
                labelSize: 12,
                  iconSize: 21,
                  frosted: true,
                  icons: const [
                    Icons.home_outlined,
                    Icons.checklist_rounded,
                    Icons.insights_rounded,
                    Icons.person_outline_rounded,
                  ],
                  onTap: onNavTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header + timeframe ────────────────────────────────────────────
  Widget _headerBlock(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: SizedBox(
        height: 112 * s,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 4 * s,
              child: figmaText(
                'Progress',
                size: 26 * s,
                weight: FontWeight.w600,
                letterSpacing: -0.65 * s,
                lineHeight: 32 * s,
                color: _ink,
              ),
            ),
            Positioned(
              left: 235 * s,
              top: 12 * s,
              child: Container(
                width: 123 * s,
                height: 16 * s,
                padding: EdgeInsets.only(left: 8 * s, right: 8 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDBCF),
                  borderRadius: BorderRadius.circular(999 * s),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9F3C16).withValues(alpha: 0.10),
                      blurRadius: 6 * s,
                      offset: Offset(0, 2 * s),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded,
                        size: 11 * s, color: const Color(0xFF9F3C16)),
                    SizedBox(width: 4 * s),
                    figmaText(
                      'Momentum Active',
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4 * s,
                      lineHeight: 12 * s,
                      color: const Color(0xFF390C00),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 40 * s,
              child: SizedBox(
                width: 358 * s,
                child: figmaText(
                  "See how far you've come. Every small spark counts.",
                  size: 14 * s,
                  weight: FontWeight.w400,
                  lineHeight: 20 * s,
                  color: _brown,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 76 * s,
              child: Container(
                width: 358 * s,
                height: 36 * s,
                padding: EdgeInsets.symmetric(horizontal: 4 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEEEB),
                  borderRadius: BorderRadius.circular(999 * s),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < _timeframes.length; i++) ...[
                      if (i > 0) SizedBox(width: 8 * s),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onTimeframeSelected?.call(i),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 28 * s,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i == 0
                                  ? const Color(0xFFFF6B2C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999 * s),
                            ),
                            child: figmaText(
                              _timeframes[i],
                              size: 12 * s,
                              weight: FontWeight.w500,
                              letterSpacing: 0.24 * s,
                              lineHeight: 16 * s,
                              color: i == 0 ? Colors.white : _brown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 2 · Weekly Rhythm ─────────────────────────────────────────────
  Widget _weeklyRhythmBlock(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 16 * s, right: 16 * s, top: 24 * s),
      child: Column(
        children: [
          SizedBox(
            height: 24 * s,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Row(
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 14 * s, color: const Color(0xFF9F3C16)),
                      SizedBox(width: 8 * s),
                      figmaText(
                        'Weekly Rhythm',
                        size: 18 * s,
                        weight: FontWeight.w600,
                        letterSpacing: -0.18 * s,
                        lineHeight: 24 * s,
                        color: _ink,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 4 * s,
                  child: Container(
                    width: 115 * s,
                    height: 16 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBCEED1),
                      borderRadius: BorderRadius.circular(999 * s),
                    ),
                    child: figmaText(
                      'Top Day: Thursday',
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4 * s,
                      lineHeight: 12 * s,
                      color: const Color(0xFF406D56),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * s),
          WeeklyRhythmCard(scale: s),
        ],
      ),
    );
  }

  // ── Section 3 · Streak ────────────────────────────────────────────────────
  Widget _streakBlock(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 16 * s, right: 16 * s, top: 24 * s),
      child: StreakCard(scale: s),
    );
  }

  // ── Section 4 · Habit Consistency ─────────────────────────────────────────
  Widget _consistencyBlock(double s) {
    const rows = [
      (
        'Hydrate (2.5L)',
        '13 of 14 days completed',
        '92%',
        Color(0xFF9F3C16),
        Color(0xFF9F3C16),
        300.0,
        Icons.water_drop_rounded,
      ),
      (
        'Read 20 Pages',
        '12 of 14 days completed',
        '85%',
        Color(0xFF7E5300),
        Color(0xFF9F6A00),
        277.0,
        Icons.menu_book_rounded,
      ),
      (
        'Morning Meditation',
        '11 of 14 days completed',
        '78%',
        Color(0xFF3A6750),
        Color(0xFF10B981),
        254.0,
        Icons.self_improvement_rounded,
      ),
      (
        '30-Min Movement',
        '9 of 14 days completed',
        '64%',
        Color(0xFFBF542C),
        Color(0xFFBF542C),
        209.0,
        Icons.directions_run_rounded,
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(left: 16 * s, right: 16 * s, top: 24 * s),
      child: Column(
        children: [
          SizedBox(
            height: 24 * s,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          size: 17 * s, color: const Color(0xFF9F3C16)),
                      SizedBox(width: 8 * s),
                      figmaText(
                        'Habit Consistency',
                        size: 18 * s,
                        weight: FontWeight.w600,
                        letterSpacing: -0.18 * s,
                        lineHeight: 24 * s,
                        color: _ink,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 4 * s,
                  child: Container(
                    width: 62 * s,
                    height: 16 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEEEB),
                      borderRadius: BorderRadius.circular(999 * s),
                    ),
                    child: figmaText(
                      '4 Active',
                      size: 10 * s,
                      weight: FontWeight.w500,
                      letterSpacing: 0.4 * s,
                      lineHeight: 12 * s,
                      color: _brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * s),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 8 * s),
            ConsistencyRow(
              scale: s,
              title: rows[i].$1,
              subtitle: rows[i].$2,
              percent: rows[i].$3,
              accent: rows[i].$4,
              fill: rows[i].$5,
              fillWidth: rows[i].$6,
              icon: rows[i].$7,
            ),
          ],
        ],
      ),
    );
  }

  // ── Section 5 · Milestone ─────────────────────────────────────────────────
  Widget _milestoneBlock(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 16 * s, right: 16 * s, top: 24 * s),
      child: MilestoneCard(scale: s, onShare: onShare),
    );
  }
}
