import '../models/habit.dart';

/// A weekly reminder rule in the device's local wall-clock time.
/// Weekdays use Dart's Monday=1 through Sunday=7 convention.
class ReminderRule {
  const ReminderRule({required this.habitId, required this.weekday,
    required this.hour, required this.minute});
  final String habitId;
  final int weekday;
  final int hour;
  final int minute;
}

/// Derive reminders solely from active habits with a valid explicit time.
/// No rule is created for habits without a time. The caller must exclude
/// demo data. [enabled] is the global reminders preference.
///
/// This is a pure planning step; it does not request permissions or schedule
/// OS notifications. The platform adapter must handle timezone changes,
/// platform limits, permission state, rescheduling and delivery failures.
List<ReminderRule> buildReminderPlan(Iterable<Habit> habits, {required bool enabled}) {
  if (!enabled) return const [];
  final rules = <ReminderRule>[];
  for (final habit in habits) {
    if (habit.isArchived) continue;
    final time = habit.reminderTime;
    final match = time == null ? null : RegExp(r'^(\d{2}):(\d{2})$').firstMatch(time);
    if (match == null) continue;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) continue;
    final days = switch (habit.rhythm) {
      HabitRhythm.everyDay => <int>{1, 2, 3, 4, 5, 6, 7},
      HabitRhythm.weekdays => <int>{1, 2, 3, 4, 5},
      HabitRhythm.weekends => <int>{6, 7},
      HabitRhythm.custom => habit.days.where((d) => d >= 1 && d <= 7).toSet(),
    };
    final orderedDays = days.toList()..sort();
    for (final day in orderedDays) {
      rules.add(ReminderRule(habitId: habit.id, weekday: day, hour: hour, minute: minute));
    }
  }
  return rules;
}
