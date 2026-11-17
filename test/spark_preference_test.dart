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

  testWidgets('blink uses registered frames and retains identical size', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SparkMascot(size: 76, blink: true)));
    await tester.pump();
    final before = tester.getSize(find.byType(Image));
    String asset() => (tester.widget<Image>(find.byType(Image)).image as AssetImage).assetName;
    expect(asset(), 'assets/mascot/spark.png');
    await tester.pump(const Duration(seconds: 3));
    expect(asset(), 'assets/mascot/blink/blink_1.png');
    await tester.pump(const Duration(milliseconds: 85));
    expect(asset(), 'assets/mascot/blink/blink_2.png');
    await tester.pump(const Duration(milliseconds: 85));
    expect(asset(), 'assets/mascot/blink/blink_3.png');
    expect(tester.getSize(find.byType(Image)), before);
    await tester.pump(const Duration(milliseconds: 85));
    expect(asset(), 'assets/mascot/blink/blink_2.png');
    await tester.pump(const Duration(milliseconds: 85));
    expect(asset(), 'assets/mascot/blink/blink_1.png');
    await tester.pump(const Duration(milliseconds: 85));
    expect(asset(), 'assets/mascot/spark.png');
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('reduced motion keeps original still', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MediaQuery(
      data: MediaQueryData(disableAnimations: true), child: SparkMascot(blink: true),
    )));
    await tester.pump(const Duration(seconds: 5));
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/mascot/spark.png');
    expect(tester.takeException(), isNull);
  });
}
