import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/day.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/data/repositories/habit_repository.dart';
import 'package:daily_spark/data/seed/seed_data.dart';
import 'package:daily_spark/data/services/streaks.dart';
import 'package:daily_spark/state/details_providers.dart';
import 'package:daily_spark/state/habit_providers.dart';

Habit _habit({
  String id = 'h1',
  HabitRhythm rhythm = HabitRhythm.everyDay,
  Set<int> days = const {1, 2, 3, 4, 5, 6, 7},
  DateTime? createdAt,
}) =>
    Habit(
      id: id,
      title: 'Read',
      rhythm: rhythm,
      days: days,
      createdAt: createdAt ?? DateTime(2026, 10, 1),
    );

void main() {
  group('calendar keys', () {
    test('dayKey is stable and zero padded', () {
      expect(dayKey(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
    });

    test('parseDayKey round-trips and rejects junk', () {
      expect(parseDayKey('2026-11-12'), DateTime(2026, 11, 12));
      expect(parseDayKey('nope'), isNull);
      expect(parseDayKey('2026-11'), isNull);
    });
  });

  group('Habit model', () {
    test('JSON round-trip keeps every field', () {
      final habit = Habit(
        id: 'h_read',
        title: 'Read 20 Pages',
        note: 'Building depth',
        iconKey: 'book',
        accent: HabitAccent.sage,
        rhythm: HabitRhythm.weekdays,
        days: {1, 3, 5},
        targetAmount: 20,
        targetUnit: 'pages',
        reminderTime: '21:30',
        category: 'Evening',
        detailTag: 'Atomic Habits',
        sortOrder: 2,
        createdAt: DateTime(2026, 10, 1),
      );

      final restored = Habit.fromJson(habit.toJson());
      expect(restored.title, 'Read 20 Pages');
      expect(restored.rhythm, HabitRhythm.weekdays);
      expect(restored.accent, HabitAccent.sage);
      expect(restored.days, {1, 3, 5});
      expect(restored.targetAmount, 20);
      expect(restored.reminderTime, '21:30');
      expect(restored.detailTag, 'Atomic Habits');
      expect(restored.createdAt, DateTime(2026, 10, 1));
    });

    test('scheduling respects rhythm and custom days', () {
      final everyDay = _habit();
      final weekdays = _habit(id: 'h2', rhythm: HabitRhythm.weekdays);
      final custom = _habit(id: 'h3', rhythm: HabitRhythm.custom, days: {2, 4});

      final monday = DateTime(2026, 11, 9); // weekday 1
      final tuesday = DateTime(2026, 11, 10); // weekday 2
      final saturday = DateTime(2026, 11, 14); // weekday 6

      expect(everyDay.isScheduledOn(saturday), isTrue);
      expect(weekdays.isScheduledOn(monday), isTrue);
      expect(weekdays.isScheduledOn(saturday), isFalse);
      expect(custom.isScheduledOn(tuesday), isTrue);
      expect(custom.isScheduledOn(monday), isFalse);
    });

    test('archived habits are never scheduled', () {
      final habit = _habit().copyWith(archivedAt: DateTime(2026, 11, 1));
      expect(habit.isScheduledOn(DateTime(2026, 11, 12)), isFalse);
    });
  });

  group('streaks', () {
    final today = DateTime(2026, 11, 12);

    test('counts consecutive completed days', () {
      final habit = _habit();
      final days = {
        today,
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 2)),
      };
      expect(streakFor(habit, days, today: today), 3);
    });

    test('an open today does not break the streak', () {
      final habit = _habit();
      final days = {
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 2)),
      };
      expect(streakFor(habit, days, today: today), 2);
    });

    test('a missed past day breaks it', () {
      final habit = _habit();
      final days = {
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 3)),
      };
      expect(streakFor(habit, days, today: today), 1);
    });

    test('non-scheduled days are skipped, not broken', () {
      // Weekends-only habit, today is Thursday 12 Nov 2026.
      final habit = _habit(rhythm: HabitRhythm.weekends);
      final days = {
        DateTime(2026, 11, 8), // Sunday
        DateTime(2026, 11, 7), // Saturday
        DateTime(2026, 11, 1), // Sunday before
        DateTime(2026, 10, 31), // Saturday before
      };
      expect(streakFor(habit, days, today: today), 4);
    });

    test('completion percent only counts scheduled days', () {
      final habit = _habit(rhythm: HabitRhythm.weekends);
      final days = {DateTime(2026, 11, 8), DateTime(2026, 11, 7)};
      // 4 weekend days in the last 14 days, 2 of them completed → 50 %.
      expect(completionPercent(habit, days, today: today, days: 14), 50);
    });
  });

  group('repository + seeding', () {
    test('first load seeds and persists', () async {
      final store = MemoryHabitStore();
      final repo = HabitRepository(store, seeder: seedSnapshot);

      final snapshot = await repo.load(now: DateTime(2026, 11, 12, 9));
      expect(snapshot.habits.length, 5);
      expect(snapshot.log.keys.length, 5);
      expect(store.writes, 1);
      expect(snapshot.completedOn(DateTime(2026, 11, 12)), 3);
    });

    test('second load reads what was persisted, no re-seed', () async {
      final store = MemoryHabitStore();
      final repo = HabitRepository(store, seeder: seedSnapshot);
      final first = await repo.load(now: DateTime(2026, 11, 12, 9));

      final second = await HabitRepository(store, seeder: seedSnapshot)
          .load(now: DateTime(2026, 11, 12, 10));
      expect(second.habits.length, first.habits.length);
      expect(store.writes, 1);
    });

    test('empty store with the default seeder starts empty', () async {
      final repo = HabitRepository(MemoryHabitStore());
      final snapshot = await repo.load();
      expect(snapshot.habits, isEmpty);
    });
  });

  group('HabitsController', () {
    ProviderContainer containerWith(MemoryHabitStore store) {
      final container = ProviderContainer(
        overrides: [
          habitStoreProvider.overrideWithValue(store),
          demoModeProvider.overrideWithValue(DemoMode.full),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('loads the seeded snapshot', () async {
      final container = containerWith(MemoryHabitStore());
      final snapshot = await container.read(habitsProvider.future);
      expect(snapshot.habits, isNotEmpty);
      expect(container.read(todaySummaryProvider).total, greaterThan(0));
    });

    test('toggle marks a habit done and writes to the store', () async {
      final store = MemoryHabitStore();
      final container = containerWith(store);
      await container.read(habitsProvider.future);

      // A habit the seed leaves open today.
      const habitId = 'h_workout';
      final before = container.read(todaySummaryProvider).completed;
      expect(
        container.read(habitsProvider).value!.isCompleted(habitId, DateTime.now()),
        isFalse,
      );

      await container.read(habitsProvider.notifier).toggle(habitId);

      final snapshot = container.read(habitsProvider).value!;
      expect(snapshot.isCompleted(habitId, DateTime.now()), isTrue);
      expect(container.read(todaySummaryProvider).completed, before + 1);
      expect(store.writes, greaterThan(1));
    });

    test('toggle un-completes a habit that was already done', () async {
      final container = containerWith(MemoryHabitStore());
      await container.read(habitsProvider.future);
      const habitId = 'h_meditation'; // seeded as done today
      expect(
        container.read(habitsProvider).value!.isCompleted(habitId, DateTime.now()),
        isTrue,
      );

      await container.read(habitsProvider.notifier).toggle(habitId);

      expect(
        container.read(habitsProvider).value!.isCompleted(habitId, DateTime.now()),
        isFalse,
      );
    });

    test('toggling twice returns to the original state', () async {
      final container = containerWith(MemoryHabitStore());
      await container.read(habitsProvider.future);
      const habitId = 'h_journal'; // seeded as open today

      await container.read(habitsProvider.notifier).toggle(habitId);
      await container.read(habitsProvider.notifier).toggle(habitId);

      final snapshot = container.read(habitsProvider).value!;
      expect(snapshot.isCompleted(habitId, DateTime.now()), isFalse);
    });

    test('add, archive and delete keep the snapshot consistent', () async {
      final container = containerWith(MemoryHabitStore());
      final initial = await container.read(habitsProvider.future);
      final controller = container.read(habitsProvider.notifier);

      final habit = Habit(
        id: 'h_new',
        title: 'Stretch',
        createdAt: DateTime.now(),
        sortOrder: 99,
      );
      await controller.addHabit(habit);
      expect(container.read(habitsProvider).value!.habits.length,
          initial.habits.length + 1);

      await controller.archiveHabit('h_new');
      final archived = container.read(habitsProvider).value!.habitById('h_new')!;
      expect(archived.isArchived, isTrue);
      expect(
        container.read(todayHabitsProvider).any((h) => h.id == 'h_new'),
        isFalse,
      );

      await controller.deleteHabit('h_new');
      expect(container.read(habitsProvider).value!.habitById('h_new'), isNull);
    });

    test('streak provider matches the seeded run', () async {
      final container = containerWith(MemoryHabitStore());
      await container.read(habitsProvider.future);
      expect(container.read(habitStreakProvider('h_workout')), 19);
    });
  });

  group('Habit Details', () {
    ProviderContainer containerWith(MemoryHabitStore store) {
      final container = ProviderContainer(
        overrides: [
          habitStoreProvider.overrideWithValue(store),
          demoModeProvider.overrideWithValue(DemoMode.full),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('details follow the selected habit', () async {
      final container = containerWith(MemoryHabitStore());
      await container.read(habitsProvider.future);

      container.read(selectedHabitIdProvider.notifier).state = 'h_read';
      final detail = container.read(habitDetailProvider)!;
      expect(detail.habit.id, 'h_read');
      expect(detail.targetAmount, 20);
      expect(detail.doneToday, isTrue);
      expect(detail.amountToday, 20);
      expect(detail.streak, 5);
    });

    test('an unknown id falls back to the first habit of the day', () async {
      final container = containerWith(MemoryHabitStore());
      await container.read(habitsProvider.future);

      container.read(selectedHabitIdProvider.notifier).state = 'nope';
      final detail = container.read(habitDetailProvider)!;
      expect(detail.habit.id, container.read(todayHabitsProvider).first.id);
    });

    test('stepping the amount moves between open, partial and complete',
        () async {
      final container = containerWith(MemoryHabitStore());
      await container.read(habitsProvider.future);
      final controller = container.read(habitsProvider.notifier);
      const habitId = 'h_read'; // target 20, seeded complete today

      final snapshot = container.read(habitsProvider).value!;
      expect(snapshot.isCompleted(habitId, DateTime.now()), isTrue);

      await controller.setAmount(habitId, 10);
      var updated = container.read(habitsProvider).value!;
      expect(updated.isCompleted(habitId, DateTime.now()), isFalse);
      expect(updated.amountFor(habitId, DateTime.now()), 10);

      await controller.stepAmount(habitId, 10);
      updated = container.read(habitsProvider).value!;
      expect(updated.isCompleted(habitId, DateTime.now()), isTrue);
      expect(updated.amountFor(habitId, DateTime.now()), 20);

      // Never above the target, never below zero.
      await controller.stepAmount(habitId, 10);
      expect(container.read(habitsProvider).value!.amountFor(habitId, DateTime.now()), 20);
      await controller.setAmount(habitId, -5);
      expect(container.read(habitsProvider).value!.amountFor(habitId, DateTime.now()), 0);
      expect(
        container.read(habitsProvider).value!.isCompleted(habitId, DateTime.now()),
        isFalse,
      );
    });

    test('toggle writes the full target amount', () async {
      final container = containerWith(MemoryHabitStore());
      await container.read(habitsProvider.future);
      final controller = container.read(habitsProvider.notifier);
      const habitId = 'h_workout'; // target 30, open today

      await controller.toggle(habitId);
      expect(
        container.read(habitsProvider).value!.amountFor(habitId, DateTime.now()),
        30,
      );
    });

    test('amounts survive a round-trip through the store', () async {
      final store = MemoryHabitStore();
      final container = containerWith(store);
      await container.read(habitsProvider.future);
      await container.read(habitsProvider.notifier).setAmount('h_read', 7);

      final reloaded = await HabitRepository(store, seeder: seedSnapshot)
          .load(now: DateTime.now());
      expect(reloaded.amountFor('h_read', DateTime.now()), 7);
    });

    test('best run is the longest complete stretch of scheduled days', () async {
      final habit = _habit();
      final done = {
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 6),
      };
      final best = bestRunFor(habit, done, today: DateTime(2026, 10, 6));
      expect(best.length, 3);
      expect(best.endedOn, DateTime(2026, 10, 3));
    });

    test('a missed scheduled day breaks the best run', () async {
      final habit = _habit();
      final done = {
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 4),
      };
      final best = bestRunFor(habit, done, today: DateTime(2026, 10, 4));
      expect(best.length, 2);
    });

    test('the month grid starts on the right weekday and marks today',
        () async {
      final container = containerWith(MemoryHabitStore());
      await container.read(habitsProvider.future);
      container.read(selectedHabitIdProvider.notifier).state = 'h_read';

      final detail = container.read(habitDetailProvider)!;
      final today = DateTime.now();
      final firstWeekday = DateTime(today.year, today.month, 1).weekday;
      expect(detail.monthStartOffset, firstWeekday - 1);
      expect(detail.monthDays.length,
          DateTime(today.year, today.month + 1, 0).day);
      expect(detail.monthDays.where((d) => d.isToday).length, 1);
      expect(detail.monthLabel, monthName(today.month));
    });

    test('digit grouping and empty details', () async {
      expect(groupDigits(1420), '1,420');
      expect(groupDigits(51), '51');
      expect(groupDigits(0), '0');

      final container = ProviderContainer(
        overrides: [
          habitStoreProvider.overrideWithValue(MemoryHabitStore()),
          demoModeProvider.overrideWithValue(DemoMode.none),
        ],
      );
      addTearDown(container.dispose);
      await container.read(habitsProvider.future);
      expect(container.read(detailsHabitProvider), isNull);
      expect(container.read(habitDetailProvider), isNull);
    });
  });
}
