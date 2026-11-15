import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LOGIC layer — the app language, persisted locally.
class LocaleController extends Notifier<Locale> {
  static const _kLocale = 'ds_locale';

  @override
  Locale build() {
    Future.microtask(_load);
    return const Locale('en');
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocale);
    if (code != null && code.isNotEmpty) state = Locale(code);
  }

  Future<void> setLanguage(String code) async {
    state = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, code);
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
