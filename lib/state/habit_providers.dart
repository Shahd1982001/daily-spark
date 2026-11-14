import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/habit_store.dart';
import '../data/models/day.dart';
import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';
import '../data/seed/seed_data.dart';
import '../data/services/streaks.dart';

/// Overridden in `main()` with the real local store.
final habitStoreProvider = Provider<HabitStore>(
  (ref) => throw UnimplementedError('habitStoreProvider must be overridden'),
);

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepository(
    ref.watch(habitStoreProvider),
    seeder: seedSnapshot,
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
