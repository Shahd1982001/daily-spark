import 'package:daily_spark/design_system/widgets/spark_mascot.dart';
import 'package:daily_spark/state/spark_alert_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('choice is opt-in, stored locally and can be reversed', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ProviderContainer();
    addTearDown(first.dispose);
    final notifier = first.read(sparkAlertPreferenceProvider.notifier);
    expect((await notifier.load()).chosen, false);
    expect(first.read(sparkAlertPreferenceProvider).wanted, false);
    await notifier.choose(true);
    final second = ProviderContainer();
    addTearDown(second.dispose);
    final stored = await second.read(sparkAlertPreferenceProvider.notifier).load();
    expect(stored.chosen, true);
    expect(stored.wanted, true);
    await second.read(sparkAlertPreferenceProvider.notifier).choose(false);
    final third = ProviderContainer();
    addTearDown(third.dispose);
    final disabled = await third.read(sparkAlertPreferenceProvider.notifier).load();
    expect(disabled.chosen, true);
    expect(disabled.wanted, false);
  });

  testWidgets('mascot respects reduce-motion', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MediaQuery(
      data: MediaQueryData(disableAnimations: true),
      child: SparkMascot(animate: true),
    )));
    final before = tester.getTopLeft(find.byType(Image));
    await tester.pump(const Duration(milliseconds: 1000));
    final after = tester.getTopLeft(find.byType(Image));
    expect(before, after);
    expect(tester.takeException(), isNull);
  });
  testWidgets('mascot moves gently when animation is allowed', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SparkMascot(animate: true)));
    final before = tester.getTopLeft(find.byType(Image));
    await tester.pump(const Duration(milliseconds: 900));
    final after = tester.getTopLeft(find.byType(Image));
    expect(after.dy, lessThan(before.dy));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
