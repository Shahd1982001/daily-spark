import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/progress_providers.dart';
import 'package:daily_spark/state/settings_providers.dart';

/// Lets the async SharedPreferences load inside the controllers finish.
Future<void> _flush() async =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings & profile info', () {
    test('defaults: light theme, reminders and sound on, no name/motto', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(settingsProvider).themeMode, ThemeMode.light);
      expect(c.read(settingsProvider).remindersOn, isTrue);
      expect(c.read(settingsProvider).soundOn, isTrue);
      expect(c.read(profileInfoProvider).name, isNull);
      expect(c.read(userNameProvider), isNull);
      expect(c.read(userMottoProvider), isNull);
    });

    test('toggles persist across containers', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);
      await c1.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
      await c1.read(settingsProvider.notifier).setReminders(false);
      await c1.read(settingsProvider.notifier).setSound(false);

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(settingsProvider); // kick off the async load
      await _flush();
      expect(c2.read(settingsProvider).themeMode, ThemeMode.dark);
      expect(c2.read(settingsProvider).remindersOn, isFalse);
      expect(c2.read(settingsProvider).soundOn, isFalse);
    });

    test('name and motto persist and drive the greeting providers', () async {
      SharedPreferences.setMockInitialValues({});
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);
      await c1
          .read(profileInfoProvider.notifier)
          .set(name: 'Noor', motto: 'Rise with the sun');

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(profileInfoProvider);
      await _flush();
      expect(c2.read(userNameProvider), 'Noor');
      expect(c2.read(userMottoProvider), 'Rise with the sun');

      // Clearing falls back to no identity at all.
      await c2.read(profileInfoProvider.notifier).set();
      await _flush();
      expect(c2.read(userNameProvider), isNull);
      expect(c2.read(userMottoProvider), isNull);
    });

    test('demo mode seeds a name but a stored name wins', () async {
      SharedPreferences.setMockInitialValues({});
      final demo = ProviderContainer(
        overrides: [demoModeProvider.overrideWithValue(DemoMode.full)],
      );
      addTearDown(demo.dispose);
      demo.read(profileInfoProvider);
      await _flush();
      expect(demo.read(userNameProvider), 'Shahd');

      await demo.read(profileInfoProvider.notifier).set(name: 'Lina');
      await _flush();
      expect(demo.read(userNameProvider), 'Lina');
    });
  });
}
