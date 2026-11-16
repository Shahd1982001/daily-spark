/// Date helpers shared by the data layer.
///
/// Everything is stored by *calendar day* (`yyyy-MM-dd`), never by timestamp,
/// so streaks and "today" math stay timezone-explicit and DST-proof.
library;

import 'package:daily_spark/l10n/strings.dart';

/// Truncates [value] to local midnight.
DateTime dayOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// Stable storage key for a calendar day: `2026-11-12`.
String dayKey(DateTime value) {
  final d = dayOnly(value);
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

/// Parses a [dayKey] back to local midnight (`null` when malformed).
DateTime? parseDayKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

/// Short label used by the UI: `3d`, `12d`, `1w`.
String shortRelativeDays(int days) {
  if (days < 14) return tr('{n}d', {'n': '$days'});
  if (days < 60) return tr('{n}w', {'n': '${(days / 7).floor()}'});
  return tr('{n}mo', {'n': '${(days / 30).floor()}'});
}
