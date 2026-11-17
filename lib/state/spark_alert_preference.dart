import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saved opt-in for planned Spark late alerts. It does not schedule alerts or
/// request OS permission yet. The character remains visible either way.
class SparkAlertPreference {
  const SparkAlertPreference({this.wanted = false, this.chosen = false});
  final bool wanted;
  final bool chosen;
}

class SparkAlertController extends Notifier<SparkAlertPreference> {
  static const _choice = 'ds_spark_late_alerts_wanted_v1';
  static const _chosen = 'ds_spark_late_alerts_chosen_v1';
  int _revision = 0;

  @override
  SparkAlertPreference build() {
    Future.microtask(load);
    return const SparkAlertPreference();
  }

  Future<SparkAlertPreference> load() async {
    final revision = _revision;
    final prefs = await SharedPreferences.getInstance();
    final loaded = SparkAlertPreference(
        wanted: prefs.getBool(_choice) ?? false,
        chosen: prefs.getBool(_chosen) ?? false);
    if (_revision == revision) state = loaded;
    return _revision == revision ? loaded : state;
  }

  Future<void> choose(bool wanted) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setBool(_choice, wanted)) throw StateError('Could not save choice');
    if (!await prefs.setBool(_chosen, true)) throw StateError('Could not save choice');
    _revision++;
    state = SparkAlertPreference(wanted: wanted, chosen: true);
  }
}

final sparkAlertPreferenceProvider = NotifierProvider<SparkAlertController, SparkAlertPreference>(SparkAlertController.new);
