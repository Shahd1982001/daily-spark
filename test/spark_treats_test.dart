import 'package:daily_spark/config/feature_flags.dart';
import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/spark_treats_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('completing with no pet visible awards once, persists and feeds', () async {
    SharedPreferences.setMockInitialValues({});
    final store = MemoryHabitStore();
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(store)]);
    await c.read(habitsProvider.future);
    await c.read(habitsProvider.notifier).addHabit(Habit(id: 'a', title: 'Read', createdAt: DateTime.now()));
    await c.read(habitsProvider.notifier).setAmount('a', 1);
    expect(c.read(sparkTreatsProvider).items.length, 1);
    await c.read(habitsProvider.notifier).setAmount('a', 0);
    await c.read(habitsProvider.notifier).setAmount('a', 1);
    expect(c.read(sparkTreatsProvider).items.length, 1);
    final original = c.read(sparkTreatsProvider).items.first;
    c.dispose();
    final second = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(store)]);
    second.read(sparkTreatsProvider);
    final eaten = await second.read(sparkTreatsProvider.notifier).feed();
    expect(eaten, original);
    expect(second.read(sparkTreatsProvider).items, isEmpty);
    expect(await second.read(sparkTreatsProvider.notifier).award('a', DateTime.now().toIso8601String().substring(0,10)), isNull);
    second.dispose();
  }, skip: !sparkCharacterEnabled);

  test('disabled character does not award treats on completion', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer(overrides: [
      habitStoreProvider.overrideWithValue(MemoryHabitStore()),
    ]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    await c.read(habitsProvider.notifier).addHabit(
      Habit(id: 'disabled', title: 'Read', createdAt: DateTime.now()),
    );
    await c.read(habitsProvider.notifier).setAmount('disabled', 1);
    expect(c.read(sparkTreatsProvider).items, isEmpty);
  }, skip: sparkCharacterEnabled);
}
