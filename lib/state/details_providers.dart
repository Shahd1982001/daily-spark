import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/day.dart';
import '../data/models/habit.dart';
import '../data/services/streaks.dart';
import 'habit_providers.dart';

/// Which habit the details screen is showing.
///
/// Set by every tap that opens the screen (Home card, Habits tile). When the id
/// is null — or points at a habit that no longer exists — the screen falls back
/// to the first habit scheduled today.
final selectedHabitIdProvider = StateProvider<String?>((ref) => null);

final detailsHabitProvider = Provider<Habit?>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (snapshot == null || snapshot.activeHabits.isEmpty) return null;

  final selectedId = ref.watch(selectedHabitIdProvider);
  final selected =
      selectedId == null ? null : snapshot.habitById(selectedId);
  if (selected != null && !selected.isArchived) return selected;

  final today = snapshot.scheduledOn(DateTime.now());
  return today.isNotEmpty ? today.first : snapshot.activeHabits.first;
});

// ── Pure helpers ─────────────────────────────────────────────────────────────

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];

/// `November`.
String monthName(int month) => _monthNames[(month - 1).clamp(0, 11)];

/// `1,420`.
String groupDigits(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}

/// The longest run of *scheduled* days the habit was completed on.
({int length, DateTime? endedOn}) bestRunFor(
  Habit habit,
  Set<DateTime> completedDays, {
  required DateTime today,
}) {
  final done = completedDays.map(dayOnly).toSet();
  if (done.isEmpty) return (length: 0, endedOn: null);

  final todayDay = dayOnly(today);
  final created = dayOnly(habit.createdAt);
  var earliest = done.reduce((a, b) => a.isBefore(b) ? a : b);
  if (earliest.isBefore(created)) earliest = created;

  var run = 0;
  var best = 0;
  DateTime? endedOn;
  var day = earliest;
  while (!day.isAfter(todayDay)) {
    if (habit.isScheduledOn(day)) {
      if (done.contains(day)) {
        run++;
        if (run > best) {
          best = run;
          endedOn = day;
        }
      } else {
        run = 0;
      }
    }
    day = day.add(const Duration(days: 1));
  }
  return (length: best, endedOn: endedOn);
}

/// One cell of the month calendar.
class DetailDay {
  const DetailDay({
    required this.day,
    required this.completed,
    required this.isToday,
    required this.scheduled,
    required this.inMonth,
    required this.beforeStart,
    required this.inFuture,
  });

  final int day;
  final bool completed;
  final bool isToday;
  final bool scheduled;
  final bool inMonth;

  /// The habit did not exist yet on that day.
  final bool beforeStart;

  /// Day is after today — can still be done.
  final bool inFuture;

  /// Neutral placeholder cell (padding for the weekday offset).
  bool get isBlank => !inMonth;

  /// Should be painted as a "missed" day.
  bool get isMissed =>
      inMonth && scheduled && !completed && !isToday && !inFuture &&
      !beforeStart;
}

/// Everything the Habit Details screen renders, computed from the store.
class HabitDetail {
  const HabitDetail({
    required this.habit,
    required this.amountToday,
    required this.targetAmount,
    required this.doneToday,
    required this.streak,
    required this.bestStreak,
    required this.bestStreakEndedOn,
    required this.totalCompletions,
    required this.totalAmount,
    required this.consistency,
    required this.weekPercent,
    required this.monthCompleted,
    required this.monthScheduled,
    required this.monthPercent,
    required this.monthDays,
    required this.monthStartOffset,
    required this.monthLabel,
    required this.year,
    required this.trendDelta,
    required this.daysSinceStart,
  });

  final Habit habit;
  final int amountToday;
  final int targetAmount;
  final bool doneToday;

  final int streak;
  final int bestStreak;
  final DateTime? bestStreakEndedOn;

  final int totalCompletions;
  final int totalAmount;

  /// Lifetime success rate on scheduled days (0–100).
  final int consistency;

  /// Completion rate over the last seven days (0–100).
  final int weekPercent;

  final int monthCompleted;
  final int monthScheduled;
  final int monthPercent;

  /// One entry per calendar day of the current month (oldest first).
  final List<DetailDay> monthDays;

  /// Empty cells before the 1st so the grid starts on the right weekday.
  final int monthStartOffset;

  /// `November`, `2026`.
  final String monthLabel;
  final int year;

  /// Completed days this 30-day window minus the previous one.
  final int trendDelta;

  final int daysSinceStart;

  int get todayPercent => targetAmount == 0
      ? 0
      : ((amountToday / targetAmount) * 100).clamp(0, 100).round();

  int get remaining => (targetAmount - amountToday).clamp(0, targetAmount);

  /// Step sizes offered by the today-progress stepper (+5 / +10 for a
  /// 20-page target, bigger for bigger targets so the buttons stay useful).
  (int, int) get steps {
    if (targetAmount >= 100) {
      final base = (targetAmount / 10).round();
      return (base, base * 2);
    }
    if (targetAmount >= 10) return (5, 10);
    return (1, 2);
  }

  String get headline => switch (streak) {
        0 => 'A quiet start awaits',
        <= 6 => 'Momentum is building',
        <= 20 => 'In your flow state',
        _ => 'Unshakeable rhythm',
      };

  String get subline => switch (streak) {
        0 => 'Log today to open your streak',
        1 => '1 day of showing up',
        <= 20 => '$streak days compound momentum',
        _ => '$streak days of showing up',
      };

  String get trendLabel {
    if (trendDelta > 0) return '+$trendDelta days vs previous 30';
    if (trendDelta < 0) return '${trendDelta.abs()} fewer than last 30';
    return 'Level with the last 30 days';
  }
}

/// Round-up helper used by the mosaic captions.
String _monthOf(DateTime? day) => day == null ? '' : monthName(day.month);

final habitDetailProvider = Provider<HabitDetail?>((ref) {
  final habit = ref.watch(detailsHabitProvider);
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (habit == null || snapshot == null) return null;

  final today = dayOnly(DateTime.now());
  final created = dayOnly(habit.createdAt);
  final days = snapshot.daysFor(habit.id);
  final done = days.map(dayOnly).toSet();

  final streak = streakFor(habit, days, today: today);
  final best = bestRunFor(habit, done, today: today);

  final targetAmount = habit.targetAmount <= 0 ? 1 : habit.targetAmount;
  final amountToday = snapshot.amountFor(habit.id, today);

  // Lifetime + rolling windows, always over scheduled days only.
  var scheduledLifetime = 0;
  var completedLifetime = 0;
  var totalAmount = 0;
  var windowCompleted = 0;
  var previousWindowCompleted = 0;
  var day = created.isAfter(today) ? today : created;
  while (!day.isAfter(today)) {
    final offset = today.difference(day).inDays;
    if (habit.isScheduledOn(day)) {
      scheduledLifetime++;
      if (done.contains(day)) {
        completedLifetime++;
        totalAmount += snapshot.amountFor(habit.id, day);
      }
      if (offset < 30 && done.contains(day)) windowCompleted++;
      if (offset >= 30 && offset < 60 && done.contains(day)) {
        previousWindowCompleted++;
      }
    }
    day = day.add(const Duration(days: 1));
  }

  final consistency = scheduledLifetime == 0
      ? 0
      : ((completedLifetime / scheduledLifetime) * 100).round();

  // Current month calendar.
  final monthStart = DateTime(today.year, today.month, 1);
  final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
  final monthDays = <DetailDay>[];
  var monthScheduled = 0;
  var monthCompleted = 0;
  for (var d = 1; d <= daysInMonth; d++) {
    final date = DateTime(today.year, today.month, d);
    final isFuture = date.isAfter(today);
    final beforeStart = date.isBefore(created);
    final scheduled = !beforeStart && habit.isScheduledOn(date);
    final completed = done.contains(date);
    if (scheduled && !isFuture) monthScheduled++;
    if (completed) monthCompleted++;
    monthDays.add(DetailDay(
      day: d,
      completed: completed,
      isToday: date == today,
      scheduled: scheduled,
      inMonth: true,
      beforeStart: beforeStart,
      inFuture: isFuture,
    ));
  }

  final monthPercent =
      monthScheduled == 0 ? 0 : ((monthCompleted / monthScheduled) * 100).round();

  return HabitDetail(
    habit: habit,
    amountToday: amountToday,
    targetAmount: targetAmount,
    doneToday: done.contains(today),
    streak: streak,
    bestStreak: best.length,
    bestStreakEndedOn: best.endedOn,
    totalCompletions: completedLifetime,
    totalAmount: totalAmount,
    consistency: consistency,
    weekPercent: _windowPercent(habit, done, today: today, days: 7),
    monthCompleted: monthCompleted,
    monthScheduled: monthScheduled,
    monthPercent: monthPercent,
    monthDays: monthDays,
    monthStartOffset: monthStart.weekday - 1,
    monthLabel: monthName(monthStart.month),
    year: monthStart.year,
    trendDelta: windowCompleted - previousWindowCompleted,
    daysSinceStart: today.difference(created).inDays + 1,
  );
});

int _windowPercent(
  Habit habit,
  Set<DateTime> done, {
  required DateTime today,
  required int days,
}) {
  var scheduled = 0;
  var completed = 0;
  for (var i = 0; i < days; i++) {
    final day = today.subtract(Duration(days: i));
    if (day.isBefore(dayOnly(habit.createdAt))) break;
    if (!habit.isScheduledOn(day)) continue;
    scheduled++;
    if (done.contains(day)) completed++;
  }
  if (scheduled == 0) return 0;
  return ((completed / scheduled) * 100).round();
}

/// Best-record caption (`Set in November`), or a nudge when there is none.
String bestRecordCaption(HabitDetail detail) =>
    detail.bestStreak == 0
        ? 'No record yet'
        : 'Set in ${_monthOf(detail.bestStreakEndedOn)}';
