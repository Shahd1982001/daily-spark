import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/app_bottom_nav.dart';
import 'package:daily_spark/design_system/widgets/app_top_bar.dart';
import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/home/widgets/habit_card.dart';
import 'package:daily_spark/screens/home/widgets/pulse_card.dart';

/// PURE UI — Home.
/// No state container, no network: taps are reported to the parent.
/// Figma: node 126:15685 — 390 × 844 viewport, 1252 of scrollable content.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onProfile,
    this.onToggleHabit,
    this.onHabitTap,
    this.onNewRitual,
    this.onFilterChanged,
    this.onNavTap,
  });

  final VoidCallback? onProfile;
  final ValueChanged<int>? onToggleHabit;
  final ValueChanged<int>? onHabitTap;
  final VoidCallback? onNewRitual;
  final ValueChanged<int>? onFilterChanged;
  final ValueChanged<int>? onNavTap;

  static Color get _canvas => p.canvas;
  static Color get _ink => p.ink;
  static Color get _brown => p.body;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    return Scaffold(
      backgroundColor: _canvas,
      body: Stack(
        children: [
          // ── Scrollable content ─────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 64 * s, bottom: 140 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _Greeting(scale: s),
                  ),
                  SizedBox(height: 16 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: PulseCard(scale: s),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _RoutineHeader(
                      scale: s,
                      onNewRitual: onNewRitual,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _FilterPills(
                      scale: s,
                      onChanged: onFilterChanged,
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  ..._habitCards(s),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _ClarityNote(scale: s),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating top bar ───────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppTopBar(scale: s, title: 'Home', onProfile: onProfile),
          ),

          // ── Floating bottom navigation ─────────────────────────────
          Positioned(
            left: 16 * s,
            right: 16 * s,
            bottom: 20 * s,
            child: AppBottomNav(
              scale: s,
              selectedIndex: 0,
              selectedWidth: 81,
              onTap: onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _habitCards(double s) {
    final data = <Map<String, Object>>[
      {
        'title': 'Morning Meditation',
        'meta': ['10 mins', '8:00 AM'],
        'streak': '12d',
        'icon': Icons.self_improvement,
        'iconColor': p.success,
        'bg': p.mintSoft,
        'done': true,
      },
      {
        'title': 'Hydrate (1.5L)',
        'meta': ['Goal: 2.5L', 'Anytime'],
        'streak': '8d',
        'icon': Icons.water_drop_outlined,
        'iconColor': p.success,
        'bg': p.mintSoft,
        'done': true,
      },
      {
        'title': 'Read 20 Pages',
        'meta': ['Atomic Habits', 'Evening'],
        'streak': '5d',
        'icon': Icons.menu_book_outlined,
        'iconColor': p.success,
        'bg': p.mintSoft,
        'done': true,
      },
      {
        'title': '30-Min Workout / Walk',
        'meta': ['5:30 PM', '350 kcal'],
        'streak': '19d',
        'icon': Icons.directions_walk_rounded,
        'iconColor': p.emberDark,
        'bg': p.creamSoft,
        'done': false,
        'next': true,
      },
      {
        'title': 'Evening Journal',
        'meta': ['9:30 PM', 'Reflection'],
        'streak': '7d',
        'icon': Icons.edit_note_rounded,
        'iconColor': p.body,
        'bg': p.bone,
        'done': false,
      },
    ];

    final widgets = <Widget>[];
    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(16 * s, 0, 16 * s, i == data.length - 1 ? 0 : 12 * s),
          child: HabitCard(
            scale: s,
            title: d['title'] as String,
            meta: (d['meta'] as List).cast<String>(),
            streak: d['streak'] as String,
            icon: d['icon'] as IconData,
            iconColor: d['iconColor'] as Color,
            iconBackground: d['bg'] as Color,
            completed: d['done'] as bool,
            showNextBadge: d['next'] == true,
            onToggle: () => onToggleHabit?.call(i),
            onTap: () => onHabitTap?.call(i),
          ),
        ),
      );
    }
    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting block
// ─────────────────────────────────────────────────────────────────────────────
class _Greeting extends StatelessWidget {
  const _Greeting({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            figmaText(
              'WEDNESDAY, OCT 25',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: p.body,
            ),
            Container(
              width: 4 * s,
              height: 4 * s,
              margin: EdgeInsets.symmetric(horizontal: 6 * s),
              decoration: BoxDecoration(
                color: p.warmBorder,
                shape: BoxShape.circle,
              ),
            ),
            figmaText(
              'Autumn Rhythm',
              size: 10 * s,
              weight: FontWeight.w500,
              letterSpacing: 0.4 * s,
              lineHeight: 12 * s,
              color: p.sage,
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        figmaText(
          'Good morning, Shahd',
          size: 22 * s,
          weight: FontWeight.w600,
          letterSpacing: -0.55 * s,
          lineHeight: 28 * s,
          color: p.ink,
        ),
        SizedBox(height: 2 * s),
        figmaText(
          '3 of 5 habits completed for today. Keep the spark alive.',
          size: 14 * s,
          weight: FontWeight.w400,
          lineHeight: 20 * s,
          color: p.body,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Today's Routine" header
// ─────────────────────────────────────────────────────────────────────────────
class _RoutineHeader extends StatelessWidget {
  const _RoutineHeader({required this.scale, this.onNewRitual});

  final double scale;
  final VoidCallback? onNewRitual;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 28 * s,
      child: Row(
        children: [
          figmaText(
            "Today's Routine",
            size: 18 * s,
            weight: FontWeight.w600,
            letterSpacing: -0.45 * s,
            lineHeight: 24 * s,
            color: p.ink,
          ),
          SizedBox(width: 4 * s),
          Container(
            height: 16 * s,
            padding: EdgeInsets.symmetric(horizontal: 8 * s),
            decoration: BoxDecoration(
              color: p.bone,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Center(
              child: figmaText(
                '5 total',
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.4 * s,
                lineHeight: 12 * s,
                color: p.body,
              ),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: onNewRitual,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 28 * s,
              padding: EdgeInsets.symmetric(horizontal: 12 * s),
              decoration: BoxDecoration(
                color: p.bone,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_rounded, size: 12 * s, color: p.ink),
                  SizedBox(width: 5 * s),
                  figmaText(
                    'New Ritual',
                    size: 12 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.24 * s,
                    lineHeight: 16 * s,
                    color: p.ink,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented filter pills
// ─────────────────────────────────────────────────────────────────────────────
class _FilterPills extends StatelessWidget {
  const _FilterPills({required this.scale, this.onChanged});

  final double scale;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const labels = ['All (5)', 'Morning (2)', 'Anytime (2)', 'Evening (1)'];
    const widths = [61.0, 95.0, 95.0, 91.0];
    return SizedBox(
      height: 36 * s,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) SizedBox(width: 4 * s),
            GestureDetector(
              onTap: () => onChanged?.call(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: widths[i] * s,
                height: 28 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == 0 ? p.slate : p.panel,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: figmaText(
                  labels[i],
                  size: 12 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.24 * s,
                  lineHeight: 16 * s,
                  color: i == 0 ? p.panel : p.body,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily clarity note
// ─────────────────────────────────────────────────────────────────────────────
class _ClarityNote extends StatelessWidget {
  const _ClarityNote({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 174 * s,
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 18 * s,
            child: Container(
              width: 32 * s,
              height: 32 * s,
              decoration: BoxDecoration(
                color: p.goldSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                size: 17 * s,
                color: p.ochre,
              ),
            ),
          ),
          Positioned(
            left: 56 * s,
            top: 16 * s,
            child: figmaText(
              'DAILY CLARITY',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: p.ochre,
            ),
          ),
          Positioned(
            left: 56 * s,
            top: 30 * s,
            child: figmaText(
              '\u201cYou do not rise to the level of your goals. You fall to the '
              'level of your systems.\u201d',
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: p.body,
              width: 270 * s,
            ),
          ),
        ],
      ),
    );
  }
}
