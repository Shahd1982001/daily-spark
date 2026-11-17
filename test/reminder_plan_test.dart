import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/data/services/reminder_plan.dart';
import 'package:flutter_test/flutter_test.dart';

Habit habit({String id = 'a', String? time = '08:30',
    HabitRhythm rhythm = HabitRhythm.everyDay, Set<int> days = const {1, 2},
    DateTime? archivedAt}) => Habit(id: id, title: 'Read', createdAt: DateTime(2026),
    reminderTime: time, rhythm: rhythm, days: days, archivedAt: archivedAt);

void main() {
  test('no reminders when globally disabled', () {
    expect(buildReminderPlan([habit()], enabled: false), isEmpty);
  });
  test('plans selected weekly days and local time', () {
    for (final entry in <HabitRhythm, List<int>>{
      HabitRhythm.everyDay: [1, 2, 3, 4, 5, 6, 7],
      HabitRhythm.weekdays: [1, 2, 3, 4, 5],
      HabitRhythm.weekends: [6, 7],
      HabitRhythm.custom: [1, 2],
    }.entries) {
      final rules = buildReminderPlan([habit(rhythm: entry.key)], enabled: true);
      expect(rules.map((r) => r.weekday), entry.value);
      expect(rules.every((r) => r.hour == 8 && r.minute == 30 && r.habitId == 'a'), isTrue);
    }
  });
  test('excludes paused, missing and invalid times', () {
    final invalid = [null, '', '8:30', '24:00', '12:60', 'xx:yy'];
    for (final time in invalid) {
      expect(buildReminderPlan([habit(time: time)], enabled: true), isEmpty);
    }
    expect(buildReminderPlan([habit(archivedAt: DateTime(2026))], enabled: true), isEmpty);
  });
  test('editing, pausing, restoring and removing alter rules without leftovers', () {
    final original = habit(rhythm: HabitRhythm.custom, days: {2, 5});
    expect(buildReminderPlan([original], enabled: true).map((r) => r.weekday), [2, 5]);
    final edited = original.copyWith(days: {3}, reminderTime: '20:15');
    final rule = buildReminderPlan([edited], enabled: true).single;
    expect([rule.weekday, rule.hour, rule.minute], [3, 20, 15]);
    expect(buildReminderPlan([edited.copyWith(archivedAt: DateTime(2026))], enabled: true), isEmpty);
    expect(buildReminderPlan([edited], enabled: true), hasLength(1));
    expect(buildReminderPlan([], enabled: true), isEmpty);
  });
  test('ignores invalid custom weekdays and respects other habits', () {
    final rules = buildReminderPlan([
      habit(id: 'a', rhythm: HabitRhythm.custom, days: {0, 2, 7, 8}),
      habit(id: 'b', rhythm: HabitRhythm.custom, days: {5}),
    ], enabled: true);
    expect(rules.map((r) => '${r.habitId}:${r.weekday}'), ['a:2', 'a:7', 'b:5']);
  });
}
