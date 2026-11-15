import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/app_bottom_nav.dart';
import 'package:daily_spark/design_system/widgets/app_top_bar.dart';
import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/habits/widgets/habit_tile.dart';
import 'package:daily_spark/screens/home/widgets/habit_card_style.dart' show habitIcon, habitAccentColours, habitTimeLabel, habitMetaLine;
import 'package:daily_spark/state/habit_providers.dart';

/// Habits — driven by the habit store.
/// Figma: node 126:15648 (data-filled state) · empty state designed in-system.
class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({
    super.key,
    this.onProfile,
    this.onSort,
    this.onHabitTap,
    this.onCreateHabit,
    this.onNavTap,
  });

  final VoidCallback? onProfile;
  final VoidCallback? onSort;
  final ValueChanged<String>? onHabitTap;
  final VoidCallback? onCreateHabit;
  final ValueChanged<int>? onNavTap;

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    final snapshot = ref.watch(habitsProvider).valueOrNull;
    final todayHabits = ref.watch(todayHabitsProvider);
    final summary = ref.watch(todaySummaryProvider);
    final week = ref.watch(lastSevenDaysProvider);

    final allHabits = snapshot?.activeHabits ?? const <Habit>[];
    final paused = snapshot?.habits.where((h) => h.isArchived).toList() ?? const <Habit>[];
    final isEmpty = allHabits.isEmpty && paused.isEmpty;

    final labels = [
      'All (${allHabits.length})',
      'Today (${todayHabits.length})',
      'Paused (${paused.length})',
    ];
    final active = _filter.clamp(0, labels.length - 1);
    final visible = switch (active) {
      1 => todayHabits,
      2 => paused,
      _ => allHabits,
    };
    final nextUpId = todayHabits
        .where((h) => !(snapshot?.isCompleted(h.id, DateTime.now()) ?? false))
        .map((h) => h.id)
        .firstOrNull;

    return Scaffold(
      backgroundColor: p.canvas,
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
                    child: _HeaderSection(scale: s, onSort: widget.onSort),
                  ),
                  if (isEmpty) ...[
                    SizedBox(height: 24 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: _EmptyHabits(
                        scale: s,
                        onCreateHabit: widget.onCreateHabit,
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: 24 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: _SnapshotCard(
                        scale: s,
                        completed: summary.completed,
                        total: summary.total,
                        percent: summary.percent,
                        week: [for (final d in week) d],
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    _FilterChips(
                      scale: s,
                      labels: labels,
                      selected: active,
                      onChanged: (i) => setState(() => _filter = i),
                    ),
                    SizedBox(height: 24 * s),
                    if (visible.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * s),
                        child: _EmptyFilter(scale: s, label: labels[active]),
                      ),
                    for (var i = 0; i < visible.length; i++)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16 * s,
                          0,
                          16 * s,
                          i == visible.length - 1 ? 0 : 8 * s,
                        ),
                        child: _HabitTileRow(
                          key: ValueKey(visible[i].id),
                          scale: s,
                          habit: visible[i],
                          completed: snapshot?.isCompleted(
                                  visible[i].id, DateTime.now()) ??
                              false,
                          nextUp: visible[i].id == nextUpId,
                          onToggle: () => ref
                              .read(habitsProvider.notifier)
                              .toggle(visible[i].id),
                          onTap: () => widget.onHabitTap?.call(visible[i].id),
                        ),
                      ),
                    SizedBox(height: 28 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: _MindfulStreakNote(
                        scale: s,
                        streakDays: ref.watch(routineStreakProvider),
                      ),
                    ),
                    SizedBox(height: 32 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: _CreateHabitCta(
                        scale: s,
                        onTap: widget.onCreateHabit,
                      ),
                    ),
                  ],
                  SizedBox(height: 20 * s),
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
              title: 'HABITS',
              onProfile: widget.onProfile,
            ),
          ),
          Positioned(
            left: 16 * s,
            right: 16 * s,
            bottom: 20 * s,
            child: AppBottomNav(
              scale: s,
              selectedIndex: 1,
              onTap: widget.onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// One habit tile, bound to the store
// ─────────────────────────────────────────────────────────────────────────────
class _HabitTileRow extends ConsumerWidget {
  const _HabitTileRow({
    super.key,
    required this.scale,
    required this.habit,
    required this.completed,
    required this.nextUp,
    this.onToggle,
    this.onTap,
  });

  final double scale;
  final Habit habit;
  final bool completed;
  final bool nextUp;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(habitStreakProvider(habit.id));
    final (fg, bg) = habitAccentColours(habit.accent);

    return HabitTile(
      scale: scale,
      title: habit.title,
      meta: habitMetaLine(habit),
      streak: streak == 0 ? '' : '${streak}d',
      icon: habitIcon(habit.iconKey),
      iconColor: fg,
      iconBackground: bg,
      completed: completed,
      nextUp: nextUp,
      showStreakPill: !nextUp,
      streakHighlighted: nextUp,
      onToggle: onToggle,
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty states
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyHabits extends StatelessWidget {
  const _EmptyHabits({required this.scale, this.onCreateHabit});

  final double scale;
  final VoidCallback? onCreateHabit;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      padding: EdgeInsets.fromLTRB(24 * s, 28 * s, 24 * s, 24 * s),
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
            'No habits yet',
            size: 20 * s,
            weight: FontWeight.w600,
            letterSpacing: -0.5 * s,
            lineHeight: 26 * s,
            color: p.ink,
          ),
          SizedBox(height: 6 * s),
          figmaText(
            'Your habit library lives here. Add your first ritual and it will '
            'show up on Home every day.',
            size: 13 * s,
            weight: FontWeight.w400,
            lineHeight: 20 * s,
            color: p.body,
            width: 300 * s,
          ),
          SizedBox(height: 20 * s),
          GestureDetector(
            onTap: onCreateHabit,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 44 * s,
              decoration: BoxDecoration(
                color: p.ember,
                borderRadius: BorderRadius.circular(14 * s),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    figmaText(
                      'Add your first habit',
                      size: 13 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.2 * s,
                      lineHeight: 18 * s,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8 * s),
                    Icon(Icons.arrow_forward_rounded,
                        size: 15 * s, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter({required this.scale, required this.label});

  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final name = label.split(' (').first;
    return Container(
      width: 358 * s,
      padding: EdgeInsets.symmetric(vertical: 22 * s, horizontal: 16 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Center(
        child: figmaText(
          name == 'Paused'
              ? 'Nothing paused. Every habit is still running.'
              : 'Nothing here yet.',
          size: 12 * s,
          weight: FontWeight.w500,
          lineHeight: 16 * s,
          color: p.body,
          align: TextAlign.center,
          width: 300 * s,
        ),
      ),
    );
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
                    color: p.ink,
                  ),
                  SizedBox(width: 6 * s),
                  figmaText(
                    'spark',
                    size: 18 * s,
                    weight: FontWeight.w400,
                    lineHeight: 22 * s,
                    color: p.emberDeep,
                  ),
                ],
              ),
              SizedBox(height: 2 * s),
              figmaText(
                'Build your routine, one habit at a time.',
                size: 14 * s,
                weight: FontWeight.w400,
                lineHeight: 20 * s,
                color: p.body,
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
              color: p.panel,
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 19 * s,
              color: p.body,
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
  const _SnapshotCard({
    required this.scale,
    required this.completed,
    required this.total,
    required this.percent,
    required this.week,
  });

  final double scale;
  final int completed;
  final int total;
  final int percent;
  final List<DayStat> week;

  static const _weekdayLong = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12 * s),
      child: Container(
        width: 358 * s,
        height: 114 * s,
        color: p.surface,
        child: Stack(
          children: [
            // ambient glow
            Positioned(
              left: 286 * s,
              top: 42 * s,
              child: Container(
                width: 96 * s,
                height: 96 * s,
                decoration: BoxDecoration(
                  color: p.emberDeep.withValues(alpha: 0.102),
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
                  color: p.chipEmber,
                  borderRadius: BorderRadius.circular(8 * s),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 17 * s,
                  color: p.emberDeep,
                ),
              ),
            ),
            Positioned(
              left: 56 * s,
              top: 16 * s,
              child: figmaText(
                '$completed of $total Completed',
                size: 16 * s,
                weight: FontWeight.w600,
                letterSpacing: -0.08 * s,
                lineHeight: 22 * s,
                color: p.ink,
              ),
            ),
            Positioned(
              left: 56 * s,
              top: 38 * s,
              child: Row(
                children: [
                  figmaText(
                    '$percent% daily spark ignited',
                    size: 12 * s,
                    weight: FontWeight.w400,
                    letterSpacing: 0.12 * s,
                    lineHeight: 16 * s,
                    color: p.body,
                  ),
                  SizedBox(width: 6 * s),
                  figmaText(
                    '\u2726',
                    size: 12 * s,
                    weight: FontWeight.w500,
                    lineHeight: 16 * s,
                    color: p.ochre,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 246 * s,
              top: 20 * s,
              child: figmaText(
                '$percent%',
                size: 14 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.14 * s,
                lineHeight: 18 * s,
                color: p.emberDeep,
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
                color: p.muted,
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
                  color: p.container,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 326 * s * (percent / 100).clamp(0.0, 1.0),
                    height: 8 * s,
                    decoration: BoxDecoration(
                      color: p.emberDeep,
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
                  for (final day in week)
                    figmaText(
                      day.isToday
                          ? '${_weekdayLong[day.day.weekday - 1]} (Today)'
                          : _weekdayLong[day.day.weekday - 1],
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.4 * s,
                      lineHeight: 12 * s,
                      color: day.isToday ? p.emberDeep : p.body,
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
  const _FilterChips({
    required this.scale,
    required this.labels,
    required this.selected,
    this.onChanged,
  });

  final double scale;
  final List<String> labels;
  final int selected;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 28 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16 * s),
        physics: const ClampingScrollPhysics(),
        itemCount: labels.length,
        separatorBuilder: (_, _) => SizedBox(width: 8 * s),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onChanged?.call(i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 28 * s,
              padding: EdgeInsets.symmetric(horizontal: 14 * s),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? p.slate : p.panel,
                borderRadius: BorderRadius.circular(999),
              ),
              child: figmaText(
                labels[i],
                size: 12 * s,
                weight: FontWeight.w500,
                letterSpacing: 0.24 * s,
                lineHeight: 16 * s,
                color: isSelected ? p.panel : p.body,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mindful streak prompt
// ─────────────────────────────────────────────────────────────────────────────
class _MindfulStreakNote extends StatelessWidget {
  const _MindfulStreakNote({required this.scale, this.streakDays = 0});

  final double scale;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 96 * s,
      decoration: BoxDecoration(
        color: p.panel,
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
              color: p.emberDeep,
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
                color: p.body,
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
                color: p.surface,
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
                color: p.emberDeep,
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.emberLight, p.ember],
          ),
          borderRadius: BorderRadius.circular(12 * s),
          boxShadow: [
            BoxShadow(
              color: p.ember.withValues(alpha: 0.25),
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
              color: p.chipEmber,
            ),
          ],
        ),
      ),
    );
  }
}
