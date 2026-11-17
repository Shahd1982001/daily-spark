import 'calendar_day_provider.dart';
import 'package:daily_spark/l10n/strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/day.dart';
import '../data/models/habit.dart';
import 'habit_providers.dart';
import 'settings_providers.dart';

/// Which window the Progress screen is showing.
enum ProgressRange { week, month, all }

final progressRangeProvider =
    StateProvider<ProgressRange>((ref) => ProgressRange.week);

/// Completed / scheduled for one habit inside the selected window.
class HabitRatio {
  const HabitRatio({
    required this.habit,
    required this.scheduled,
    required this.completed,
  });

  final Habit habit;
  final int scheduled;
  final int completed;

  int get percent => scheduled == 0 ? 0 : ((completed / scheduled) * 100).round();
}

/// Everything the Progress hero + consistency list needs.
class RangeStats {
  const RangeStats({
    required this.scheduled,
    required this.completed,
    required this.habits,
    required this.range,
  });

  final int scheduled;
  final int completed;
  final List<HabitRatio> habits;
  final ProgressRange range;

  int get percent => scheduled == 0 ? 0 : ((completed / scheduled) * 100).round();

  bool get isEmpty => scheduled == 0;

  static const empty = RangeStats(
    scheduled: 0,
    completed: 0,
    habits: [],
    range: ProgressRange.week,
  );
}

int _daysForRange(ProgressRange range, DateTime today, DateTime? earliest) {
  switch (range) {
    case ProgressRange.week:
      return 7;
    case ProgressRange.month:
      return 30;
    case ProgressRange.all:
      if (earliest == null) return 7;
      final span = calendarDaysBetween(earliest, today) + 1;
      return span < 1 ? 1 : span;
  }
}

final rangeStatsProvider = Provider<RangeStats>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  final range = ref.watch(progressRangeProvider);
  if (snapshot == null || snapshot.habits.isEmpty) return RangeStats.empty;

  final today = ref.watch(calendarDayProvider);
  DateTime? earliest;
  for (final habit in snapshot.habits) {
    final created = dayOnly(habit.createdAt);
    if (earliest == null || created.isBefore(earliest)) earliest = created;
  }
  final days = _daysForRange(range, today, earliest);

  var scheduled = 0;
  var completed = 0;
  final rows = <HabitRatio>[];

  for (final habit in snapshot.activeHabits) {
    final done = snapshot.daysFor(habit.id).map(dayOnly).toSet();
    var habitScheduled = 0;
    var habitCompleted = 0;
    for (var i = 0; i < days; i++) {
      final day = addCalendarDays(today, -i);
      if (habit.isScheduledOn(day)) {
        habitScheduled++;
        if (done.contains(day)) habitCompleted++;
      }
    }
    scheduled += habitScheduled;
    completed += habitCompleted;
    if (habitScheduled > 0) {
      rows.add(HabitRatio(
        habit: habit,
        scheduled: habitScheduled,
        completed: habitCompleted,
      ));
    }
  }

  rows.sort((a, b) => b.percent.compareTo(a.percent));
  return RangeStats(
    scheduled: scheduled,
    completed: completed,
    habits: rows,
    range: range,
  );
});

/// One column of the Weekly Rhythm chart.
class RhythmDay {
  const RhythmDay({
    required this.day,
    required this.percent,
    required this.isToday,
  });

  final DateTime day;
  final int percent;
  final bool isToday;
}

/// Last 7 days, oldest first — the Weekly Rhythm bars.
final weeklyRhythmProvider = Provider<List<RhythmDay>>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  final today = ref.watch(calendarDayProvider);
  final days = <RhythmDay>[];
  for (var offset = 6; offset >= 0; offset--) {
    final day = addCalendarDays(today, -offset);
    final scheduled = snapshot?.scheduledOn(day).length ?? 0;
    final completed = snapshot?.completedOn(day) ?? 0;
    days.add(RhythmDay(
      day: day,
      percent: scheduled == 0 ? 0 : ((completed / scheduled) * 100).round(),
      isToday: offset == 0,
    ));
  }
  return days;
});

/// Longest streak across all habits (used by the streak card).
final bestHabitStreakProvider = Provider<int>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (snapshot == null || snapshot.habits.isEmpty) return 0;
  var best = 0;
  for (final habit in snapshot.activeHabits) {
    final streak = ref.watch(habitStreakProvider(habit.id));
    if (streak > best) best = streak;
  }
  return best;
});

/// Consecutive days at least one habit was completed (used as "personal best"
/// proxy when there is no longer history).
final personalBestProvider = Provider<int>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (snapshot == null || snapshot.habits.isEmpty) return 0;

  final allDays = <DateTime>{};
  for (final days in snapshot.log.values) {
    allDays.addAll(days.map(dayOnly));
  }
  if (allDays.isEmpty) return 0;
  final sorted = allDays.toList()..sort();

  var best = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    if (calendarDaysBetween(sorted[i - 1], sorted[i]) == 1) {
      run++;
      if (run > best) best = run;
    } else {
      run = 1;
    }
  }
  return best;
});

// ── Profile summaries ───────────────────────────────────────────────────────

/// Every completed check-in the user has ever logged.
final totalCompletionsProvider = Provider<int>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (snapshot == null) return 0;
  return snapshot.log.values.fold<int>(0, (sum, days) => sum + days.length);
});

/// Overall completion over the last [days] days (Profile consistency score).
final consistencyScoreProvider = Provider<int>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (snapshot == null || snapshot.habits.isEmpty) return 0;
  final today = ref.watch(calendarDayProvider);
  var scheduled = 0;
  var completed = 0;
  for (var i = 0; i < 14; i++) {
    final day = addCalendarDays(today, -i);
    scheduled += snapshot.scheduledOn(day).length;
    completed += snapshot.completedOn(day);
  }
  if (scheduled == 0) return 0;
  return ((completed / scheduled) * 100).round();
});

/// Level derived from lifetime completions (1 level per 30 check-ins).
class ProfileLevel {
  const ProfileLevel({
    required this.level,
    required this.title,
    required this.score,
    required this.toNext,
  });

  final int level;
  final String title;
  final int score;
  final int toNext;

  String get nextLabel => tr('Next: {count} more check-ins', {'count': '$toNext'});

  static const _titles = [
    'Sprout',
    'Builder',
    'Achiever',
    'Explorer',
    'Navigator',
    'Master',
    'Luminary',
  ];

  String get label =>
      tr('Level {level} {title}', {'level': '$level', 'title': tr(title)});
}

final profileLevelProvider = Provider<ProfileLevel>((ref) {
  final done = ref.watch(totalCompletionsProvider);
  final score = ref.watch(consistencyScoreProvider);
  final level = (1 + done ~/ 30).clamp(1, ProfileLevel._titles.length);
  final toNext = 30 - (done % 30);
  return ProfileLevel(
    level: level,
    title: ProfileLevel._titles[level - 1],
    score: score,
    toNext: toNext,
  );
});

/// Display name — the stored one when set; demo seeds show 'Shahd'.
/// `null` for a fresh user (no auth yet).
final userNameProvider = Provider<String?>((ref) {
  final stored = ref.watch(profileInfoProvider.select((i) => i.name));
  if (ref.watch(demoModeProvider) != DemoMode.none) return stored ?? 'Shahd';
  return stored;
});

/// The user's ritual motto, `null` until set.
final userMottoProvider = Provider<String?>(
    (ref) => ref.watch(profileInfoProvider.select((i) => i.motto)));
