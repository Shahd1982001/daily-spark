import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/day.dart';
import '../data/models/habit.dart';
import 'habit_providers.dart';

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
      final span = dayOnly(today).difference(dayOnly(earliest)).inDays + 1;
      return span.clamp(1, 400);
  }
}

final rangeStatsProvider = Provider<RangeStats>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  final range = ref.watch(progressRangeProvider);
  if (snapshot == null || snapshot.habits.isEmpty) return RangeStats.empty;

  final today = dayOnly(DateTime.now());
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
      final day = today.subtract(Duration(days: i));
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
  final today = dayOnly(DateTime.now());
  final days = <RhythmDay>[];
  for (var offset = 6; offset >= 0; offset--) {
    final day = today.subtract(Duration(days: offset));
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
    if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
      run++;
      if (run > best) best = run;
    } else {
      run = 1;
    }
  }
  return best;
});
