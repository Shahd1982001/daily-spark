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
  });

  final List<Habit> habits;
  final Map<String, Set<DateTime>> log;

  static const int schemaVersion = 1;

  static const empty = HabitsSnapshot(habits: [], log: {});

  List<Habit> get activeHabits =>
      habits.where((h) => !h.isArchived).toList(growable: false);

  /// Habits expected on [day], in display order.
  List<Habit> scheduledOn(DateTime day) {
    final list = activeHabits.where((h) => h.isScheduledOn(day)).toList()
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
  }) =>
      HabitsSnapshot(
        habits: habits ?? this.habits,
        log: log ?? this.log,
      );

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'habits': habits.map((h) => h.toJson()).toList(),
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
    return HabitsSnapshot(habits: habits, log: log);
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
