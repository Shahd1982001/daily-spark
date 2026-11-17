import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/habit.dart';
import '../data/repositories/habit_repository.dart';

/// Event counter only; no persisted personal information and no event on load.
final completionCelebrationProvider = StateProvider<int>((ref) => 0);

/// Returns whether an active, scheduled, incomplete habit is past its own
/// reminder time today, with a one-hour grace period.
bool hasOverdueHabit(HabitsSnapshot snapshot, DateTime now) {
  for (final habit in snapshot.scheduledOn(now)) {
    if (habit.isArchived || snapshot.isCompleted(habit.id, now)) continue;
    final time = habit.reminderTime;
    final match = time == null ? null : RegExp(r'^(\d{2}):(\d{2})$').firstMatch(time);
    if (match == null) continue;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) continue;
    if (now.hour * 60 + now.minute >= hour * 60 + minute + 60) return true;
  }
  return false;
}
