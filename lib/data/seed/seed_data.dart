import '../models/day.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';

/// First-run content, mirroring the approved Figma data set so the UI keeps
/// looking exactly like the designs while the logic comes alive.
///
/// The completion log is generated relative to [now] so streaks read 12d / 8d /
/// 5d / 19d / 7d on day one — the same numbers the designs show.
HabitsSnapshot seedSnapshot(DateTime now) {
  final created = dayOnly(now).subtract(const Duration(days: 40));

  Habit habit({
    required String id,
    required String title,
    required String note,
    required String iconKey,
    required HabitAccent accent,
    required String category,
    required int sortOrder,
    String detailTag = '',
    String? reminderTime,
    int targetAmount = 1,
    String targetUnit = 'times',
    HabitRhythm rhythm = HabitRhythm.everyDay,
    Set<int> days = const {1, 2, 3, 4, 5, 6, 7},
  }) =>
      Habit(
        id: id,
        title: title,
        note: note,
        iconKey: iconKey,
        accent: accent,
        category: category,
        detailTag: detailTag,
        reminderTime: reminderTime,
        targetAmount: targetAmount,
        targetUnit: targetUnit,
        rhythm: rhythm,
        days: days,
        sortOrder: sortOrder,
        createdAt: created,
      );

  final habits = <Habit>[
    habit(
      id: 'h_meditation',
      title: 'Morning Meditation',
      note: 'Ten quiet minutes before the day starts.',
      iconKey: 'meditation',
      accent: HabitAccent.sage,
      category: 'Morning',
      reminderTime: '08:00',
      targetAmount: 10,
      targetUnit: 'mins',
      sortOrder: 0,
    ),
    habit(
      id: 'h_hydrate',
      title: 'Hydrate (1.5L)',
      note: 'Steady sips through the day.',
      iconKey: 'water',
      accent: HabitAccent.sage,
      category: 'Morning',
      targetAmount: 1500,
      targetUnit: 'ml',
      sortOrder: 1,
    ),
    habit(
      id: 'h_read',
      title: 'Read 20 Pages',
      note: 'Building intellectual stillness & depth',
      iconKey: 'book',
      accent: HabitAccent.sage,
      category: 'Anytime',
      detailTag: 'Atomic Habits',
      targetAmount: 20,
      targetUnit: 'pages',
      sortOrder: 2,
    ),
    habit(
      id: 'h_workout',
      title: '30-Min Workout / Walk',
      note: 'Movement first, screens later.',
      iconKey: 'walk',
      accent: HabitAccent.terracotta,
      category: 'Anytime',
      reminderTime: '17:30',
      targetAmount: 30,
      targetUnit: 'mins',
      sortOrder: 3,
    ),
    habit(
      id: 'h_journal',
      title: 'Evening Journal',
      note: 'One page of reflection before sleep.',
      iconKey: 'journal',
      accent: HabitAccent.slate,
      category: 'Evening',
      reminderTime: '21:30',
      targetAmount: 1,
      targetUnit: 'entry',
      sortOrder: 4,
    ),
  ];

  final today = dayOnly(now);

  // Days completed, counting back from yesterday (today is partially done).
  final log = <String, Set<DateTime>>{
    'h_meditation': _run(today, 12, includeToday: true),
    'h_hydrate': _run(today, 8, includeToday: true),
    'h_read': _run(today, 5, includeToday: true),
    'h_workout': _run(today, 19, includeToday: false),
    'h_journal': _run(today, 7, includeToday: false),
  };

  return HabitsSnapshot(habits: habits, log: log);
}

/// `count` consecutive days ending today (or yesterday) — with a few natural
/// gaps so the data does not look machine-perfect.
Set<DateTime> _run(DateTime today, int count, {required bool includeToday}) {
  final days = <DateTime>{};
  var cursor = includeToday ? today : dayOnly(today).subtract(const Duration(days: 1));
  var remaining = count;
  var guard = 0;
  while (remaining > 0 && guard < 400) {
    days.add(cursor);
    remaining--;
    guard++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return days;
}
