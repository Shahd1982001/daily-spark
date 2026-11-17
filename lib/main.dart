import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/preview/preview_shell.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/locale_providers.dart';
import 'package:daily_spark/l10n/strings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // `?demo=1` opens the design data set for review in a throw-away in-memory
  // store — it never touches the user's real data. A normal launch starts
  // empty and everything the user adds is persisted locally.
  final demo = switch (Uri.base.queryParameters['demo']) {
    '1' || 'full' => DemoMode.full,
    'small' => DemoMode.small,
    _ => DemoMode.none,
  };
  final isDemo = demo != DemoMode.none;

  runApp(
    ProviderScope(
      overrides: [
        habitStoreProvider
            .overrideWithValue(isDemo ? MemoryHabitStore() : PrefsHabitStore()),
        demoModeProvider.overrideWithValue(demo),
      ],
      child: const _AppBootstrap(child: PreviewShell()),
    ),
  );
}

/// Loads the persisted snapshot once at startup so the first screen that opens
/// already has data (and the first run seeds the store).
class _AppBootstrap extends ConsumerWidget {
  const _AppBootstrap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    if (habits.hasError) {
      final locale = ref.watch(localeProvider);
      Strings.locale = locale;
      return MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        home: Scaffold(
          backgroundColor: const Color(0xFFFAF8F5),
          body: SafeArea(child: Center(child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: Color(0xFFEC7440)),
              const SizedBox(height: 18),
              Text(tr('Your habits could not be loaded'), textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(tr('Your saved data has not been erased. Please try again.'),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => ref.read(habitsProvider.notifier).reload(),
                  child: Text(tr('Try again'))),
            ]),
          ))),
        ),
      );
    }
    return child;
  }
}
