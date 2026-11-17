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
    final finder = find.byWidgetPredicate((w) => w is Image &&
        w.image is AssetImage && (w.image as AssetImage).assetName.endsWith('happy_left_arm.png'));
    expect(finder, findsOneWidget);
    final transforms = find.ancestor(of: finder, matching: find.byType(Transform));
    final before = tester.widget<Transform>(transforms.first).transform.clone();
    await tester.pump(const Duration(milliseconds: 800));
    final after = tester.widget<Transform>(transforms.first).transform;
    expect(after, isNot(before));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
  testWidgets('Spark blinks and animates separate limbs with concerned artwork', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SparkMascot(animate: true, concerned: true)));
    await tester.pump();
    final arm = find.byWidgetPredicate((w) => w is Image && w.image is AssetImage &&
      (w.image as AssetImage).assetName.endsWith('concerned_right_arm.png'));
    expect(arm, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2400));
    final closed = find.byWidgetPredicate((w) => w is Image && w.image is AssetImage &&
      (w.image as AssetImage).assetName.endsWith('concerned_body_closed.png'));
    expect(closed, findsOneWidget);
    final opacity = tester.widget<Opacity>(find.ancestor(of: closed, matching: find.byType(Opacity)).first);
    expect(opacity.opacity, greaterThan(.9));
    await tester.pumpWidget(const SizedBox.shrink());
  });

}
