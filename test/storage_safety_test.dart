import 'dart:async';
import 'package:daily_spark/data/local/habit_store.dart';
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/data/repositories/habit_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeldStore extends HabitStore {
  Map<String, dynamic>? data;
  final firstWrite = Completer<void>();
  final secondStarted = Completer<void>();
  int writes = 0;
  @override Future<Map<String,dynamic>?> read() async => data;
  @override Future<void> clear() async { data = null; }
  @override Future<void> write(Map<String,dynamic> input) async {
    writes++;
    if (writes == 1) { await firstWrite.future; }
    else { secondStarted.complete(); }
    data = input;
  }
}
class FailingOnceStore extends HabitStore {
  int calls = 0;
  Map<String, dynamic>? data;
  @override Future<Map<String, dynamic>?> read() async => data;
  @override Future<void> clear() async { data = null; }
  @override Future<void> write(Map<String, dynamic> value) async {
    calls++;
    if (calls == 1) throw StateError('simulated write failure');
    data = value;
  }
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('malformed local storage is reported and never overwritten with seed', () async {
    for (final raw in ['', '{oops', '[]', '{}']) {
      SharedPreferences.setMockInitialValues({PrefsHabitStore.storageKey: raw});
      final repo=HabitRepository(PrefsHabitStore());
      await expectLater(repo.load(), throwsA(isA<FormatException>()));
      final prefs=await SharedPreferences.getInstance();
      expect(prefs.getString(PrefsHabitStore.storageKey), raw);
    }
  });
  test('concurrent saves write in request order and reload sees latest', () async {
    final store=HeldStore();
    final repo=HabitRepository(store);
    HabitsSnapshot snapshot(String title) => HabitsSnapshot(habits: [Habit(
      id: 'a', title: title, createdAt: DateTime(2026))], log: const {});
    final first=repo.save(snapshot('first'));
    final second=repo.save(snapshot('second'));
    await Future<void>.delayed(Duration.zero);
    expect(store.writes, 1);
    expect(store.secondStarted.isCompleted, isFalse);
    final loading=repo.load();
    store.firstWrite.complete();
    await Future.wait([first,second]);
    expect((await loading).habits.single.title, 'second');
    expect(store.writes, 2);
  });
  test('a failed save is reported and a later save can still succeed', () async {
    final store = FailingOnceStore();
    final repo = HabitRepository(store);
    final snapshot = HabitsSnapshot(habits: [Habit(id: 'a', title: 'A', createdAt: DateTime(2026))], log: const {});
    await expectLater(repo.save(snapshot), throwsStateError);
    await repo.save(snapshot);
    expect((await repo.load()).habits.single.title, 'A');
  });

}
