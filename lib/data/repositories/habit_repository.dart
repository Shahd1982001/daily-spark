import '../local/habit_store.dart';
import '../models/day.dart';
import '../models/habit.dart';

/// Aggregated read model: the habits plus the completion log.
///
/// `log` maps a habit id to the calendar days it was completed on.
class HabitsSnapshot {
  const HabitsSnapshot({
    required this.habits,
    required this.log,
    this.amounts = const {},
  });

  final List<Habit> habits;

  /// Which calendar days a habit was *completed* on.
  final Map<String, Set<DateTime>> log;

  /// Partial progress for amount-based habits:
  /// habit id → `yyyy-MM-dd` → amount logged that day.
  ///
  /// A day is complete when the amount reaches the habit's target; `log` stays
  /// the single source of truth for "done", `amounts` only adds the in-between.
  final Map<String, Map<String, int>> amounts;

  static const int schemaVersion = 1;

  static const empty = HabitsSnapshot(habits: [], log: {});

  List<Habit> get activeHabits =>
      habits.where((h) => !h.isArchived).toList(growable: false);

  /// Habits expected on [day], in display order.
  List<Habit> scheduledOn(DateTime day) {
    final list = habits.where((h) => h.isScheduledOn(day)).toList()
      ..sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        return a.createdAt.compareTo(b.createdAt);
      });
    return list;
  }

  Set<DateTime> daysFor(String habitId) => log[habitId] ?? const <DateTime>{};

  bool isCompleted(String habitId, DateTime day) =>
      daysFor(habitId).map(dayOnly).contains(dayOnly(day));

  /// Amount logged for [habitId] on [day] (0 when nothing is recorded).
  int amountFor(String habitId, DateTime day) {
    final stored = amounts[habitId]?[dayKey(day)];
    if (stored != null) return stored;
    return isCompleted(habitId, day)
        ? (habitById(habitId)?.targetAmount ?? 1)
        : 0;
  }

  int completedOn(DateTime day) {
    final key = dayOnly(day);
    return scheduledOn(day)
        .where((h) => daysFor(h.id).map(dayOnly).contains(key))
        .length;
  }

  Habit? habitById(String habitId) {
    for (final h in habits) {
      if (h.id == habitId) return h;
    }
    return null;
  }

  HabitsSnapshot copyWith({
    List<Habit>? habits,
    Map<String, Set<DateTime>>? log,
    Map<String, Map<String, int>>? amounts,
  }) =>
      HabitsSnapshot(
        habits: habits ?? this.habits,
        log: log ?? this.log,
        amounts: amounts ?? this.amounts,
      );

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'habits': habits.map((h) => h.toJson()).toList(),
        'amounts': amounts.map(
          (habitId, days) => MapEntry(habitId, Map<String, int>.from(days)),
        ),
        'log': log.map(
          (habitId, days) => MapEntry(
            habitId,
            (days.map(dayKey).toList()..sort()),
          ),
        ),
      };

  factory HabitsSnapshot.fromJson(Map<String, dynamic> json) {
    final habits = ((json['habits'] as List?) ?? const [])
        .whereType<Map>()
        .map((h) => Habit.fromJson(h.cast<String, dynamic>()))
        .toList();
    final log = <String, Set<DateTime>>{};
    final rawLog = (json['log'] as Map?) ?? const {};
    rawLog.forEach((key, value) {
      final days = ((value as List?) ?? const [])
          .whereType<String>()
          .map(parseDayKey)
          .whereType<DateTime>()
          .map(dayOnly)
          .toSet();
      if (days.isNotEmpty) log[key as String] = days;
    });
    final amounts = <String, Map<String, int>>{};
    final rawAmounts = (json['amounts'] as Map?) ?? const {};
    rawAmounts.forEach((key, value) {
      if (value is! Map) return;
      final perDay = <String, int>{};
      value.forEach((day, amount) {
        final parsed = (amount as num?)?.toInt();
        if (parsed != null) perDay[day as String] = parsed;
      });
      if (perDay.isNotEmpty) amounts[key as String] = perDay;
    });
    return HabitsSnapshot(habits: habits, log: log, amounts: amounts);
  }
}

/// Persists to a repository with a single JSON payload.
class HabitRepository {
  HabitRepository(this._store, {this.seeder = defaultSeeder});

  final HabitStore _store;

  /// Called once, when there is nothing stored yet.
  final HabitsSnapshot Function(DateTime now) seeder;

  static HabitsSnapshot defaultSeeder(DateTime now) =>
      HabitsSnapshot(habits: const [], log: const {});

  /// Loads the snapshot, seeding the store on first launch.
  Future<HabitsSnapshot> load({DateTime? now}) async {
    final raw = await _store.read();
    if (raw == null || raw.isEmpty) {
      final seeded = seeder(now ?? DateTime.now());
      await save(seeded);
      return seeded;
    }
    return HabitsSnapshot.fromJson(raw);
  }

  Future<void> save(HabitsSnapshot snapshot) =>
      _store.write(snapshot.toJson());
}
