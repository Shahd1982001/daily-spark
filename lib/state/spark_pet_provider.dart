import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/day.dart';
import '../data/repositories/habit_repository.dart';

/// Latest missed *scheduled* day among the most recent scheduled days of each
/// currently active habit. Today is never a missed day until it has ended.
/// Paused periods are excluded by the habit model. Two weeks covers a weekly
/// rhythm without searching indefinitely through an old paused history.
DateTime? latestMissedDay(HabitsSnapshot snapshot, DateTime today) {
  final day = dayOnly(today);
  DateTime? latest;
  for (final habit in snapshot.activeHabits) {
    for (var i = 1; i <= 14; i++) {
      final previous = addCalendarDays(day, -i);
      if (previous.isBefore(dayOnly(habit.createdAt))) break;
      if (!habit.isScheduledOn(previous)) continue;
      if (!snapshot.isCompleted(habit.id, previous) &&
          (latest == null || previous.isAfter(latest))) latest = previous;
      break;
    }
  }
  return latest;
}

class SparkPetMood {
  const SparkPetMood({this.calmedDay, this.loaded = false});
  final String? calmedDay;
  final bool loaded;
}

class SparkPetMoodController extends Notifier<SparkPetMood> {
  static const key = 'ds_spark_calmed_day_v1';
  int _revision = 0;
  @override
  SparkPetMood build() {
    Future.microtask(_load);
    return const SparkPetMood();
  }
  Future<void> _load() async {
    final revision = _revision;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (revision == _revision) state = SparkPetMood(calmedDay: prefs.getString(key), loaded: true);
    } catch (_) {
      if (revision == _revision) state = const SparkPetMood(loaded: true);
    }
  }
  Future<void> comfort(DateTime missedDay) async {
    final value = dayKey(missedDay);
    _revision++;
    state = SparkPetMood(calmedDay: value, loaded: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {
      // The pet can still be comforted for this session if storage is absent.
    }
  }
}

final sparkPetMoodProvider = NotifierProvider<SparkPetMoodController, SparkPetMood>(SparkPetMoodController.new);
