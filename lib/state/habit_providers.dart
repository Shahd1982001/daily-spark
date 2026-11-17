import 'dart:async';
import 'calendar_day_provider.dart';
import 'completion_feedback_provider.dart';
import 'settings_providers.dart';
import 'mascot_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/habit_store.dart';
import '../data/models/day.dart';
import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';
import '../data/seed/seed_data.dart';
import '../data/services/streaks.dart';

/// Review data sets — a real first launch starts with [DemoMode.none]
/// (empty: no habits, no stats). `?demo=small` / `?demo=1` seed a throw-away
/// in-memory store so every state can be reviewed in light and dark.
enum DemoMode { none, small, full }

final demoModeProvider = Provider<DemoMode>((ref) => DemoMode.none);

/// Overridden in `main()` with the real local store.
final habitStoreProvider = Provider<HabitStore>(
  (ref) => throw UnimplementedError('habitStoreProvider must be overridden'),
);

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepository(
    ref.watch(habitStoreProvider),
    seeder: switch (ref.watch(demoModeProvider)) {
      DemoMode.full => seedSnapshot,
      DemoMode.small => seedSmallSnapshot,
      DemoMode.none => HabitRepository.defaultSeeder,
    },
  ),
);

/// The live app state: habits + completion log. Every screen reads this.
final habitsProvider =
    AsyncNotifierProvider<HabitsController, HabitsSnapshot>(HabitsController.new);

class HabitsController extends AsyncNotifier<HabitsSnapshot> {
  @override
  Future<HabitsSnapshot> build() => ref.watch(habitRepositoryProvider).load();

  HabitRepository get _repo => ref.read(habitRepositoryProvider);

  /// Marks a habit done / not done on [day] (defaults to today).
  Future<void> toggle(String habitId, {DateTime? day}) async {
    final current = state.valueOrNull;
    final habit = current?.habitById(habitId);
    if (current == null || habit == null || habit.isArchived) return;
    final day_ = dayOnly(day ?? DateTime.now());
    final done = current.isCompleted(habitId, day_);
    await setAmount(habitId, done ? 0 : _targetOf(habit, day_), day: day_);
  }

  /// Logs progress on an amount-based habit (today by default).
  ///
  /// The amount is clamped to `0…target`; reaching the target marks the day
  /// complete, dropping below it clears the completion. Nothing is stored for
  /// amount-less days, so the log stays the single source of truth.
  Future<void> setAmount(String habitId, int amount, {DateTime? day}) async {
    final current = state.valueOrNull;
    final habit = current?.habitById(habitId);
    if (current == null || habit == null || habit.isArchived) return;

    final targetDay = dayOnly(day ?? DateTime.now());
    final key = dayKey(targetDay);
    final targetAmount = _targetOf(habit, targetDay);
    final wasDone = current.isCompleted(habitId, targetDay);
    final clamped = amount.clamp(0, targetAmount);

    final amounts = <String, Map<String, int>>{
      for (final entry in current.amounts.entries)
        entry.key: Map<String, int>.from(entry.value),
    };
    final perDay = amounts[habitId] ?? <String, int>{};
    perDay[key] = clamped;
    amounts[habitId] = perDay;

    final log = <String, Set<DateTime>>{
      for (final entry in current.log.entries) entry.key: {...entry.value},
    };
    final days = log[habitId] ?? <DateTime>{};
    if (clamped >= targetAmount) {
      days.add(targetDay);
    } else {
      days.removeWhere((d) => dayOnly(d) == targetDay);
    }
    log[habitId] = days;

    final next = current.copyWith(log: log, amounts: amounts);
    state = AsyncData(next);
    await _repo.save(next);
    // Celebrate a user action crossing today's goal, not initial data loads,
    // partial progress, undo, old dates or target changes. Preference covers
    // both audio and haptics; unavailable devices fail quietly.
    if (!wasDone && clamped >= targetAmount && targetDay == dayOnly(DateTime.now())) {
      if (ref.exists(completionCelebrationProvider)) {
        ref.read(completionCelebrationProvider.notifier).state++;
      }
      if (ref.exists(settingsProvider)) {
        final settings = ref.read(settingsProvider);
        if (settings.loaded && settings.soundOn) {
          unawaited(ref.read(completionFeedbackProvider).play().catchError((Object _) {}));
        }
      }
    }
  }

  /// Steps the logged amount by [delta], clamped to the habit target.
  Future<void> stepAmount(String habitId, int delta, {DateTime? day}) async {
    final current = state.valueOrNull;
    final habit = current?.habitById(habitId);
    if (current == null || habit == null) return;
    final targetDay = dayOnly(day ?? DateTime.now());
    await setAmount(
      habitId,
      current.amountFor(habitId, targetDay) + delta,
      day: targetDay,
    );
  }

  static int _targetOf(Habit habit, DateTime day) =>
      habit.planOn(day).targetAmount <= 0 ? 1 : habit.planOn(day).targetAmount;

  Future<void> addHabit(Habit habit) async {
    final current = state.valueOrNull;
    if (current == null) throw StateError('Habit data is not loaded');
    final next = current.copyWith(habits: [...current.habits, habit]);
    state = AsyncData(next);
    await _repo.save(next);
  }

  Future<void> updateHabit(Habit habit, {DateTime? effectiveAt}) async {
    final current = state.valueOrNull;
    if (current == null) throw StateError('Habit data is not loaded');
    final old = current.habitById(habit.id);
    if (old == null) return;
    final day = dayOnly(effectiveAt ?? DateTime.now());
    final changesPlan = old.rhythm != habit.rhythm ||
        old.days.length != habit.days.length || !old.days.containsAll(habit.days) ||
        old.targetAmount != habit.targetAmount || old.targetUnit != habit.targetUnit;
    var updated = habit;
    var amounts = current.amounts;
    var log = current.log;
    if (changesPlan) {
      final history = old.planHistory.isEmpty
          ? [HabitPlan(effectiveFrom: dayOnly(old.createdAt), rhythm: old.rhythm,
              days: Set<int>.from(old.days), targetAmount: old.targetAmount,
              targetUnit: old.targetUnit)]
          : [...old.planHistory];
      history.removeWhere((plan) => dayOnly(plan.effectiveFrom) == day);
      history.add(HabitPlan(effectiveFrom: day, rhythm: habit.rhythm,
          days: Set<int>.from(habit.days), targetAmount: habit.targetAmount,
          targetUnit: habit.targetUnit));
      history.sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
      updated = habit.copyWith(planHistory: history);
      if (old.targetAmount != habit.targetAmount || old.targetUnit != habit.targetUnit) {
        amounts = {for (final entry in current.amounts.entries)
          entry.key: Map<String, int>.from(entry.value)};
        log = {for (final entry in current.log.entries) entry.key: {...entry.value}};
        final oldAmount = current.amountFor(habit.id, day);
        final todayAmount = old.targetUnit != habit.targetUnit ? 0 : oldAmount;
        amounts.putIfAbsent(habit.id, () => {})[dayKey(day)] = todayAmount;
        final completed = log.putIfAbsent(habit.id, () => {});
        completed.removeWhere((date) => dayOnly(date) == day);
        if (todayAmount >= (habit.targetAmount <= 0 ? 1 : habit.targetAmount)) completed.add(day);
      }
    }
    final next = current.copyWith(
      habits: [for (final h in current.habits) if (h.id == habit.id) updated else h],
      amounts: amounts, log: log,
    );
    state = AsyncData(next);
    await _repo.save(next);
  }

  Future<void> archiveHabit(String habitId) async {
    final current = state.valueOrNull;
    final habit = current?.habitById(habitId);
    if (current == null || habit == null || habit.isArchived) return;
    await updateHabit(habit.copyWith(archivedAt: DateTime.now()));
  }

  /// Restores the habit without losing its log or counting paused days as missed.
  Future<void> restoreHabit(String habitId, {DateTime? now}) async {
    final habit = state.valueOrNull?.habitById(habitId);
    final pausedAt = habit?.archivedAt;
    if (habit == null || pausedAt == null) return;
    final restoredAt = now ?? DateTime.now();
    if (dayOnly(restoredAt).isBefore(dayOnly(pausedAt))) return;
    await updateHabit(habit.copyWith(
      clearArchived: true,
      pauseHistory: [...habit.pauseHistory, HabitPause(pausedAt, restoredAt)],
    ));
  }

  Future<void> deleteHabit(String habitId) async {
    final current = state.valueOrNull;
    if (current == null) throw StateError('Habit data is not loaded');
    final log = <String, Set<DateTime>>{
      for (final entry in current.log.entries)
        if (entry.key != habitId) entry.key: entry.value,
    };
    final next = HabitsSnapshot(
      habits: current.habits.where((h) => h.id != habitId).toList(),
      log: log,
      amounts: {
        for (final entry in current.amounts.entries)
          if (entry.key != habitId) entry.key: Map<String, int>.from(entry.value),
      },
    );
    state = AsyncData(next);
    await _repo.save(next);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.load());
  }
}

// ── Derived read models ─────────────────────────────────────────────────────

/// Habits expected today, in display order.
final todayHabitsProvider = Provider<List<Habit>>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (snapshot == null) return const [];
  return snapshot.scheduledOn(ref.watch(calendarDayProvider));
});

/// `3 of 5` style summary for today.
class TodaySummary {
  const TodaySummary({required this.completed, required this.total});

  final int completed;
  final int total;

  int get percent => total == 0 ? 0 : ((completed / total) * 100).round();

  bool get isComplete => total > 0 && completed == total;
}

final todaySummaryProvider = Provider<TodaySummary>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  final habits = ref.watch(todayHabitsProvider);
  if (snapshot == null) return const TodaySummary(completed: 0, total: 0);
  final now = ref.watch(calendarDayProvider);
  return TodaySummary(
    completed: snapshot.completedOn(now),
    total: habits.length,
  );
});

/// Amount logged for one habit today (partial progress included).
final habitTodayAmountProvider =
    Provider.family<int, String>((ref, habitId) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (snapshot == null) return 0;
  return snapshot.amountFor(habitId, ref.watch(calendarDayProvider));
});

/// Streak for one habit, as shown on cards (`12d`).
final habitStreakProvider = Provider.family<int, String>((ref, habitId) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  final habit = snapshot?.habitById(habitId);
  if (snapshot == null || habit == null) return 0;
  return streakFor(
    habit,
    snapshot.daysFor(habitId),
    today: ref.watch(calendarDayProvider),
  );
});


/// One day of the Home pulse strip.
class DayStat {
  const DayStat({required this.day, required this.done, required this.isToday});

  final DateTime day;
  final bool done;
  final bool isToday;
}

const _weekdayShort = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

/// The last 7 days (oldest first). A past day counts as "done" when every
/// habit scheduled that day was completed.
final lastSevenDaysProvider = Provider<List<DayStat>>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  final today = ref.watch(calendarDayProvider);
  final days = <DayStat>[];
  for (var offset = 6; offset >= 0; offset--) {
    final day = addCalendarDays(today, -offset);
    final scheduled = snapshot?.scheduledOn(day).length ?? 0;
    final completed = snapshot?.completedOn(day) ?? 0;
    days.add(DayStat(
      day: day,
      done: scheduled > 0 && completed >= scheduled,
      isToday: offset == 0,
    ));
  }
  return days;
});

/// Label for a day cell (`Th`, `Fr`, …).
String weekdayLabel(DateTime day) => _weekdayShort[day.weekday - 1];

/// Consecutive days where the whole routine was completed (today stays open).
final routineStreakProvider = Provider<int>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (snapshot == null || snapshot.habits.isEmpty) return 0;
  final today = ref.watch(calendarDayProvider);
  final earliest = snapshot.habits.map((h) => dayOnly(h.createdAt))
      .reduce((a, b) => a.isBefore(b) ? a : b);
  final availableDays = calendarDaysBetween(earliest, today) + 1;
  var streak = 0;
  for (var i = 0; i < availableDays; i++) {
    final day = addCalendarDays(today, -i);
    final scheduled = snapshot.scheduledOn(day).length;
    if (scheduled == 0) {
      if (i == 0) continue;
      break;
    }
    final complete = snapshot.completedOn(day) >= scheduled;
    if (complete) {
      streak++;
    } else if (i == 0) {
      // today still open
    } else {
      break;
    }
  }
  return streak;
});

/// Longest routine-complete run anywhere in the log.
final routineRecordProvider = Provider<int>((ref) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  if (snapshot == null || snapshot.habits.isEmpty) return 0;

  final allDays = <DateTime>{};
  for (final days in snapshot.log.values) {
    allDays.addAll(days.map(dayOnly));
  }
  if (allDays.isEmpty) return 0;

  final sorted = allDays.toList()..sort();
  var best = 0;
  for (final day in sorted) {
    final scheduled = snapshot.scheduledOn(day).length;
    if (scheduled > 0 && snapshot.completedOn(day) >= scheduled) {
      best = best < 1 ? 1 : best;
    }
  }
  // Longest consecutive run of complete days.
  var run = 0;
  var previous = DateTime.fromMillisecondsSinceEpoch(0);
  var bestRun = 0;
  for (final day in sorted) {
    final scheduled = snapshot.scheduledOn(day).length;
    final complete = scheduled > 0 && snapshot.completedOn(day) >= scheduled;
    if (!complete) {
      run = 0;
      continue;
    }
    run = (calendarDaysBetween(previous, day) == 1) ? run + 1 : 1;
    previous = day;
    if (run > bestRun) bestRun = run;
  }
  return bestRun > best ? bestRun : best;
});
