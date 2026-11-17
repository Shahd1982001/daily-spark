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
  testWidgets('lifting and releasing lands sadly; a tap comforts, even with reduced motion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(MemoryHabitStore())]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    await tester.pumpWidget(UncontrolledProviderScope(container: c,
      child: SparkThemeScope(palette: SparkPalette.light,
        child: const MaterialApp(home: MediaQuery(data: MediaQueryData(size: Size(390, 844), disableAnimations: true),
          child: Scaffold(body: SparkPet()))))));
    await tester.pump(const Duration(milliseconds: 100));
    final before = tester.getCenter(find.byType(SparkMascot));
    await tester.drag(find.byType(SparkMascot), const Offset(0, -180));
    await tester.pump();
    expect(tester.getCenter(find.byType(SparkMascot)).dy, closeTo(before.dy, 1));
    expect(tester.widget<SparkMascot>(find.byType(SparkMascot)).concerned, isTrue);
    await tester.tap(find.byType(SparkMascot));
    await tester.pump();
    expect(tester.widget<SparkMascot>(find.byType(SparkMascot)).celebrating, isTrue);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('frame sequences advance from wave to walking and idle turn', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(MemoryHabitStore())]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    await tester.pumpWidget(UncontrolledProviderScope(container: c,
      child: SparkThemeScope(palette: SparkPalette.light,
        child: const MaterialApp(home: Scaffold(body: SparkPet())))));
    await tester.pump(const Duration(milliseconds: 700));
    bool frame(String name) => tester.widgetList<Image>(find.byType(Image)).any((image) =>
      image.image is AssetImage && (image.image as AssetImage).assetName.endsWith('/$name.png'));
    expect(frame('wave_mid') || frame('wave_alt'), isTrue);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widgetList<Image>(find.byType(Image)).any((image) => image.image is AssetImage && (image.image as AssetImage).assetName.contains('/walk_cycle_')), isTrue);
    final seenFrames = <String>{};
    for (var i = 0; i < 18; i++) {
      await tester.pump(const Duration(milliseconds: 80));
      for (final image in tester.widgetList<Image>(find.byType(Image))) {
        if (image.image is AssetImage) {
          final path = (image.image as AssetImage).assetName;
          if (path.contains('/walk_cycle_')) seenFrames.add(path);
        }
      }
    }
    expect(seenFrames.length, 16);
    var sawBack = false, sawJump = false, sawHeart = false;
    for (var i = 0; i < 110; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      sawJump = sawJump || frame('jump');
      sawBack = sawBack || frame('back');
      sawHeart = sawHeart || frame('heart');
    }
    expect(sawJump && sawBack && sawHeart, isTrue);
  });

}
