import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/data/repositories/habit_repository.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/mascot_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Habit h({String id='h', String? time='10:00', HabitRhythm rhythm=HabitRhythm.everyDay,
    Set<int> days=const {1}, DateTime? archivedAt}) => Habit(id: id, title: 'Read',
    createdAt: DateTime(2026, 1, 1), reminderTime: time, rhythm: rhythm,
    days: days, archivedAt: archivedAt);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('late message only for scheduled incomplete active habits after their time', () {
    final now = DateTime(2026, 11, 17, 11, 0);
    HabitsSnapshot snap(Habit habit, {bool done=false}) => HabitsSnapshot(
      habits: [habit], log: done ? {habit.id: {DateTime(2026,11,17)}} : {}, amounts: const {});
    expect(hasOverdueHabit(snap(h()), now), isTrue);
    expect(hasOverdueHabit(snap(h()), DateTime(2026, 11, 17, 10, 59)), isFalse);
    expect(hasOverdueHabit(snap(h(), done:true), now), isFalse);
    expect(hasOverdueHabit(snap(h(time:null)), now), isFalse);
    expect(hasOverdueHabit(snap(h(time:'99:99')), now), isFalse);
    expect(hasOverdueHabit(snap(h(archivedAt: DateTime(2026, 11, 17))), now), isFalse);
    expect(hasOverdueHabit(snap(h(rhythm: HabitRhythm.custom, days: {1})), now), isFalse);
  });
  test('celebration emitted only when today crosses the goal, even without sound', () async {
    final c=ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(MemoryHabitStore())]);
    addTearDown(c.dispose);
    final sub=c.listen(completionCelebrationProvider, (_, __) {});
    addTearDown(sub.close);
    await c.read(habitsProvider.future);
    final ctrl=c.read(habitsProvider.notifier);
    await ctrl.addHabit(h().copyWith(targetAmount: 3));
    await ctrl.setAmount('h', 2);
    expect(c.read(completionCelebrationProvider), 0);
    await ctrl.setAmount('h', 3);
    expect(c.read(completionCelebrationProvider), 1);
    await ctrl.setAmount('h', 3);
    expect(c.read(completionCelebrationProvider), 1);
    await ctrl.setAmount('h', 0);
    expect(c.read(completionCelebrationProvider), 1);
    await ctrl.setAmount('h', 3, day: DateTime.now().subtract(const Duration(days:1)));
    expect(c.read(completionCelebrationProvider), 1);
  });
}
