import '../models/day.dart';
import '../models/habit.dart';

/// Pure streak math — no I/O, fully unit-tested.
///
/// A streak is the number of consecutive *scheduled* days the habit was
/// completed, counting back from [today]. Today itself never breaks a streak
/// while it is still open (the day is not over yet).
int streakFor(
  Habit habit,
  Set<DateTime> completedDays, {
  required DateTime today,
  int? lookBackDays,
}) {
  final done = completedDays.map(dayOnly).toSet();
  var streak = 0;
  var day = dayOnly(today);
  final created = dayOnly(habit.createdAt);

  final availableDays = (calendarDaysBetween(created, day) + 1).clamp(0, 1000000);
  final limit = lookBackDays == null ? availableDays : lookBackDays.clamp(0, availableDays);
  for (var i = 0; i < limit; i++) {
    if (day.isBefore(created)) break;

    final scheduled = habit.isScheduledOn(day);
    final completed = done.contains(day);

    if (scheduled) {
      if (completed) {
        streak++;
      } else if (i == 0) {
        // Today is still open — do not break, just skip it.
      } else {
        break;
      }
    }
    day = addCalendarDays(day, -1);
  }
  return streak;
}

/// Completion ratio for one habit over the last [days] days (scheduled only).
/// Returns 0 when the habit was never scheduled in that window.
int completionPercent(
  Habit habit,
  Set<DateTime> completedDays, {
  required DateTime today,
  int days = 14,
}) {
  final done = completedDays.map(dayOnly).toSet();
  var scheduled = 0;
  var completed = 0;
  var day = dayOnly(today);
  for (var i = 0; i < days; i++) {
    if (day.isBefore(dayOnly(habit.createdAt))) break;
    if (habit.isScheduledOn(day)) {
      scheduled++;
      if (done.contains(day)) completed++;
    }
    day = addCalendarDays(day, -1);
  }
  if (scheduled == 0) return 0;
  return ((completed / scheduled) * 100).round();
}
