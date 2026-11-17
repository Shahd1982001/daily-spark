import 'package:daily_spark/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/app_bottom_nav.dart';
import 'package:daily_spark/design_system/widgets/app_top_bar.dart';
import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/progress/widgets/consistency_row.dart';
import 'package:daily_spark/screens/progress/widgets/milestone_card.dart';
import 'package:daily_spark/screens/progress/widgets/momentum_hero_card.dart';
import 'package:daily_spark/screens/progress/widgets/streak_card.dart';
import 'package:daily_spark/screens/progress/widgets/weekly_rhythm_card.dart';
import 'package:daily_spark/screens/home/widgets/habit_card_style.dart' show habitIcon, habitAccentColours;
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/progress_providers.dart';

/// PURE UI — Progress & Momentum.
/// No state container, no network: taps are reported to the parent.
/// Figma: node 126:15950 — 390 × 844 viewport, 1883 of content.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({
    super.key,
    this.onProfile,
    this.onBell,
    this.onShare,
    this.onNavTap,
  });

  final VoidCallback? onProfile;
  final VoidCallback? onBell;
  final VoidCallback? onShare;
  final ValueChanged<int>? onNavTap;

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  static Color get _ink => p.ink;
  static Color get _brown => p.body;

  static const _timeframes = ['This Week', 'This Month', 'All Time'];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    final stats = ref.watch(rangeStatsProvider);
    final rhythm = ref.watch(weeklyRhythmProvider);
    final range = ref.watch(progressRangeProvider);
    final streak = ref.watch(bestHabitStreakProvider);
    final best = ref.watch(personalBestProvider);
    final rangeIndex = ProgressRange.values.indexOf(range);
    final hasHabits = ref.watch(habitsProvider).valueOrNull?.habits.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: p.canvas,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 64 * s, bottom: 152 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _headerBlock(s, rangeIndex),
                  SizedBox(height: 24 * s),
                  if (!hasHabits)
                    _progressEmptyState(s)
                  else ...[
                    MomentumHeroCard(
                      scale: s,
                      percent: stats.percent / 100,
                      hits: stats.completed,
                      scheduled: stats.scheduled,
                    ),
                    _weeklyRhythmBlock(s, rhythm),
                    _streakBlock(s, streak, best),
                    _consistencyBlock(s, stats),
                    _milestoneBlock(s),
                  ],
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

              brandColor: p.emberDeep,
              showBell: true,
              onBell: widget.onBell,
              onProfile: widget.onProfile,
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
                  onTap: widget.onNavTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header + timeframe ────────────────────────────────────────────
  Widget _headerBlock(double s, int rangeIndex) {
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
                  color: p.chipEmber,
                  borderRadius: BorderRadius.circular(999 * s),
                  boxShadow: [
                    BoxShadow(
                      color: p.emberDeep.withValues(alpha: 0.10),
                      blurRadius: 6 * s,
                      offset: Offset(0, 2 * s),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded,
                        size: 11 * s, color: p.emberDeep),
                    SizedBox(width: 4 * s),
                    figmaText(
                      'Momentum Active',
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4 * s,
                      lineHeight: 12 * s,
                      color: p.onEmberSoft,
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
                  color: p.dark ? p.canvas : p.container,
                  borderRadius: BorderRadius.circular(999 * s),
                  border: p.dark
                      ? Border.all(
                          color: p.bone.withValues(alpha: 0.35), width: 1 * s)
                      : null,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < _timeframes.length; i++) ...[
                      if (i > 0) SizedBox(width: 8 * s),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => ref
                              .read(progressRangeProvider.notifier)
                              .state = ProgressRange.values[i],
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 28 * s,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i == rangeIndex
                                  ? p.ember
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999 * s),
                            ),
                            child: figmaText(
                              _timeframes[i],
                              size: 12 * s,
                              weight: FontWeight.w500,
                              letterSpacing: 0.24 * s,
                              lineHeight: 16 * s,
                              color: i == rangeIndex ? Colors.white : _brown,
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
  Widget _weeklyRhythmBlock(double s, List<RhythmDay> rhythm) {
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
                          size: 14 * s, color: p.emberDeep),
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
                      color: p.chipGreen,
                      borderRadius: BorderRadius.circular(999 * s),
                    ),
                    child: figmaText(
                      _topDayLabel(rhythm),
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4 * s,
                      lineHeight: 12 * s,
                      color: p.pine,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * s),
          WeeklyRhythmCard(scale: s, days: rhythm),
        ],
      ),
    );
  }

  // ── Section 3 · Streak ────────────────────────────────────────────────────
  Widget _streakBlock(double s, int streak, int best) {
    return Padding(
      padding: EdgeInsets.only(left: 16 * s, right: 16 * s, top: 24 * s),
      child: StreakCard(scale: s, days: streak, personalBest: best),
    );
  }

  static String _topDayLabel(List<RhythmDay> rhythm) {
    if (rhythm.isEmpty) return 'Top Day: —';
    var best = rhythm.first;
    var any = false;
    for (final day in rhythm) {
      if (day.percent > best.percent) {
        best = day;
        any = true;
      }
      if (day.percent > 0) any = true;
    }
    if (!any) return 'Top Day: —';
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return tr('Top Day: {day}', {'day': tr(names[best.day.weekday - 1])});
  }

  // ── Section 4 · Habit Consistency (real data) ─────────────────────────────
  Widget _consistencyBlock(double s, RangeStats stats) {
    final rows = stats.habits;
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
                          size: 17 * s, color: p.emberDeep),
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
                    height: 16 * s,
                    padding: EdgeInsets.symmetric(horizontal: 8 * s),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.container,
                      borderRadius: BorderRadius.circular(999 * s),
                    ),
                    child: figmaText(
                      tr('{n} Active', {'n': '${rows.length}'}),
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
          if (rows.isEmpty)
            Container(
              width: 358 * s,
              padding: EdgeInsets.symmetric(vertical: 22 * s),
              decoration: BoxDecoration(
                color: p.panel,
                borderRadius: BorderRadius.circular(16 * s),
              ),
              child: Center(
                child: figmaText(
                  'No consistency data in this range yet.',
                  size: 12 * s,
                  weight: FontWeight.w500,
                  lineHeight: 16 * s,
                  color: _brown,
                ),
              ),
            ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 8 * s),
            ConsistencyRow(
              scale: s,
              title: rows[i].habit.title,
              subtitle: tr('{completed} of {scheduled} days completed', {
                    'completed': '${rows[i].completed}',
                    'scheduled': '${rows[i].scheduled}',
                  }),
              percent: '${rows[i].percent}%',
              accent: habitAccentColours(rows[i].habit.accent).$1,
              fill: habitAccentColours(rows[i].habit.accent).$1,
              fillWidth: 326 * s * (rows[i].percent / 100).clamp(0.02, 1.0),
              icon: habitIcon(rows[i].habit.iconKey),
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _progressEmptyState(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: Container(
        width: 358 * s,
        padding: EdgeInsets.fromLTRB(24 * s, 28 * s, 24 * s, 26 * s),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: p.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48 * s,
              height: 48 * s,
              decoration: BoxDecoration(
                color: p.chipEmber,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/brand/spark_logo.png',
                  width: 26 * s,
                  height: 26 * s,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            SizedBox(height: 18 * s),
            figmaText(
              'Your progress starts here',
              size: 20 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.5 * s,
              lineHeight: 26 * s,
              color: p.ink,
            ),
            SizedBox(height: 6 * s),
            figmaText(
              'Nothing to measure yet — complete a habit on Home and this page '
              'fills up: weekly rhythm, streaks and consistency.',
              size: 13 * s,
              weight: FontWeight.w400,
              lineHeight: 20 * s,
              color: p.body,
              width: 300 * s,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 5 · Milestone ─────────────────────────────────────────────────
  Widget _milestoneBlock(double s) {
    return Padding(
      padding: EdgeInsets.only(left: 16 * s, right: 16 * s, top: 24 * s),
      child: MilestoneCard(scale: s, onShare: widget.onShare),
    );
  }
}
