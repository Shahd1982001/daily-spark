import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Storage gateway: the only place that knows where the bytes live.
///
/// Swap this implementation for a backend-backed one later — nothing above
/// this layer changes.
abstract class HabitStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> data);

  Future<void> clear();
}

/// Local-first implementation backed by `shared_preferences`
/// (localStorage on web, NSUserDefaults / SharedPreferences on device).
class PrefsHabitStore implements HabitStore {
  PrefsHabitStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const String storageKey = 'daily_spark.snapshot.v1';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<Map<String, dynamic>?> read() async {
    final prefs = await _instance;
    final raw = prefs.getString(storageKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Stored habit data is not a JSON object');
    }
    return decoded.cast<String, dynamic>();
  }

  @override
  Future<void> write(Map<String, dynamic> data) async {
    final prefs = await _instance;
    if (!await prefs.setString(storageKey, jsonEncode(data))) {
      throw StateError('Unable to save habit data');
    }
  }

  @override
  Future<void> clear() async {
    final prefs = await _instance;
    await prefs.remove(storageKey);
  }
}

/// Test double — keeps the payload in memory.
class MemoryHabitStore implements HabitStore {
  MemoryHabitStore([this._data]);

  Map<String, dynamic>? _data;

  int writes = 0;

  @override
  Future<Map<String, dynamic>?> read() async => _data;

  @override
  Future<void> write(Map<String, dynamic> data) async {
    _data = data;
    writes++;
  }

  @override
  Future<void> clear() async {
    _data = null;
  }
}
