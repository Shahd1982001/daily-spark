import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/day.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/design_system/widgets/spark_mascot.dart';
import 'package:daily_spark/design_system/widgets/spark_pet.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/spark_pet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('pet can be dragged and comforted without marking habit complete', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c=ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(MemoryHabitStore())]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    final today=dayOnly(DateTime.now());
    await c.read(habitsProvider.notifier).addHabit(Habit(id:'a', title:'Read', createdAt:addCalendarDays(today,-2)));
    await tester.pumpWidget(UncontrolledProviderScope(container:c,
      child: SparkThemeScope(palette:SparkPalette.light,
        child: const MaterialApp(home: MediaQuery(data: MediaQueryData(size: Size(390,844), disableAnimations:true),
          child: Scaffold(body: SparkPet()))))));
    await tester.pump(const Duration(milliseconds:100));
    await tester.pump(const Duration(milliseconds:100));
    expect(tester.widget<SparkMascot>(find.byType(SparkMascot)).concerned, isTrue);
    final before=tester.getCenter(find.byType(SparkMascot));
    await tester.drag(find.byType(SparkMascot), const Offset(-90, 30));
    await tester.pump();
    final after=tester.getCenter(find.byType(SparkMascot));
    expect(after.dx, lessThan(before.dx - 60));
    await tester.tap(find.byType(SparkMascot));
    await tester.pump(const Duration(milliseconds:100));
    expect(tester.widget<SparkMascot>(find.byType(SparkMascot)).celebrating, isTrue);
    expect(c.read(habitsProvider).value!.isCompleted('a', addCalendarDays(today,-1)), isFalse);
    expect(c.read(sparkPetMoodProvider).calmedDay, dayKey(addCalendarDays(today,-1)));
    await tester.pump(const Duration(seconds:5));
    expect(tester.widget<SparkMascot>(find.byType(SparkMascot)).concerned, isFalse);
    expect(tester.takeException(), isNull);
  });
}
