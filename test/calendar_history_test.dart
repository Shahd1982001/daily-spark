import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/day.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/data/repositories/habit_repository.dart';
import 'package:daily_spark/data/services/streaks.dart';
import 'package:daily_spark/state/calendar_day_provider.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCalendar extends CalendarDayController {
  @override
  DateTime build() => DateTime(2026, 11, 12);
  void setDay(DateTime value) => state = dayOnly(value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final origin = DateTime(2026, 11, 1);
  Habit make() => Habit(id: 'h', title: 'Read', createdAt: origin,
      targetAmount: 20, targetUnit: 'pages');

  Future<({ProviderContainer container, MemoryHabitStore store})> setup() async {
    final snapshot = HabitsSnapshot(habits: [make()], log: const {});
    final store = MemoryHabitStore(snapshot.toJson());
    final container = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(store)]);
    addTearDown(container.dispose);
    await container.read(habitsProvider.future);
    return (container: container, store: store);
  }

  test('schedule edits apply from the chosen day and survive reload', () async {
    final env = await setup();
    final controller = env.container.read(habitsProvider.notifier);
    final habit = env.container.read(habitsProvider).value!.habitById('h')!;
    await controller.updateHabit(habit.copyWith(rhythm: HabitRhythm.weekends, days: {6, 7}),
        effectiveAt: DateTime(2026, 11, 12));
    var edited = env.container.read(habitsProvider).value!.habitById('h')!;
    expect(edited.isScheduledOn(DateTime(2026, 11, 11)), isTrue);
    expect(edited.isScheduledOn(DateTime(2026, 11, 12)), isFalse);
    expect(edited.isScheduledOn(DateTime(2026, 11, 14)), isTrue);
    edited = (await HabitRepository(env.store).load()).habitById('h')!;
    expect(edited.isScheduledOn(DateTime(2026, 11, 11)), isTrue);
    expect(edited.isScheduledOn(DateTime(2026, 11, 12)), isFalse);
  });

  test('unit change resets that day only, preserves earlier amounts and their units', () async {
    final env = await setup();
    final ctrl = env.container.read(habitsProvider.notifier);
    final yesterday = DateTime(2026, 11, 11), today = DateTime(2026, 11, 12);
    await ctrl.setAmount('h', 15, day: yesterday);
    await ctrl.setAmount('h', 20, day: today);
    final old = env.container.read(habitsProvider).value!.habitById('h')!;
    await ctrl.updateHabit(old.copyWith(targetAmount: 10, targetUnit: 'mins'), effectiveAt: today);
    final snapshot = env.container.read(habitsProvider).value!;
    final edited = snapshot.habitById('h')!;
    expect(snapshot.amountFor('h', yesterday), 15);
    expect(snapshot.amountFor('h', today), 0);
    expect(snapshot.isCompleted('h', today), isFalse);
    expect(edited.planOn(yesterday).targetUnit, 'pages');
    expect(edited.planOn(today).targetUnit, 'mins');
    final reloaded = await HabitRepository(env.store).load();
    expect(reloaded.amountFor('h', yesterday), 15);
    expect(reloaded.amountFor('h', today), 0);
    expect(reloaded.habitById('h')!.planOn(yesterday).targetUnit, 'pages');
  });

  test('legacy completion without an amount keeps its old target after edit', () async {
    final yesterday = DateTime(2026, 11, 11), today = DateTime(2026, 11, 12);
    final store = MemoryHabitStore(HabitsSnapshot(
      habits: [make()], log: {'h': {yesterday}},
    ).toJson());
    final container = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(store)]);
    addTearDown(container.dispose);
    await container.read(habitsProvider.future);
    final ctrl = container.read(habitsProvider.notifier);
    final original = container.read(habitsProvider).value!.habitById('h')!;
    await ctrl.updateHabit(original.copyWith(targetAmount: 30), effectiveAt: today);
    final reloaded = await HabitRepository(store).load();
    expect(reloaded.amountFor('h', yesterday), 20);
    expect(reloaded.habitById('h')!.planOn(yesterday).targetAmount, 20);
    expect(reloaded.isCompleted('h', yesterday), isTrue);
  });

  test('same-unit target edit retains amount and recalculates today only', () async {
    final env = await setup();
    final ctrl = env.container.read(habitsProvider.notifier);
    final yesterday = DateTime(2026, 11, 11), today = DateTime(2026, 11, 12);
    await ctrl.setAmount('h', 20, day: yesterday);
    await ctrl.setAmount('h', 20, day: today);
    final old = env.container.read(habitsProvider).value!.habitById('h')!;
    await ctrl.updateHabit(old.copyWith(targetAmount: 30), effectiveAt: today);
    var snap = env.container.read(habitsProvider).value!;
    expect(snap.amountFor('h', today), 20);
    expect(snap.isCompleted('h', today), isFalse);
    expect(snap.isCompleted('h', yesterday), isTrue);
    expect(snap.habitById('h')!.planOn(yesterday).targetAmount, 20);
    final updated = snap.habitById('h')!;
    await ctrl.updateHabit(updated.copyWith(targetAmount: 10), effectiveAt: today);
    snap = env.container.read(habitsProvider).value!;
    expect(snap.amountFor('h', today), 20);
    expect(snap.isCompleted('h', today), isTrue);
    expect(snap.habitById('h')!.planOn(yesterday).targetAmount, 20);
  });

  test('a long streak is not silently capped at 400 days', () {
    final start = DateTime(2024, 1, 1);
    final habit = Habit(id: 'long', title: 'x', createdAt: start);
    final days = {for (var i = 0; i < 450; i++) addCalendarDays(start, i)};
    expect(streakFor(habit, days, today: addCalendarDays(start, 449)), 450);
  });

  test('calendar stepping and streaks across daylight saving transitions', () {
    for (final day in [DateTime(2026, 3, 8), DateTime(2026, 11, 1)]) {
      final previous = addCalendarDays(day, -1), next = addCalendarDays(day, 1);
      expect(calendarDaysBetween(previous, day), 1);
      expect(calendarDaysBetween(day, next), 1);
      expect(dayKey(addCalendarDays(previous, 1)), dayKey(day));
      final habit = Habit(id: 'dst', title: 'x', createdAt: previous);
      expect(streakFor(habit, {previous, day, next}, today: next), 3);
    }
  });

  test('day-dependent providers recompute after the civil date changes', () async {
    final store = MemoryHabitStore(HabitsSnapshot(habits: [make()], log: const {}).toJson());
    final container = ProviderContainer(overrides: [
      habitStoreProvider.overrideWithValue(store),
      calendarDayProvider.overrideWith(FakeCalendar.new),
    ]);
    addTearDown(container.dispose);
    await container.read(habitsProvider.future);
    await container.read(habitsProvider.notifier).setAmount('h', 20, day: DateTime(2026, 11, 12));
    expect(container.read(todaySummaryProvider).completed, 1);
    (container.read(calendarDayProvider.notifier) as FakeCalendar).setDay(DateTime(2026, 11, 13));
    expect(container.read(todaySummaryProvider).completed, 0);
    expect(container.read(todaySummaryProvider).total, 1);
  });
}
