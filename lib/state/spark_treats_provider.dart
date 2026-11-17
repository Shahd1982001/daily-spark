import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_providers.dart';

enum SparkTreat { cookie, cake }

class TreatInventory {
  const TreatInventory({this.items = const [], this.earned = const {}});
  final List<SparkTreat> items;
  final Set<String> earned;
}

/// One snack per habit/day on the first completion. FIFO inventory is stored
/// locally; demo mode gets a separate throw-away in-memory inventory.
class SparkTreatsController extends Notifier<TreatInventory> {
  static const key = 'ds_spark_treats_v1';
  final Random _random = Random();
  Future<void> _queue = Future.value();
  Future<void>? _loadFuture;
  late bool _demo;

  @override
  TreatInventory build() {
    _demo = ref.read(demoModeProvider) != DemoMode.none;
    Future.microtask(() => _ensureLoaded().catchError((Object _) {}));
    return const TreatInventory();
  }
  Future<void> _ensureLoaded() => _loadFuture ??= _load();
  Future<void> _load() async {
    if (_demo) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return;
    final json = jsonDecode(raw);
    if (json is! Map || json['items'] is! List || json['earned'] is! List) {
      throw const FormatException('Invalid Spark treats');
    }
    state = TreatInventory(
      items: (json['items'] as List).map((e) => SparkTreat.values.where((t) => t.name == e).firstOrNull).whereType<SparkTreat>().toList(),
      earned: (json['earned'] as List).whereType<String>().toSet(),
    );
  }
  Future<T> _serial<T>(Future<T> Function() work) {
    final result = _queue.then((_) async { await _ensureLoaded(); return work(); });
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }
  Future<void> _save(TreatInventory next) async {
    if (!_demo) {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode({'items': next.items.map((t) => t.name).toList(), 'earned': next.earned.toList()});
      if (!await prefs.setString(key, raw)) throw StateError('Could not save Spark treats');
    }
    state = next;
  }
  Future<SparkTreat?> award(String habitId, String day) => _serial(() async {
    final token = jsonEncode([habitId, day]);
    if (state.earned.contains(token)) return null;
    final treat = SparkTreat.values[_random.nextInt(SparkTreat.values.length)];
    await _save(TreatInventory(items: [...state.items, treat], earned: {...state.earned, token}));
    return treat;
  });
  Future<SparkTreat?> feed() => _serial(() async {
    if (state.items.isEmpty) return null;
    final treat = state.items.first;
    await _save(TreatInventory(items: state.items.skip(1).toList(), earned: state.earned));
    return treat;
  });
}

final sparkTreatsProvider = NotifierProvider<SparkTreatsController, TreatInventory>(SparkTreatsController.new);
