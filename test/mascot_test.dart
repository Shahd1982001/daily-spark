import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/data/repositories/habit_repository.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/mascot_providers.dart';
import 'package:daily_spark/state/spark_pet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Habit h({String id='h', String? time='10:00', HabitRhythm rhythm=HabitRhythm.everyDay,
    Set<int> days=const {1}, DateTime? archivedAt}) => Habit(id: id, title: 'Read',
    createdAt: DateTime(2026, 1, 1), reminderTime: time, rhythm: rhythm,
    days: days, archivedAt: archivedAt);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('sad only after a scheduled day has passed without completion', () {
    final now = DateTime(2026, 11, 17, 10);
    HabitsSnapshot snap(Habit habit, {bool done=false}) => HabitsSnapshot(
      habits: [habit], log: done ? {habit.id: {DateTime(2026,11,16)}} : {}, amounts: const {});
    expect(latestMissedDay(snap(h()), now), DateTime(2026,11,16));
    expect(latestMissedDay(snap(h(), done:true), now), isNull);
    expect(latestMissedDay(snap(h(archivedAt: DateTime(2026, 11, 16))), now), isNull);
    expect(latestMissedDay(snap(h(rhythm: HabitRhythm.custom, days: {2})), now), DateTime(2026,11,10));
    final createdToday = Habit(id:'new', title:'New', createdAt:now);
    expect(latestMissedDay(snap(createdToday), now), isNull);
    expect(latestMissedDay(const HabitsSnapshot(habits: [], log: {}), now), isNull);
  });
  test('celebration emitted only when today crosses the goal, even without sound', () async {
    final c=ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(MemoryHabitStore())]);
    addTearDown(c.dispose);
    var events = 0;
    final sub=c.listen(completionCelebrationProvider, (_, next) { if (next != null) events++; });
    addTearDown(sub.close);
    await c.read(habitsProvider.future);
    final ctrl=c.read(habitsProvider.notifier);
    await ctrl.addHabit(h().copyWith(targetAmount: 3));
    await ctrl.setAmount('h', 2);
    expect(events, 0);
    await ctrl.setAmount('h', 3);
    expect(events, 1);
    await ctrl.setAmount('h', 3);
    expect(events, 1);
    await ctrl.setAmount('h', 0);
    expect(events, 1);
    await ctrl.setAmount('h', 3, day: DateTime.now().subtract(const Duration(days:1)));
    expect(events, 1);
  });
}
