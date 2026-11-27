import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/screens/add_habit/add_habit_screen.dart';
import 'package:daily_spark/screens/habits/habits_screen.dart';
import 'package:daily_spark/l10n/habit_translation.dart';
import 'package:http/http.dart' as http;
import 'package:daily_spark/state/add_habit_providers.dart';
import 'package:daily_spark/state/habit_providers.dart';

class SlowMemoryHabitStore extends MemoryHabitStore {
  Completer<void>? hold;
  bool failNext = false;
  @override
  Future<void> write(Map<String, dynamic> data) async {
    final pending = hold;
    if (pending != null) await pending.future;
    if (failNext) {
      failNext = false;
      throw StateError('simulated storage failure');
    }
    await super.write(data);
  }
}

/// Taps through the form the way a person would, so the wiring between the
/// widgets and the draft controller is covered end to end.
void main() {
  late SlowMemoryHabitStore store;
  late ProviderContainer container;

  Future<void> pumpForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    store = SlowMemoryHabitStore();
    container = ProviderContainer(
      overrides: [
        habitStoreProvider.overrideWithValue(store),
        demoModeProvider.overrideWithValue(DemoMode.none),
      ],
    );
    addTearDown(container.dispose);
    await container.read(habitsProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: SparkThemeScope(
          palette: SparkPalette.light,
          child: const MaterialApp(home: AddHabitScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the CTA stays inert until the ritual has a name',
      (tester) async {
    await pumpForm(tester);

    await tester.tap(find.text('Ignite This Habit'));
    await tester.pumpAndSettle();

    expect(container.read(habitsProvider).value!.habits, isEmpty);
  });

  testWidgets('typing a title and igniting stores a real habit',
      (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextField).first, 'Morning Walk');
    await tester.pumpAndSettle();
    expect(container.read(habitDraftProvider).title, 'Morning Walk');

    await tester.tap(find.text('Ignite This Habit'));
    await tester.pumpAndSettle();

    final habits = container.read(habitsProvider).value!.habits;
    expect(habits, hasLength(1));
    expect(habits.single.title, 'Morning Walk');
    expect(container.read(todayHabitsProvider), hasLength(1));
  });

  testWidgets('symbol, rhythm and dosage chips all write to the draft',
      (tester) async {
    await pumpForm(tester);

    await tester.tap(find.text('Weekends'));
    await tester.pumpAndSettle();
    expect(container.read(habitDraftProvider).days, {6, 7});

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    expect(container.read(habitDraftProvider).rhythm, HabitRhythm.custom);

    await tester.tap(find.text('10 pages'));
    await tester.pumpAndSettle();
    expect(container.read(habitDraftProvider).targetAmount, 10);

    // Picking the water symbol swaps the unit and its presets.
    await tester.tap(find.byIcon(Icons.water_drop_outlined).first);
    await tester.pumpAndSettle();
    expect(container.read(habitDraftProvider).unit, 'ml');
    expect(find.text('1000 ml'), findsOneWidget);
  });

  testWidgets('changing unit warns and cancel keeps current progress', (tester) async {
    await pumpForm(tester);
    await tester.enterText(find.byType(TextField).first, 'Read');
    await tester.tap(find.text('Ignite This Habit'));
    await tester.pumpAndSettle();
    final habit = container.read(habitsProvider).value!.habits.single;
    await container.read(habitsProvider.notifier).setAmount(habit.id, 10);
    container.read(editingHabitIdProvider.notifier).state = habit.id;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: SparkThemeScope(palette: SparkPalette.light,
        child: MaterialApp(home: AddHabitScreen(key: ValueKey(habit.id)))),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.water_drop_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Change goal unit?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(container.read(habitsProvider).value!.amountFor(habit.id, DateTime.now()), 10);
    expect(container.read(habitsProvider).value!.habitById(habit.id)!.targetUnit, 'pages');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(container.read(habitsProvider).value!.amountFor(habit.id, DateTime.now()), 0);
    expect(container.read(habitsProvider).value!.habitById(habit.id)!.targetUnit, 'ml');
  });

  testWidgets('edit mode prefills the form and saves in place',
      (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextField).first, 'Journal');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ignite This Habit'));
    await tester.pumpAndSettle();

    final saved = container.read(habitsProvider).value!.habits.single;

    container.read(editingHabitIdProvider.notifier).state = saved.id;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: SparkThemeScope(
          palette: SparkPalette.light,
          child: MaterialApp(
            home: AddHabitScreen(key: ValueKey(saved.id)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Habit'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Evening Journal');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    final habits = container.read(habitsProvider).value!.habits;
    expect(habits, hasLength(1));
    expect(habits.single.title, 'Evening Journal');
  });

  testWidgets('edited habit replaces old card immediately and after reload',
      (tester) async {
    HabitTranslation.clearCache();
    HabitTranslation.request = (_) async => throw Exception('offline');
    addTearDown(() {
      HabitTranslation.request = http.get;
      HabitTranslation.clearCache();
    });
    await pumpForm(tester);
    await tester.enterText(find.byType(TextField).first, 'Original habit');
    await tester.tap(find.text('Ignite This Habit'));
    await tester.pumpAndSettle();
    final id = container.read(habitsProvider).value!.habits.single.id;
    container.read(editingHabitIdProvider.notifier).state = id;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: SparkThemeScope(palette: SparkPalette.light,
        child: MaterialApp(home: AddHabitScreen(key: ValueKey(id)))),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Edited habit');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: SparkThemeScope(palette: SparkPalette.light,
        child: const MaterialApp(home: HabitsScreen())),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Original habit'), findsNothing);
    expect(find.text('Edited habit'), findsOneWidget);
    expect(container.read(habitsProvider).value!.habits.single.id, id);
    await container.read(habitsProvider.notifier).reload();
    await tester.pumpAndSettle();
    expect(find.text('Original habit'), findsNothing);
    expect(find.text('Edited habit'), findsOneWidget);
    expect(container.read(habitsProvider).value!.habits.single.id, id);
  });


  testWidgets('repeated taps while a new habit saves create only one habit', (tester) async {
    await pumpForm(tester);
    await tester.enterText(find.byType(TextField).first, 'One habit');
    final gate = Completer<void>();
    store.hold = gate;
    await tester.tap(find.text('Ignite This Habit'));
    await tester.pump();
    await tester.tap(find.text('Ignite This Habit'));
    await tester.pump();
    gate.complete();
    await tester.pumpAndSettle();
    expect(container.read(habitsProvider).value!.habits, hasLength(1));
  });


  testWidgets('failed save keeps the draft and allows retry', (tester) async {
    await pumpForm(tester);
    await tester.enterText(find.byType(TextField).first, 'Retry habit');
    store.failNext = true;
    await tester.tap(find.text('Ignite This Habit'));
    await tester.pumpAndSettle();
    expect(container.read(habitsProvider).value!.habits, isEmpty);
    expect(container.read(habitDraftProvider).title, 'Retry habit');
    await tester.tap(find.text('Ignite This Habit'));
    await tester.pumpAndSettle();
    expect(container.read(habitsProvider).value!.habits.single.title, 'Retry habit');
  });

}
