import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/l10n/strings.dart';
import 'package:daily_spark/screens/add_habit/add_habit_screen.dart';
import 'package:daily_spark/screens/profile/widgets/settings_group.dart';
import 'package:daily_spark/state/add_habit_providers.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final language in ['en', 'ar']) {
    testWidgets('settings subtitle wraps before the switch ($language)', (tester) async {
      Strings.locale = Locale(language);
      addTearDown(() => Strings.locale = const Locale('en'));
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const subtitle = 'Sound and vibration when you complete a habit';
      await tester.pumpWidget(SparkThemeScope(palette: SparkPalette.darkPalette,
        child: MaterialApp(home: Scaffold(body: Directionality(
          textDirection: language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: const SettingsRow(scale: .86, icon: Icons.vibration_rounded,
            title: 'Sound & Haptic Spark', subtitle: subtitle, switchValue: true),
        ))),
      ));
      final text = tester.getRect(find.text(tr(subtitle)));
      final switchBox = tester.getRect(find.byWidgetPredicate((w) =>
          w is Semantics && w.properties.label == tr('Sound & Haptic Spark')));
      expect(text.overlaps(switchBox), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dark identity icon is visible outside the raised text well and selectable', (tester) async {
    SparkPalette.active = SparkPalette.darkPalette;
    addTearDown(() => SparkPalette.active = SparkPalette.light);
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(MemoryHabitStore())]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    await tester.pumpWidget(UncontrolledProviderScope(container: c,
      child: SparkThemeScope(palette: SparkPalette.darkPalette,
        child: const MaterialApp(home: AddHabitScreen()))));
    await tester.pumpAndSettle();
    final iconRect = tester.getRect(find.byIcon(Icons.menu_book_outlined).first);
    final textRect = tester.getRect(find.byType(TextField).first);
    expect(iconRect.overlaps(textRect), isFalse);
    final well = find.byWidgetPredicate((w) => w is Container &&
        w.decoration is BoxDecoration && (w.decoration as BoxDecoration).color == SparkPalette.darkPalette.raised);
    expect(well, findsWidgets);
    expect(tester.getRect(well.first).overlaps(iconRect), isFalse);
    await tester.tap(find.byIcon(Icons.water_drop_outlined).first);
    await tester.pumpAndSettle();
    expect(c.read(habitDraftProvider).unit, 'ml');
    expect(tester.takeException(), isNull);
  });
}
