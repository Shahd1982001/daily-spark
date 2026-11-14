import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/app_bottom_nav.dart';
import 'package:daily_spark/design_system/widgets/app_top_bar.dart';
import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/home/widgets/habit_card.dart';
import 'package:daily_spark/screens/home/widgets/pulse_card.dart';
import 'package:daily_spark/state/habit_providers.dart';

/// Home — now driven by the habit store (Riverpod).
/// Figma: node 126:15685 (data-filled state) · empty state designed separately.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.onProfile,
    this.onHabitTap,
    this.onNewRitual,
    this.onNavTap,
    this.userName = 'Shahd',
  });

  final VoidCallback? onProfile;
  final ValueChanged<String>? onHabitTap;
  final VoidCallback? onNewRitual;
  final ValueChanged<int>? onNavTap;
  final String userName;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    final habits = ref.watch(todayHabitsProvider);
    final summary = ref.watch(todaySummaryProvider);
    final snapshot = ref.watch(habitsProvider).valueOrNull;
    final week = ref.watch(lastSevenDaysProvider);
    final streak = ref.watch(routineStreakProvider);
    final record = ref.watch(routineRecordProvider);

    final filters = _buildFilters(habits);
    final activeFilter = _filterIndex.clamp(0, filters.length - 1);
    final visible = activeFilter == 0
        ? habits
        : habits.where((h) => h.category == filters[activeFilter]).toList();

    final isEmpty = habits.isEmpty;

    return Scaffold(
      backgroundColor: p.canvas,
      body: Stack(
        children: [
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
                    child: _Greeting(
                      scale: s,
                      name: widget.userName,
                      completed: summary.completed,
                      total: summary.total,
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  if (isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: _EmptyHome(
                        scale: s,
                        onNewRitual: widget.onNewRitual,
                      ),
                    )
                  else ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: PulseCard(
                        scale: s,
                        percent: summary.percent,
                        completed: summary.completed,
                        total: summary.total,
                        streakDays: streak,
                        recordDays: record,
                        week: [
                          for (final d in week)
                            PulseDay(
                              label: weekdayLabel(d.day),
                              done: d.done,
                              isToday: d.isToday,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: _RoutineHeader(
                        scale: s,
                        total: habits.length,
                        onNewRitual: widget.onNewRitual,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: _FilterPills(
                        scale: s,
                        labels: filters,
                        habits: habits,
                        selected: activeFilter,
                        onChanged: (i) => setState(() => _filterIndex = i),
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    if (visible.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * s),
                        child: _EmptyFilter(scale: s),
                      ),
                    for (var i = 0; i < visible.length; i++)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16 * s,
                          0,
                          16 * s,
                          i == visible.length - 1 ? 0 : 12 * s,
                        ),
                        child: _HabitRow(
                          key: ValueKey(visible[i].id),
                          scale: s,
                          habit: visible[i],
                          completed:
                              snapshot?.isCompleted(visible[i].id, DateTime.now()) ??
                                  false,
                          onToggle: () => ref
                              .read(habitsProvider.notifier)
                              .toggle(visible[i].id),
                          onTap: () => widget.onHabitTap?.call(visible[i].id),
                        ),
                      ),
                    SizedBox(height: 24 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: _ClarityNote(scale: s),
                    ),
                  ],
                  SizedBox(height: 24 * s),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppTopBar(scale: s, title: 'Home', onProfile: widget.onProfile),
          ),
          Positioned(
            left: 16 * s,
            right: 16 * s,
            bottom: 20 * s,
            child: AppBottomNav(
              scale: s,
              selectedIndex: 0,
              selectedWidth: 81,
              onTap: widget.onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  /// `[All, …categories in use]`
  List<String> _buildFilters(List<Habit> habits) {
    final categories = <String>[];
    for (final h in habits) {
      if (!categories.contains(h.category)) categories.add(h.category);
    }
    return ['All', ...categories];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// One habit row, bound to the store
// ─────────────────────────────────────────────────────────────────────────────
class _HabitRow extends ConsumerWidget {
  const _HabitRow({
    super.key,
    required this.scale,
    required this.habit,
    required this.completed,
    this.onToggle,
    this.onTap,
  });

  final double scale;
  final Habit habit;
  final bool completed;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  static IconData _icon(String key) => switch (key) {
        'book' => Icons.menu_book_outlined,
        'water' => Icons.water_drop_outlined,
        'meditation' => Icons.self_improvement,
        'walk' => Icons.directions_walk_rounded,
        'journal' => Icons.edit_note_rounded,
        'moon' => Icons.nightlight_round,
        'flame' => Icons.local_fire_department_rounded,
        _ => Icons.bolt_rounded,
      };

  static (Color, Color) _accent(HabitAccent accent) => switch (accent) {
        HabitAccent.sage => (p.success, p.mintSoft),
        HabitAccent.terracotta => (p.emberDark, p.creamSoft),
        HabitAccent.ochre => (p.ochre, p.chipGold),
        HabitAccent.slate => (p.body, p.bone),
      };

  static String _time(String? hhmm) {
    if (hhmm == null) return '';
    final parts = hhmm.split(':');
    if (parts.length != 2) return '';
    final hour = int.tryParse(parts[0]);
    final minute = parts[1];
    if (hour == null) return '';
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final display = hour % 12 == 0 ? 12 : hour % 12;
    return '$display:$minute $suffix';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (iconColor, background) = _accent(habit.accent);
    final streak = ref.watch(habitStreakProvider(habit.id));

    final meta = <String>[
      if (habit.targetAmount > 1) '${habit.targetAmount} ${habit.targetUnit}',
      if (habit.detailTag.isNotEmpty) habit.detailTag,
      if (_time(habit.reminderTime).isNotEmpty) _time(habit.reminderTime),
      if (habit.targetAmount <= 1 && habit.reminderTime == null) habit.category,
    ];

    return HabitCard(
      scale: scale,
      title: habit.title,
      meta: meta,
      streak: streak == 0 ? '' : '${streak}d',
      icon: _icon(habit.iconKey),
      iconColor: iconColor,
      iconBackground: background,
      completed: completed,
      onToggle: onToggle,
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty states
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.scale, this.onNewRitual});

  final double scale;
  final VoidCallback? onNewRitual;

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
            'Your first spark is waiting',
            size: 20 * s,
            weight: FontWeight.w600,
            letterSpacing: -0.5 * s,
            lineHeight: 26 * s,
            color: p.ink,
          ),
          SizedBox(height: 6 * s),
          figmaText(
            'Small steps compound. Add one ritual you can keep for a week — '
            'the streak starts on day one.',
            size: 13 * s,
            weight: FontWeight.w400,
            lineHeight: 20 * s,
            color: p.body,
            width: 300 * s,
          ),
          SizedBox(height: 20 * s),
          GestureDetector(
            onTap: onNewRitual,
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
                      'Create your first ritual',
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
          SizedBox(height: 14 * s),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 12 * s, color: p.faint),
              SizedBox(width: 6 * s),
              figmaText(
                'Takes about 40 seconds',
                size: 11 * s,
                weight: FontWeight.w500,
                lineHeight: 14 * s,
                color: p.faint,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      padding: EdgeInsets.symmetric(vertical: 22 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Center(
        child: figmaText(
          'Nothing scheduled in this part of the day.',
          size: 12 * s,
          weight: FontWeight.w500,
          lineHeight: 16 * s,
          color: p.body,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting block
// ─────────────────────────────────────────────────────────────────────────────
class _Greeting extends StatelessWidget {
  const _Greeting({
    required this.scale,
    required this.name,
    required this.completed,
    required this.total,
  });

  final double scale;
  final String name;
  final int completed;
  final int total;

  static const _weekdays = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY',
  ];
  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  String get _dateLabel {
    final now = DateTime.now();
    return '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}';
  }

  String get _season {
    final month = DateTime.now().month;
    if (month == 12 || month <= 2) return 'Winter Rhythm';
    if (month <= 5) return 'Spring Rhythm';
    if (month <= 8) return 'Summer Rhythm';
    return 'Autumn Rhythm';
  }

  String get _greetingWord {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _statusLine {
    if (total == 0) return 'No rituals yet — add your first one to start your spark.';
    if (completed >= total) return 'All $total habits done today. The spark is alive.';
    return '$completed of $total habits completed for today. Keep the spark alive.';
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            figmaText(
              _dateLabel,
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
              _season,
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
          '$_greetingWord, $name',
          size: 22 * s,
          weight: FontWeight.w600,
          letterSpacing: -0.55 * s,
          lineHeight: 28 * s,
          color: p.ink,
        ),
        SizedBox(height: 2 * s),
        figmaText(
          _statusLine,
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
  const _RoutineHeader({
    required this.scale,
    required this.total,
    this.onNewRitual,
  });

  final double scale;
  final int total;
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
                '$total total',
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
  const _FilterPills({
    required this.scale,
    required this.labels,
    required this.habits,
    required this.selected,
    this.onChanged,
  });

  final double scale;
  final List<String> labels;
  final List<Habit> habits;
  final int selected;
  final ValueChanged<int>? onChanged;

  int _countFor(int index) {
    if (index == 0) return habits.length;
    final label = labels[index];
    return habits.where((h) => h.category == label).length;
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 36 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: labels.length,
        separatorBuilder: (_, _) => SizedBox(width: 4 * s),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onChanged?.call(i),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 28 * s,
              padding: EdgeInsets.symmetric(horizontal: 12 * s),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? p.slate : p.panel,
                borderRadius: BorderRadius.circular(999),
              ),
              child: figmaText(
                '${labels[i]} (${_countFor(i)})',
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
                color: p.chipGold,
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
