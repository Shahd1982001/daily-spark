import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_providers.dart';

/// LOGIC layer — local-first accounts (no backend yet).
///
/// One account per device, stored in SharedPreferences exactly like the habit
/// store; swap this for the cloud backend later and nothing above changes.
/// The display name lives in `profileInfoProvider` so every screen keeps
/// reading one identity source.

enum AuthMode { none, guest, account }

class AuthState {
  const AuthState({this.mode = AuthMode.none, this.name, this.email});

  final AuthMode mode;
  final String? name;
  final String? email;

  bool get signedIn => mode != AuthMode.none;
}

// ── validation ─────────────────────────────────────────────────────────────

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateName(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Please enter your name';
  if (v.length < 2) return 'Name is too short';
  return null;
}

String? validateEmail(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Please enter your email';
  if (!_emailRe.hasMatch(v)) return 'That email does not look right';
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) return 'Please enter your password';
  if (value.length < 6) return 'Use at least 6 characters';
  return null;
}

// ── controller ─────────────────────────────────────────────────────────────

class AuthController extends Notifier<AuthState> {
  static const _kMode = 'ds_auth_mode';
  static const _kName = 'ds_auth_name';
  static const _kEmail = 'ds_auth_email';
  static const _kPass = 'ds_auth_pass';

  @override
  AuthState build() {
    Future.microtask(_load);
    return const AuthState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = switch (prefs.getString(_kMode)) {
      'guest' => const AuthState(mode: AuthMode.guest),
      'account' => AuthState(
          mode: AuthMode.account,
          name: prefs.getString(_kName),
          email: prefs.getString(_kEmail),
        ),
      _ => const AuthState(),
    };
  }

  /// Creates the local account. Returns an error message, or null on success.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final nameError = validateName(name);
    if (nameError != null) return nameError;
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;
    final passError = validatePassword(password);
    if (passError != null) return passError;
    if (password != confirmPassword) return 'The passwords do not match';

    final prefs = await SharedPreferences.getInstance();
    final cleanEmail = email.trim().toLowerCase();
    await prefs.setString(_kName, name.trim());
    await prefs.setString(_kEmail, cleanEmail);
    await prefs.setString(_kPass, password);
    await prefs.setString(_kMode, 'account');
    state = AuthState(
        mode: AuthMode.account, name: name.trim(), email: cleanEmail);
    // The account name becomes the identity shown across the app.
    await ref.read(profileInfoProvider.notifier).set(name: name.trim());
    return null;
  }

  /// Signs in to the account stored on this device.
  /// Returns an error message, or null on success.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanEmail = email.trim().toLowerCase();
    final storedEmail = prefs.getString(_kEmail);
    if (storedEmail == null) return 'No account on this device yet — create one first';
    if (storedEmail != cleanEmail) return 'That account is not on this device';
    if (prefs.getString(_kPass) != password) return 'Incorrect password';

    final name = prefs.getString(_kName);
    await prefs.setString(_kMode, 'account');
    state = AuthState(mode: AuthMode.account, name: name, email: cleanEmail);
    final info = ref.read(profileInfoProvider);
    if (info.name == null || info.name!.isEmpty) {
      await ref.read(profileInfoProvider.notifier).set(name: name, motto: info.motto);
    }
    return null;
  }

  Future<void> signInAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, 'guest');
    state = const AuthState(mode: AuthMode.guest);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, 'none');
    state = const AuthState();
    // The name belongs to the account; a signed-out user has none.
    final info = ref.read(profileInfoProvider);
    if (info.name != null) {
      await ref.read(profileInfoProvider.notifier).set(motto: info.motto);
    }
  }
}

final authProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
