import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/habit_store.dart';
import '../data/models/day.dart';
import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';
import '../data/seed/seed_data.dart';
import '../data/services/streaks.dart';

/// True only when the app is opened with `?demo=1` (design review / gallery).
/// A real first launch starts empty — no habits, no stats.
final demoModeProvider = Provider<bool>((ref) => false);

/// Overridden in `main()` with the real local store.
final habitStoreProvider = Provider<HabitStore>(
  (ref) => throw UnimplementedError('habitStoreProvider must be overridden'),
);

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepository(
    ref.watch(habitStoreProvider),
    seeder: ref.watch(demoModeProvider)
        ? seedSnapshot
        : HabitRepository.defaultSeeder,
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
    if (current == null) return;

    final target = dayOnly(day ?? DateTime.now());
    final log = <String, Set<DateTime>>{
      for (final entry in current.log.entries) entry.key: {...entry.value},
    };
    final days = log[habitId] ?? <DateTime>{};
    final wasDone = days.map(dayOnly).contains(target);
    if (wasDone) {
      days.removeWhere((d) => dayOnly(d) == target);
    } else {
      days.add(target);
    }
    log[habitId] = days;

    final next = current.copyWith(log: log);
    state = AsyncData(next);
    await _repo.save(next);
  }

  Future<void> addHabit(Habit habit) async {
    final current = state.valueOrNull ?? HabitsSnapshot.empty;
    final next = current.copyWith(habits: [...current.habits, habit]);
    state = AsyncData(next);
    await _repo.save(next);
  }

  Future<void> updateHabit(Habit habit) async {
    final current = state.valueOrNull ?? HabitsSnapshot.empty;
    final next = current.copyWith(
      habits: [
        for (final h in current.habits) if (h.id == habit.id) habit else h,
      ],
    );
    state = AsyncData(next);
    await _repo.save(next);
  }

  Future<void> archiveHabit(String habitId) async {
    final current = state.valueOrNull;
    final habit = current?.habitById(habitId);
    if (current == null || habit == null) return;
    await updateHabit(habit.copyWith(archivedAt: DateTime.now()));
  }

  Future<void> deleteHabit(String habitId) async {
    final current = state.valueOrNull ?? HabitsSnapshot.empty;
    final log = <String, Set<DateTime>>{
      for (final entry in current.log.entries)
        if (entry.key != habitId) entry.key: entry.value,
    };
    final next = HabitsSnapshot(
      habits: current.habits.where((h) => h.id != habitId).toList(),
      log: log,
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
  return snapshot.scheduledOn(DateTime.now());
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
  final now = DateTime.now();
  return TodaySummary(
    completed: snapshot.completedOn(now),
    total: habits.length,
  );
});

/// Streak for one habit, as shown on cards (`12d`).
final habitStreakProvider = Provider.family<int, String>((ref, habitId) {
  final snapshot = ref.watch(habitsProvider).valueOrNull;
  final habit = snapshot?.habitById(habitId);
  if (snapshot == null || habit == null) return 0;
  return streakFor(
    habit,
    snapshot.daysFor(habitId),
    today: DateTime.now(),
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
  final today = dayOnly(DateTime.now());
  final days = <DayStat>[];
  for (var offset = 6; offset >= 0; offset--) {
    final day = today.subtract(Duration(days: offset));
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
  if (snapshot == null) return 0;
  final today = dayOnly(DateTime.now());
  var streak = 0;
  for (var i = 0; i < 400; i++) {
    final day = today.subtract(Duration(days: i));
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
    run = (day.difference(previous).inDays == 1) ? run + 1 : 1;
    previous = day;
    if (run > bestRun) bestRun = run;
  }
  return bestRun > best ? bestRun : best;
});
