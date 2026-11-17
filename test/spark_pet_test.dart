import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/day.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/design_system/widgets/spark_mascot.dart';
import 'package:daily_spark/design_system/widgets/spark_pet.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/spark_pet_provider.dart';
import 'package:daily_spark/state/spark_treats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('original mascot stays the same size and still; tapping comforts', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(MemoryHabitStore())]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    final today = dayOnly(DateTime.now());
    await c.read(habitsProvider.notifier).addHabit(Habit(id: 'a', title: 'Read', createdAt: addCalendarDays(today, -2)));
    await tester.pumpWidget(UncontrolledProviderScope(container: c,
      child: SparkThemeScope(palette: SparkPalette.light, child: const MaterialApp(home: Scaffold(body: SparkPet())))));
    await tester.pump(const Duration(milliseconds: 100));
    final mascot = find.byType(SparkMascot);
    final pos = tester.getTopLeft(mascot), size = tester.getSize(mascot);
    final image = tester.widget<Image>(find.descendant(of: mascot, matching: find.byType(Image)));
    expect((image.image as AssetImage).assetName, 'assets/mascot/spark.png');
    await tester.pump(const Duration(seconds: 10));
    expect(tester.getTopLeft(mascot), pos);
    expect(tester.getSize(mascot), size);
    await tester.tap(mascot);
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.read(sparkPetMoodProvider).calmedDay, dayKey(addCalendarDays(today, -1)));
    expect(c.read(habitsProvider).value!.isCompleted('a', addCalendarDays(today, -1)), isFalse);
    await tester.pump(const Duration(seconds: 5));
  });
  testWidgets('treats stay available and can still be fed', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(MemoryHabitStore())]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    await c.read(sparkTreatsProvider.notifier).award('a', '2026-01-01');
    await tester.pumpWidget(UncontrolledProviderScope(container: c,
      child: SparkThemeScope(palette: SparkPalette.light, child: const MaterialApp(home: Scaffold(body: SparkPet())))));
    await tester.pump();
    expect(c.read(sparkTreatsProvider).items.length, 1);
    await tester.tap(find.byType(SparkMascot));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.read(sparkTreatsProvider).items, isEmpty);
    await tester.pump(const Duration(seconds: 5));
  });
}
