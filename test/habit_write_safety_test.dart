import 'dart:async';
import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/data/repositories/habit_repository.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledStore implements HabitStore {
  ControlledStore(this.data);
  Map<String, dynamic>? data;
  bool failNext = false;
  Completer<void>? gate;
  final started = <Completer<void>>[];
  @override Future<Map<String, dynamic>?> read() async => data;
  @override Future<void> clear() async => data = null;
  @override Future<void> write(Map<String, dynamic> value) async {
    if (started.isNotEmpty) started.removeAt(0).complete();
    if (gate != null) { final waiting = gate!; gate = null; await waiting.future; }
    if (failNext) { failNext = false; throw StateError('simulated failure'); }
    data = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final habit = Habit(id: 'a', title: 'Read', targetAmount: 10, createdAt: DateTime.now());
  HabitsSnapshot snapshot() => HabitsSnapshot(habits: [habit], log: const {});

  test('failed add, progress and deletion remain unchanged and next write works', () async {
    final store = ControlledStore(snapshot().toJson());
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(store)]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    final controller = c.read(habitsProvider.notifier);
    store.failNext = true;
    await expectLater(controller.addHabit(Habit(id: 'b', title: 'Water', createdAt: DateTime.now())), throwsStateError);
    expect(c.read(habitsProvider).value!.habits.map((h) => h.id), ['a']);
    store.failNext = true;
    await expectLater(controller.setAmount('a', 5), throwsStateError);
    expect(c.read(habitsProvider).value!.amountFor('a', DateTime.now()), 0);
    store.failNext = true;
    await expectLater(controller.deleteHabit('a'), throwsStateError);
    expect(c.read(habitsProvider).value!.habitById('a'), isNotNull);
    expect(c.read(habitSaveFailureProvider), 3);
    await controller.setAmount('a', 5);
    expect(c.read(habitsProvider).value!.amountFor('a', DateTime.now()), 5);
    expect(HabitsSnapshot.fromJson(store.data!).amountFor('a', DateTime.now()), 5);
  });

  test('rapid additions to progress are serialized and based on saved state', () async {
    final store = ControlledStore(snapshot().toJson());
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(store)]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    final controller = c.read(habitsProvider.notifier);
    final firstStarted = Completer<void>();
    final hold = Completer<void>();
    store.started.add(firstStarted);
    store.gate = hold;
    final first = controller.stepAmount('a', 2);
    await firstStarted.future;
    final second = controller.stepAmount('a', 3);
    expect(c.read(habitsProvider).value!.amountFor('a', DateTime.now()), 0);
    hold.complete();
    await Future.wait([first, second]);
    expect(c.read(habitsProvider).value!.amountFor('a', DateTime.now()), 5);
    expect(HabitsSnapshot.fromJson(store.data!).amountFor('a', DateTime.now()), 5);
  });

  test('failure followed by queued change uses the last successfully saved state', () async {
    final store = ControlledStore(snapshot().toJson());
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(store)]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    final controller = c.read(habitsProvider.notifier);
    final started = Completer<void>();
    final hold = Completer<void>();
    store.started.add(started);
    store.gate = hold;
    store.failNext = true;
    final first = controller.stepAmount('a', 2);
    final failed = expectLater(first, throwsStateError);
    await started.future;
    final second = controller.stepAmount('a', 3);
    hold.complete();
    await failed;
    await second;
    expect(c.read(habitsProvider).value!.amountFor('a', DateTime.now()), 3);
    expect(HabitsSnapshot.fromJson(store.data!).amountFor('a', DateTime.now()), 3);
  });

  test('reload waits for an in-flight habit write', () async {
    final store = ControlledStore(snapshot().toJson());
    final c = ProviderContainer(overrides: [habitStoreProvider.overrideWithValue(store)]);
    addTearDown(c.dispose);
    await c.read(habitsProvider.future);
    final controller = c.read(habitsProvider.notifier);
    final started = Completer<void>();
    final hold = Completer<void>();
    store.started.add(started);
    store.gate = hold;
    final first = controller.stepAmount('a', 2);
    await started.future;
    final reload = controller.reload();
    // Queue the second mutation while reload is waiting on the first write.
    final second = controller.stepAmount('a', 3);
    hold.complete();
    await Future.wait([first, reload, second]);
    expect(c.read(habitsProvider).value!.amountFor('a', DateTime.now()), 5);
    expect(HabitsSnapshot.fromJson(store.data!).amountFor('a', DateTime.now()), 5);
  });

}
