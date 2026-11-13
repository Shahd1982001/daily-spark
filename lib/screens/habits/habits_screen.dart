import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/app_bottom_nav.dart';
import 'package:daily_spark/design_system/widgets/app_top_bar.dart';
import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/habits/widgets/habit_tile.dart';

/// PURE UI — Habits.
/// No state container, no network: taps are reported to the parent.
/// Figma: node 126:15648 — 390 × 844 viewport, 1208 of scrollable content.
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({
    super.key,
    this.onProfile,
    this.onSort,
    this.onFilterChanged,
    this.onToggleHabit,
    this.onHabitTap,
    this.onCreateHabit,
    this.onNavTap,
  });

  final VoidCallback? onProfile;
  final VoidCallback? onSort;
  final ValueChanged<int>? onFilterChanged;
  final ValueChanged<int>? onToggleHabit;
  final ValueChanged<int>? onHabitTap;
  final VoidCallback? onCreateHabit;
  final ValueChanged<int>? onNavTap;

  static const _canvas = Color(0xFFF8FAF6);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    return Scaffold(
      backgroundColor: _canvas,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 64 * s, bottom: 152 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _HeaderSection(scale: s, onSort: onSort),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _SnapshotCard(scale: s),
                  ),
                  SizedBox(height: 24 * s),
                  _FilterChips(scale: s, onChanged: onFilterChanged),
                  SizedBox(height: 24 * s),
                  ..._tiles(s),
                  SizedBox(height: 28 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _MindfulStreakNote(scale: s),
                  ),
                  SizedBox(height: 32 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _CreateHabitCta(scale: s, onTap: onCreateHabit),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppTopBar(scale: s, title: 'HABITS', onProfile: onProfile),
          ),
          Positioned(
            left: 16 * s,
            right: 16 * s,
            bottom: 20 * s,
            child: AppBottomNav(
              scale: s,
              selectedIndex: 1,
              onTap: onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _tiles(double s) {
    final data = <Map<String, Object>>[
      {
        'title': 'Morning Meditation',
        'meta': '10 mins \u00b7 Everyday \u00b7 8:00 AM',
        'streak': '12d',
        'icon': Icons.self_improvement,
        'fg': const Color(0xFF406D56),
        'bg': const Color(0xFFBCEED1),
        'done': true,
      },
      {
        'title': 'Hydrate (2.5L)',
        'meta': '2.5L goal \u00b7 Throughout day',
        'streak': '8d',
        'icon': Icons.water_drop_outlined,
        'fg': const Color(0xFF191C1A),
        'bg': const Color(0xFFEDEEEB),
        'done': true,
      },
      {
        'title': 'Read 20 Pages',
        'meta': 'Atomic Habits \u00b7 Evening',
        'streak': '5d',
        'icon': Icons.menu_book_outlined,
        'fg': const Color(0xFF822801),
        'bg': const Color(0xFFFFDBCF),
        'done': true,
      },
      {
        'title': '30-Min Workout / Walk',
        'meta': '5:30 PM \u00b7 4x a week',
        'streak': '19d',
        'icon': Icons.directions_walk_rounded,
        'fg': const Color(0xFF9F3C16),
        'bg': const Color(0x66FFB59C),
        'done': false,
        'next': true,
        'orange_streak': true,
      },
      {
        'title': 'Learn Spanish',
        'meta': '15 mins \u00b7 Everyday \u00b7 Evening',
        'streak': '3d',
        'icon': Icons.translate_rounded,
        'fg': const Color(0xFF7E5300),
        'bg': const Color(0x99FFDDB2),
        'done': false,
      },
      {
        'title': 'Deep Work Block',
        'meta': '90 mins \u00b7 Weekdays \u00b7 Morning',
        'streak': '24d',
        'icon': Icons.work_outline_rounded,
        'fg': const Color(0xFF224F3A),
        'bg': const Color(0xFFBCEED1),
        'done': true,
      },
    ];

    final widgets = <Widget>[];
    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
            16 * s,
            0,
            16 * s,
            i == data.length - 1 ? 0 : 8 * s,
          ),
          child: HabitTile(
            scale: s,
            title: d['title'] as String,
            meta: d['meta'] as String,
            streak: d['streak'] as String,
            icon: d['icon'] as IconData,
            iconColor: d['fg'] as Color,
            iconBackground: d['bg'] as Color,
            completed: d['done'] as bool,
            nextUp: d['next'] == true,
            showStreakPill: d['orange_streak'] != true,
            streakHighlighted: d['orange_streak'] == true,
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
// Title block
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.scale, this.onSort});

  final double scale;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  figmaText(
                    'Habits',
                    size: 26 * s,
                    weight: FontWeight.w600,
                    letterSpacing: -0.65 * s,
                    lineHeight: 32 * s,
                    color: const Color(0xFF191C1A),
                  ),
                  SizedBox(width: 6 * s),
                  figmaText(
                    'spark',
                    size: 18 * s,
                    weight: FontWeight.w400,
                    lineHeight: 22 * s,
                    color: const Color(0xFF9F3C16),
                  ),
                ],
              ),
              SizedBox(height: 2 * s),
              figmaText(
                'Build your routine, one habit at a time.',
                size: 14 * s,
                weight: FontWeight.w400,
                lineHeight: 20 * s,
                color: const Color(0xFF57423B),
              ),
            ],
          ),
        ),
        SizedBox(width: 8 * s),
        GestureDetector(
          onTap: onSort,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44 * s,
            height: 44 * s,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F0),
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 19 * s,
              color: const Color(0xFF57423B),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily spark rhythm snapshot
// ─────────────────────────────────────────────────────────────────────────────
class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12 * s),
      child: Container(
        width: 358 * s,
        height: 114 * s,
        color: Colors.white,
        child: Stack(
          children: [
            // ambient glow
            Positioned(
              left: 286 * s,
              top: 42 * s,
              child: Container(
                width: 96 * s,
                height: 96 * s,
                decoration: const BoxDecoration(
                  color: Color(0x1A9F3C16),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 16 * s,
              top: 19 * s,
              child: Container(
                width: 32 * s,
                height: 32 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDBCF),
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 17 * s,
                  color: const Color(0xFF9F3C16),
                ),
              ),
            ),
            Positioned(
              left: 56 * s,
              top: 16 * s,
              child: figmaText(
                '4 of 6 Completed',
                size: 16 * s,
                weight: FontWeight.w600,
                letterSpacing: -0.08 * s,
                lineHeight: 22 * s,
                color: const Color(0xFF191C1A),
              ),
            ),
            Positioned(
              left: 56 * s,
              top: 38 * s,
              child: Row(
                children: [
                  figmaText(
                    '66% daily spark ignited',
                    size: 12 * s,
                    weight: FontWeight.w400,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: const Color(0xFF57423B),
                  ),
                  SizedBox(width: 6 * s),
                  figmaText(
                    '\u2726',
                    size: 12 * s,
                    weight: FontWeight.w500,
                    lineHeight: 16 * s,
                    color: const Color(0xFF7E5300),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 246 * s,
              top: 20 * s,
              child: figmaText(
                '66%',
                size: 14 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.14 * s,
                lineHeight: 18 * s,
                color: const Color(0xFF9F3C16),
              ),
            ),
            Positioned(
              left: 269 * s,
              top: 38 * s,
              child: figmaText(
                'TARGET 100%',
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.5 * s,
                lineHeight: 12 * s,
                color: const Color(0xFF8A726A),
              ),
            ),
            // progress
            Positioned(
              left: 16 * s,
              top: 66 * s,
              child: Container(
                width: 326 * s,
                height: 8 * s,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEEEB),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 217 * s,
                    height: 8 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9F3C16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            // week day labels
            Positioned(
              left: 16 * s,
              right: 16 * s,
              top: 86 * s,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final label in const ['Mon', 'Tue', 'Wed', 'Thu (Today)', 'Fri', 'Sat', 'Sun'])
                    figmaText(
                      label,
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4 * s,
                      lineHeight: 12 * s,
                      color: label.startsWith('Thu')
                          ? const Color(0xFF9F3C16)
                          : const Color(0xFF57423B),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter chips (horizontally scrollable, as designed)
// ─────────────────────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.scale, this.onChanged});

  final double scale;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const labels = ['All (6)', 'Active Today (5)', 'Paused (1)', 'Morning'];
    return SizedBox(
      height: 36 * s,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16 * s),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) SizedBox(width: 7 * s),
              GestureDetector(
                onTap: () => onChanged?.call(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 32 * s,
                  padding: EdgeInsets.symmetric(horizontal: 16 * s),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == 0 ? const Color(0xFF2E312F) : const Color(0xFFF3F4F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: figmaText(
                    labels[i],
                    size: 12 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.24 * s,
                    lineHeight: 16 * s,
                    color: i == 0 ? const Color(0xFFF0F1EE) : const Color(0xFF57423B),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mindful streak prompt
// ─────────────────────────────────────────────────────────────────────────────
class _MindfulStreakNote extends StatelessWidget {
  const _MindfulStreakNote({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 96 * s,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F0),
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 16 * s,
            child: figmaText(
              'MINDFUL STREAK',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: const Color(0xFF9F3C16),
            ),
          ),
          Positioned(
            left: 16 * s,
            top: 32 * s,
            child: SizedBox(
              width: 258 * s,
              child: figmaText(
                '\u201cSmall disciplines repeated with consistency lead to great '
                'achievements.\u201d',
                size: 12 * s,
                weight: FontWeight.w400,
                letterSpacing: 0.12 * s,
                lineHeight: 16 * s,
                color: const Color(0xFF57423B),
              ),
            ),
          ),
          Positioned(
            left: 302 * s,
            top: 28 * s,
            child: Container(
              width: 40 * s,
              height: 40 * s,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4 * s,
                    offset: Offset(0, 1 * s),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18 * s,
                color: const Color(0xFF9F3C16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Create habit CTA
// ─────────────────────────────────────────────────────────────────────────────
class _CreateHabitCta extends StatelessWidget {
  const _CreateHabitCta({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 358 * s,
        height: 48 * s,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8A54), Color(0xFFFF6B2C)],
          ),
          borderRadius: BorderRadius.circular(12 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B2C).withValues(alpha: 0.25),
              blurRadius: 12 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 16 * s, color: Colors.white),
            SizedBox(width: 8 * s),
            figmaText(
              'Create New Habit',
              size: 14 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.14 * s,
              lineHeight: 18 * s,
              color: Colors.white,
            ),
            SizedBox(width: 8 * s),
            figmaText(
              'spark',
              size: 16 * s,
              weight: FontWeight.w400,
              lineHeight: 20 * s,
              color: const Color(0xFFFFDBCF),
            ),
          ],
        ),
      ),
    );
  }
}
