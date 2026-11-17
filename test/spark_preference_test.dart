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

  testWidgets('original mascot stays still with or without reduced motion', (tester) async {
    for (final reduced in [true, false]) {
      await tester.pumpWidget(MaterialApp(home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced), child: const SparkMascot(),
      )));
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, 'assets/mascot/spark.png');
      final before = tester.getTopLeft(find.byType(Image));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.getTopLeft(find.byType(Image)), before);
    }
    expect(tester.takeException(), isNull);
  });
}
