import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/state/completion_feedback_provider.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeFeedback implements CompletionFeedback {
  int count = 0;
  @override
  Future<void> play() async { count++; }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('feedback only on crossing today goal; setting disables both', () async {
    SharedPreferences.setMockInitialValues({});
    final feedback = FakeFeedback();
    final c = ProviderContainer(overrides: [
      habitStoreProvider.overrideWithValue(MemoryHabitStore()),
      completionFeedbackProvider.overrideWithValue(feedback),
    ]);
    addTearDown(c.dispose);
    c.read(settingsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 25));
    await c.read(habitsProvider.future);
    final h = Habit(id: 'a', title: 'Read', targetAmount: 10, createdAt: DateTime.now().subtract(const Duration(days: 4)));
    final controller = c.read(habitsProvider.notifier);
    await controller.addHabit(h);
    await controller.setAmount('a', 5);
    expect(feedback.count, 0);
    await controller.setAmount('a', 10);
    expect(feedback.count, 1);
    await controller.setAmount('a', 10);
    expect(feedback.count, 1);
    await controller.setAmount('a', 0);
    expect(feedback.count, 1);
    await controller.setAmount('a', 10, day: DateTime.now().subtract(const Duration(days: 1)));
    expect(feedback.count, 1);
    await c.read(settingsProvider.notifier).setSound(false);
    await controller.setAmount('a', 10);
    expect(feedback.count, 1);
    await controller.setAmount('a', 0);
    await c.read(settingsProvider.notifier).setSound(true);
    await controller.toggle('a');
    expect(feedback.count, 2);
  });
}
