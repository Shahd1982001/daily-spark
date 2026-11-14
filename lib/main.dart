import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/preview/preview_shell.dart';
import 'package:daily_spark/state/habit_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        // Local-first storage: shared_preferences (localStorage on web).
        habitStoreProvider.overrideWithValue(PrefsHabitStore()),
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
    ref.watch(habitsProvider);
    return child;
  }
}
