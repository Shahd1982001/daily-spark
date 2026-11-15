import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LOGIC layer — user preferences, persisted locally (same storage gateway
/// idea as [HabitStore]: swap the SharedPreferences calls for a backend later).
///
/// These are real user prefs, not demo data: they persist in every mode.

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.remindersOn = true,
    this.soundOn = true,
    this.loaded = false,
  });

  final ThemeMode themeMode;
  final bool remindersOn;
  final bool soundOn;

  /// True once the persisted values have been read.
  final bool loaded;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? remindersOn,
    bool? soundOn,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        remindersOn: remindersOn ?? this.remindersOn,
        soundOn: soundOn ?? this.soundOn,
        loaded: true,
      );
}

class SettingsController extends Notifier<AppSettings> {
  static const _kTheme = 'ds_theme_mode';
  static const _kReminders = 'ds_reminders_on';
  static const _kSound = 'ds_sound_on';

  @override
  AppSettings build() {
    Future.microtask(_load);
    return const AppSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      themeMode: switch (prefs.getString(_kTheme)) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => state.themeMode,
      },
      remindersOn: prefs.getBool(_kReminders) ?? state.remindersOn,
      soundOn: prefs.getBool(_kSound) ?? state.soundOn,
      loaded: true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setReminders(bool value) async {
    state = state.copyWith(remindersOn: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminders, value);
  }

  Future<void> setSound(bool value) async {
    state = state.copyWith(soundOn: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSound, value);
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

/// The editable identity shown on Profile / Home greeting.
class ProfileInfo {
  const ProfileInfo({this.name, this.motto});

  /// Display name — `null` until the user sets one (no auth yet).
  final String? name;

  /// A short personal motto shown as the profile bio.
  final String? motto;

  ProfileInfo copyWith({String? name, String? motto}) => ProfileInfo(
        name: name,
        motto: motto,
      );
}

class ProfileInfoController extends Notifier<ProfileInfo> {
  static const _kName = 'ds_display_name';
  static const _kMotto = 'ds_motto';

  @override
  ProfileInfo build() {
    Future.microtask(_load);
    return const ProfileInfo();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = ProfileInfo(
      name: prefs.getString(_kName),
      motto: prefs.getString(_kMotto),
    );
  }

  Future<void> set({String? name, String? motto}) async {
    state = ProfileInfo(name: name, motto: motto);
    final prefs = await SharedPreferences.getInstance();
    if (name == null) {
      await prefs.remove(_kName);
    } else {
      await prefs.setString(_kName, name);
    }
    if (motto == null) {
      await prefs.remove(_kMotto);
    } else {
      await prefs.setString(_kMotto, motto);
    }
  }
}

final profileInfoProvider =
    NotifierProvider<ProfileInfoController, ProfileInfo>(
        ProfileInfoController.new);
