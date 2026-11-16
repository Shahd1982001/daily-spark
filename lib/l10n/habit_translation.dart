import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Translates only habit titles, never account information or other fields.
/// Original titles remain in the local habit store; this is display-only.
class HabitTranslation {
  HabitTranslation._();

  static final Map<String, Future<String>> _pending = {};
  static final Map<String, String> _cache = {};
  static final Map<String, DateTime> _retryAfter = {};
  static const _languages = {'en', 'ar', 'fr', 'es', 'ru', 'zh'};

  /// Replaced by a deterministic fake in tests.
  static Future<http.Response> Function(Uri) request = http.get;

  static void clearCache() {
    _pending.clear();
    _cache.clear();
    _retryAfter.clear();
  }

  static Future<String> translate(String original, String target) {
    if (original.trim().isEmpty || !_languages.contains(target)) {
      return Future.value(original);
    }
    final key = '$target\u0000$original';
    final cached = _cache[key];
    if (cached != null) return Future.value(cached);
    if ((_retryAfter[key] ?? DateTime(1970)).isAfter(DateTime.now())) {
      return Future.value(original);
    }
    return _pending.putIfAbsent(key, () async {
      try {
        final uri = Uri.https('clients5.google.com', '/translate_a/t', {
          'client': 'dict-chrome-ex',
          'sl': 'auto',
          'tl': target,
          'q': original,
        });
        final response = await request(uri).timeout(const Duration(seconds: 8));
        if (response.statusCode != 200) throw StateError('Translation failed');
        final result = jsonDecode(utf8.decode(response.bodyBytes));
        // With language auto-detection the service returns [[text, language]].
        final value = result is List && result.isNotEmpty && result.first is List
            ? (result.first as List).first
            : result is List && result.isNotEmpty
                ? result.first
                : result;
        if (value is! String || value.trim().isEmpty) {
          throw const FormatException('Invalid translation response');
        }
        _cache[key] = value;
        return value;
      } catch (_) {
        // Network/quota/provider failures never block the task or alter its data.
        _retryAfter[key] = DateTime.now().add(const Duration(minutes: 1));
        return original;
      } finally {
        _pending.remove(key);
      }
    });
  }
}
