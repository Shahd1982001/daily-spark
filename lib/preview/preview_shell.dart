import 'dart:convert';
import 'package:daily_spark/data/services/reminder_notifications.dart';
import 'package:daily_spark/data/services/reminder_plan.dart';
import 'package:daily_spark/state/avatar_provider.dart';
import 'package:daily_spark/state/mascot_providers.dart';
import 'package:daily_spark/state/spark_alert_preference.dart';
import 'package:daily_spark/design_system/widgets/spark_mascot.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:image_picker/image_picker.dart';
import 'package:daily_spark/state/calendar_day_provider.dart';
import 'package:daily_spark/l10n/habit_sentence.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_spark/design_system/theme/app_theme.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/screens/onboarding/onboarding_screen.dart';
import 'package:daily_spark/screens/splash/splash_screen.dart';
import 'package:daily_spark/screens/add_habit/add_habit_screen.dart';
import 'package:daily_spark/screens/habit_details/habit_details_screen.dart';
import 'package:daily_spark/screens/habits/habits_screen.dart';
import 'package:daily_spark/screens/home/home_screen.dart';
import 'package:daily_spark/screens/login/login_screen.dart';
import 'package:daily_spark/screens/profile/profile_screen.dart';
import 'package:daily_spark/screens/progress/progress_screen.dart';
import 'package:daily_spark/screens/sign_up/sign_up_screen.dart';
import 'package:daily_spark/screens/welcome/welcome_screen.dart';
import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/state/add_habit_providers.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/details_providers.dart';
import 'package:daily_spark/state/progress_providers.dart';
import 'package:daily_spark/state/settings_providers.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:daily_spark/l10n/strings.dart';
import 'package:daily_spark/state/auth_providers.dart';
import 'package:daily_spark/state/locale_providers.dart';

/// ⚠️ TEMPORARY PREVIEW SHELL — scaffolding only, zero business logic.
///
/// It shows the pure design screens exactly as drawn in Figma (no dev bar,
/// no overlay of any kind). Screens are reachable by URL while we review:
///
///   /?s=onboarding&p=2   → onboarding page 2
///   /?s=welcome          → welcome screen
///
/// This shell will be replaced by the real app router later.
class PreviewShell extends ConsumerStatefulWidget {
  const PreviewShell({super.key});

  @override
  ConsumerState<PreviewShell> createState() => _PreviewShellState();
}

enum _Stage {
  splash,
  onboarding,
  welcome,
  login,
  signUp,
  home,
  habits,
  habitDetails,
  addHabit,
  progress,
  profile,
}

class _PreviewShellState extends ConsumerState<PreviewShell> with WidgetsBindingObserver {
  final _reminderNotifications = ReminderNotifications();
  Timer? _reminderTimer;
  String? _reminderFingerprint;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Lets modal sheets/dialogs open from shell-level handlers: the State's own
  /// context sits above `MaterialApp` and has no Navigator.
  final _navKey = GlobalKey<NavigatorState>();
  late _Stage _stage = _initialStage();
  late final int _initialPage = _intParam('p', 0);
  late bool _isDark = _param('theme') == 'dark';
  Timer? _timer;
  bool _obscurePassword = false;

  /// Navigation spine history — `_back()` returns to where a screen was
  /// opened from (details/add), so the app moves like one connected flow.
  final _history = <_Stage>[];

  // Auth form state (local accounts until the backend lands).
  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();
  final _suName = TextEditingController();
  final _suEmail = TextEditingController();
  final _suPass = TextEditingController();
  final _suConfirm = TextEditingController();
  String? _loginEmailError, _loginPassError;
  String? _suNameError, _suEmailError, _suPassError, _suConfirmError;

  /// Theme bookkeeping: `?theme=…` forces the start value; a user tap wins
  /// afterwards; otherwise the persisted setting is adopted once it loads.
  bool _themeTouched = false;
  late final bool _themeForced = _param('theme') != null;

  static String? _param(String key) =>
      Uri.base.queryParameters[key]?.toLowerCase();

  static int _intParam(String key, int fallback) =>
      int.tryParse(Uri.base.queryParameters[key] ?? '') ?? fallback;

  static _Stage _initialStage() => switch (_param('s')) {
        'onboarding' => _Stage.onboarding,
        'welcome' => _Stage.welcome,
        'login' => _Stage.login,
        'signup' => _Stage.signUp,
        'home' => _Stage.home,
        'habits' => _Stage.habits,
        'details' => _Stage.habitDetails,
        'add' => _Stage.addHabit,
        'progress' => _Stage.progress,
        'profile' => _Stage.profile,
        _ => _Stage.splash,
      };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recoverPhoto());
    }
    // `?id=<habitId>` opens the details screen on a specific habit.
    final habitId = Uri.base.queryParameters['id'];
    if (habitId != null && habitId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Wait for the first load so `?s=details&id=` / `?s=add&id=` can find
        // the habit (the store read is async on a cold start).
        await ref.read(habitsProvider.future);
        if (!mounted) return;
        ref.read(selectedHabitIdProvider.notifier).state = habitId;
        if (_stage == _Stage.addHabit) {
          // `?s=add&id=…` opens the form in edit mode.
          ref.read(editingHabitIdProvider.notifier).state = habitId;
        }
      });
    }
    // Only auto-advance when the splash was reached naturally (no ?s= route).
    if (_stage == _Stage.splash && _param('s') == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _timer = Timer(const Duration(milliseconds: 2600), () {
          if (!mounted) return;
          // A signed-in (or guest) session skips straight to the app.
          final signedIn = ref.read(authProvider).signedIn;
          setState(() => _stage = signedIn ? _Stage.home : _Stage.onboarding);
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderTimer?.cancel();
    _timer?.cancel();
    for (final c in [_loginEmail, _loginPass, _suName, _suEmail, _suPass, _suConfirm]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Opens Habit Details for [habitId].
  /// Opens the Add form in create mode.
  void _newHabit() {
    ref.read(editingHabitIdProvider.notifier).state = null;
    ref.read(habitDraftProvider.notifier).reset();
    _go(_Stage.addHabit);
  }

  /// Opens the Add form prefilled for [habitId].
  Future<void> _editHabit(String habitId) async {
    await ref.read(habitsProvider.future);
    ref.read(editingHabitIdProvider.notifier).state = habitId;
    if (mounted) _go(_Stage.addHabit);
  }

  void _openDetails(String habitId) {
    ref.read(selectedHabitIdProvider.notifier).state = habitId;
    _go(_Stage.habitDetails);
  }

  /// Opens the form for whichever habit the details screen is showing.
  void _editCurrentHabit() {
    final id = ref.read(detailsHabitProvider)?.id;
    if (id != null) _editHabit(id);
  }


  /// True for the screens that form the app's navigation spine.
  static const _mainStages = {
    _Stage.home,
    _Stage.habits,
    _Stage.progress,
    _Stage.profile,
    _Stage.habitDetails,
  };

  void _go(_Stage stage) {
    _timer?.cancel();
    setState(() {
      if (_mainStages.contains(_stage) && _stage != stage) {
        _history.add(_stage);
      }
      if (stage == _Stage.login || stage == _Stage.signUp) {
        _loginEmailError = _loginPassError = null;
        _suNameError = _suEmailError = _suPassError = _suConfirmError = null;
      }
      _stage = stage;
    });
  }

  /// Pops back to the screen the current one was opened from.
  void _back() {
    _timer?.cancel();
    setState(
        () => _stage = _history.isEmpty ? _Stage.habits : _history.removeLast());
  }

  /// Tapping the already-selected bottom-nav tab does nothing.
  static void _noop() {}

  /// Validates and signs in to the account stored on this device.
  Future<void> _submitLogin() async {
    final email = _loginEmail.text;
    final pass = _loginPass.text;
    final emailError = validateEmail(email);
    final passError =
        pass.isEmpty ? 'Please enter your password' : null;
    if (emailError != null || passError != null) {
      setState(() {
        _loginEmailError = emailError;
        _loginPassError = passError;
      });
      return;
    }
    final error = await ref
        .read(authProvider.notifier)
        .signIn(email: email, password: pass);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        if (error.toLowerCase().contains('password')) {
          _loginPassError = error;
        } else {
          _loginEmailError = error;
        }
      });
      return;
    }
    setState(() {
      _loginEmailError = _loginPassError = null;
      _history.clear();
    });
    _toast('Welcome back ✦');
    _go(_Stage.home);
  }

  /// Creates the local account and enters the app.
  Future<void> _submitSignUp() async {
    final name = _suName.text;
    final email = _suEmail.text;
    final pass = _suPass.text;
    final confirm = _suConfirm.text;
    final nameError = validateName(name);
    final emailError = validateEmail(email);
    final passError = validatePassword(pass);
    final confirmError =
        pass == confirm ? null : 'The passwords do not match';
    if (nameError != null || emailError != null || passError != null || confirmError != null) {
      setState(() {
        _suNameError = nameError;
        _suEmailError = emailError;
        _suPassError = passError;
        _suConfirmError = confirmError;
      });
      return;
    }
    final error = await ref.read(authProvider.notifier).signUp(
          name: name,
          email: email,
          password: pass,
          confirmPassword: confirm,
        );
    if (!mounted) return;
    if (error != null) {
      _toast(error);
      return;
    }
    setState(() {
      _suNameError = _suEmailError = _suPassError = _suConfirmError = null;
      _history.clear();
    });
    _toast(tr('Welcome, {name} ✦', {'name': name.trim()}));
    _go(_Stage.home);
    await _offerSparkAlerts(force: true);
  }

  /// Enters the app without an account.
  Future<void> _submitGuest() async {
    await ref.read(authProvider.notifier).signInAsGuest();
    if (!mounted) return;
    setState(_history.clear);
    _go(_Stage.home);
    await _offerSparkAlerts();
  }

  /// Ends the session and returns to the welcome screen.
  Future<void> _logout() async {
    await ref.read(authProvider.notifier).signOut();
    if (!mounted) return;
    setState(_history.clear);
    _toast('Logged out ✦');
    _go(_Stage.welcome);
  }

  void _toast(String message) {
    _messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(tr(message))));
  }

  void _showCelebration() {
    final streak = ref.read(routineStreakProvider);
    final message = streak >= 3
        ? tr('Amazing! Your streak is {n} days ✨', {'n': '$streak'})
        : tr('You did it! Every little step counts ✨');
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Row(children: [
          const SparkMascot(size: 68, animate: true, celebrating: true),
          const SizedBox(width: 12),
          Expanded(child: figmaText(message, translate: false, size: 14,
              weight: FontWeight.w600, color: p.ink)),
        ]),
      ));
  }

  /// A local preference only until actual late alerts are implemented. The
  /// choice is asked for on first guest entry and each new local signup.
  Future<void> _offerSparkAlerts({bool force = false}) async {
    if (ref.read(demoModeProvider) != DemoMode.none) return;
    try {
      final preference = await ref.read(sparkAlertPreferenceProvider.notifier).load();
      if (!mounted || (preference.chosen && !force)) return;
      final ctx = _navKey.currentContext;
      if (ctx == null) return;
      final answer = await showDialog<bool>(context: ctx, barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(tr('Would you like Spark late alerts?')),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const SparkMascot(size: 90),
            const SizedBox(height: 12),
            Text(tr('Spark stays on Home either way. Late alerts are still being prepared and are not active yet.')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(tr('Not now'))),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(tr('Yes, when ready'))),
          ],
        ));
      if (!mounted || answer == null) return;
      await ref.read(sparkAlertPreferenceProvider.notifier).choose(answer);
      if (mounted && !answer) _toast('You can change this later in Profile, under Preferences.');
    } catch (_) {
      if (mounted) _toast('Could not save your choice. Please try again.');
    }
  }

  Future<void> _setSparkAlertsPreference(bool value) async {
    try {
      await ref.read(sparkAlertPreferenceProvider.notifier).choose(value);
    } catch (_) {
      if (mounted) _toast('Could not save your choice. Please try again.');
    }
  }

  /// Toggles the app theme and persists the choice.
  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
      _themeTouched = true;
    });
    ref
        .read(settingsProvider.notifier)
        .setThemeMode(_isDark ? ThemeMode.dark : ThemeMode.light);
  }

  /// Copies the app link (real share for now; the OS share sheet comes later).
  Future<void> _shareApp() async {
    await Clipboard.setData(
        const ClipboardData(text: 'https://shahd1982001.github.io/daily-spark/'));
    if (mounted) _toast('Link copied ✦');
  }

  /// The system photo picker returns only the chosen image. It stays on this
  /// device for now; an account-aware cloud store will be designed later.
  Future<void> _savePickedPhoto(XFile file) async {
    try {
      if (await file.length() > AvatarController.maxBytes) {
        if (mounted) _toast('Photo is too large. Please choose a smaller image.');
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final ok = await ref.read(avatarProvider.notifier).save(bytes);
      if (mounted) _toast(ok ? 'Profile photo updated ✦' : 'Could not save this photo. Please try another image.');
    } catch (_) {
      if (mounted) _toast('Could not open photos. Please check permission and try again.');
    }
  }

  Future<void> _recoverPhoto() async {
    try {
      final recovered = await ImagePicker().retrieveLostData();
      if (!mounted || recovered.isEmpty) return;
      final files = recovered.files;
      if (files != null && files.isNotEmpty) {
        await _savePickedPhoto(files.first);
      } else if (recovered.exception != null) {
        _toast('Could not open photos. Please check permission and try again.');
      }
    } catch (_) {
      // Nothing to recover; normal use remains available.
    }
  }

  Future<void> _showAvatarSheet() async {
    final hasPhoto = ref.read(avatarProvider) != null;
    final choice = await showModalBottomSheet<String>(
      context: _navKey.currentContext!,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          figmaText('Profile photo', size: 18, weight: FontWeight.w700, color: p.ink),
          const SizedBox(height: 4),
          figmaText('Your photo is stored on this device.', size: 13, weight: FontWeight.w400, color: p.body),
          const SizedBox(height: 12),
          ListTile(leading: Icon(Icons.photo_library_outlined, color: p.ember),
            title: figmaText('Choose photo', size: 15, weight: FontWeight.w600, color: p.ink),
            onTap: () => Navigator.pop(ctx, 'choose')),
          if (hasPhoto) ListTile(leading: Icon(Icons.delete_outline_rounded, color: p.error),
            title: figmaText('Remove photo', size: 15, weight: FontWeight.w600, color: p.error),
            onTap: () => Navigator.pop(ctx, 'remove')),
        ]),
      )),
    );
    if (!mounted || choice == null) return;
    if (choice == 'remove') {
      final ok = await ref.read(avatarProvider.notifier).remove();
      if (mounted) _toast(ok ? 'Profile photo removed' : 'Could not remove the photo. Please try again.');
      return;
    }
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery,
          maxWidth: 512, maxHeight: 512, imageQuality: 75);
      if (file != null) await _savePickedPhoto(file);
    } catch (_) {
      if (mounted) _toast('Could not open photos. Please check permission and try again.');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Timezone and permission may have changed while the app was away.
      _reminderFingerprint = null;
      _queueReminderSync();
    }
  }

  void _queueReminderSync() {
    if (!ReminderNotifications.supported || ref.read(demoModeProvider) != DemoMode.none) return;
    _reminderTimer?.cancel();
    _reminderTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final snapshot = ref.read(habitsProvider).valueOrNull;
      final settings = ref.read(settingsProvider);
      if (snapshot == null || !settings.loaded) return;
      final habits = snapshot.habits;
      final rules = buildReminderPlan(habits, enabled: settings.remindersOn);
      final locale = ref.read(localeProvider).languageCode;
      final fingerprint = jsonEncode([settings.remindersOn, locale,
        for (final r in rules) [r.habitId, r.weekday, r.hour, r.minute,
          habits.where((h) => h.id == r.habitId).first.title]]);
      if (fingerprint == _reminderFingerprint) return;
      _reminderFingerprint = fingerprint;
      final result = await _reminderNotifications.sync(habits, enabled: settings.remindersOn, language: locale);
      if (!mounted) return;
      if (result == ReminderResult.failed || result == ReminderResult.limitExceeded) {
        _reminderFingerprint = null; // allow a retry on the next change/resume
        _toast(result == ReminderResult.limitExceeded
            ? 'Too many reminders for this iPhone; none were scheduled. Reduce reminder days or habits.'
            : 'Could not schedule reminders. Please try again.');
      }
    });
  }

  Future<void> _enableReminders() async {
    if (!ReminderNotifications.supported || ref.read(demoModeProvider) != DemoMode.none) {
      _toast('Reminders are available in the mobile app, not this preview.');
      return;
    }
    final granted = await _reminderNotifications.requestPermission();
    if (!mounted) return;
    await ref.read(settingsProvider.notifier).setReminders(granted);
    if (!mounted) return;
    if (!granted) {
      _toast('Notifications are off. Allow them in your device settings to receive reminders.');
    }
    _reminderFingerprint = null;
    _queueReminderSync();
  }

  Future<void> _setReminders(bool value) async {
    if (value) {
      await _enableReminders();
    } else {
      await ref.read(settingsProvider.notifier).setReminders(false);
      _queueReminderSync();
    }
  }

  /// Bottom sheet: edit display name + ritual motto (real, persisted, and
  /// reflected on Home's greeting and the Profile identity card).
  Future<void> _showProfileSheet() async {
    final info = ref.read(profileInfoProvider);
    final nameCtrl = TextEditingController(text: info.name ?? '');
    final mottoCtrl = TextEditingController(text: info.motto ?? '');
    final saved = await showModalBottomSheet<bool>(
      context: _navKey.currentContext!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16 + bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                figmaText('Personal Details',
                    size: 18, weight: FontWeight.w700, color: p.ink),
                const SizedBox(height: 4),
                figmaText('Your name and motto travel with you across the app.',
                    size: 13,
                    weight: FontWeight.w400,
                    lineHeight: 18,
                    color: p.body),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  maxLength: 24,
                  style: const TextStyle(fontFamily: 'PlusJakartaSans'),
                  decoration: InputDecoration(
                    labelText: tr('Display name'),
                    counterText: '',
                    filled: true,
                    fillColor: p.canvas,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mottoCtrl,
                  maxLength: 80,
                  style: const TextStyle(fontFamily: 'PlusJakartaSans'),
                  decoration: InputDecoration(
                    labelText: tr('Ritual motto'),
                    counterText: '',
                    filled: true,
                    fillColor: p.canvas,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Material(
                    color: p.ember,
                    borderRadius: BorderRadius.circular(26),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(26),
                      onTap: () => Navigator.of(ctx).pop(true),
                      child: Center(
                        child: figmaText('Save',
                            size: 15,
                            weight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (saved == true) {
      final name = nameCtrl.text.trim();
      final motto = mottoCtrl.text.trim();
      await ref.read(profileInfoProvider.notifier).set(
            name: name.isEmpty ? null : name,
            motto: motto.isEmpty ? null : motto,
          );
      if (mounted) _toast('Profile updated ✦');
    }
    nameCtrl.dispose();
    mottoCtrl.dispose();
  }

  /// Bottom sheet: pick the app language (persisted, applies live).
  Future<void> _showLanguageSheet() async {
    const options = [
      ('en', 'English', 'English'),
      ('ar', 'العربية', 'Arabic'),
    ];
    final current = ref.read(localeProvider).languageCode;
    await showModalBottomSheet<void>(
      context: _navKey.currentContext!,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            figmaText('Language',
                size: 18, weight: FontWeight.w700, color: p.ink),
            const SizedBox(height: 12),
            for (final (code, native, english) in options)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ref.read(localeProvider.notifier).setLanguage(code);
                  Navigator.of(ctx).pop();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: figmaText(native,
                            size: 15,
                            weight: current == code
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: p.ink),
                      ),
                      if (current == code)
                        Icon(Icons.check_rounded, color: p.ember, size: 20),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(tr('Close')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet: a short, real guide to building rituals.
  Future<void> _showGuideSheet() async {
    await showModalBottomSheet<void>(
      context: _navKey.currentContext!,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            figmaText('The Ritual Guide',
                size: 18, weight: FontWeight.w700, color: p.ink),
            const SizedBox(height: 14),
            _guideStep('1', 'Ignite',
                'Name one small ritual, pick its symbol and a daily target.'),
            _guideStep('2', 'Track',
                'Tap the circle on the days you keep the promise — one tap per habit.'),
            _guideStep('3', 'Stack',
                'Tie each ritual to something you already do, and let streaks compound.'),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(tr('Close')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Honest note: recovery arrives with the cloud accounts.
  void _showForgotDialog() {
    showDialog<void>(
      context: _navKey.currentContext!,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: figmaText('Password recovery',
            size: 18, weight: FontWeight.w700, color: p.ink),
        content: figmaText(
          'Your account lives on this device for now. Password recovery '
          'arrives together with Spark Cloud accounts ☁️',
          size: 13,
          weight: FontWeight.w400,
          lineHeight: 19,
          color: p.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('Close')),
          ),
        ],
      ),
    );
  }

  Widget _guideStep(String number, String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.ember.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: figmaText(number,
                  size: 12, weight: FontWeight.w700, color: p.emberDeep),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  figmaText(title,
                      size: 14, weight: FontWeight.w700, color: p.ink),
                  const SizedBox(height: 2),
                  figmaText(body,
                      size: 13,
                      weight: FontWeight.w400,
                      lineHeight: 18,
                      color: p.body),
                ],
              ),
            ),
          ],
        ),
      );

  /// Dialog: what Daily Spark is, honestly.
  void _showAboutSpark() {
    showDialog<void>(
      context: _navKey.currentContext!,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: figmaText('Daily Spark',
            size: 18, weight: FontWeight.w700, color: p.ink),
        content: figmaText(
          'Version 2.4.0\n\nA local-first ritual companion: your habits, '
          'streaks and spark live on this device. Accounts and cloud '
          'sync arrive later.',
          size: 13,
          weight: FontWeight.w400,
          lineHeight: 19,
          color: p.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr('Close')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(calendarDayProvider); // Refresh visible dates after midnight/resume.
    // Adopt the persisted theme once it loads (?theme=… still forces it).
    ref.listen(completionCelebrationProvider, (previous, next) {
      if (previous != null && next > previous) _showCelebration();
    });
    ref.listen(habitsProvider, (_, __) => _queueReminderSync());
    ref.listen(localeProvider, (_, __) => _queueReminderSync());
    ref.listen(settingsProvider, (prev, next) {
      _queueReminderSync();
      if (!_themeForced && !_themeTouched && next.loaded) {
        setState(() => _isDark = next.themeMode == ThemeMode.dark);
      }
    });
    Strings.locale = ref.watch(localeProvider);
    final palette = _isDark ? SparkPalette.darkPalette : SparkPalette.light;
    SparkPalette.active = palette;
    return MaterialApp(
      title: 'Daily Spark',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      navigatorKey: _navKey,
      locale: ref.watch(localeProvider),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => SparkThemeScope(
        palette: palette,
        child: child ?? const SizedBox.shrink(),
      ),
      home: switch (_stage) {
        _Stage.splash => SplashScreen(onTap: () {
            final signedIn = ref.read(authProvider).signedIn;
            _go(signedIn ? _Stage.home : _Stage.onboarding);
          }),
        _Stage.onboarding => OnboardingScreen(
            initialPage: _initialPage,
            onSkip: () => _go(_Stage.welcome),
            onFinished: () => _go(_Stage.welcome),
            onFooterLogin: () => _go(_Stage.welcome),
          ),
        _Stage.welcome => WelcomeScreen(
            onGetStarted: () => _go(_Stage.signUp),
            onLogin: () => _go(_Stage.login),
            onGuest: _submitGuest,
          ),
        _Stage.login => LoginScreen(
            obscurePassword: _obscurePassword,
            emailController: _loginEmail,
            passwordController: _loginPass,
            emailError: _loginEmailError,
            passwordError: _loginPassError,
            onBack: () => _go(_Stage.welcome),
            onForgotPassword: _showForgotDialog,
            onTogglePasswordVisibility: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onLogin: _submitLogin,
            onGuest: _submitGuest,
            onSignUp: () => _go(_Stage.signUp),
          ),
        _Stage.signUp => SignUpScreen(
            obscurePassword: _obscurePassword,
            nameController: _suName,
            emailController: _suEmail,
            passwordController: _suPass,
            confirmController: _suConfirm,
            nameError: _suNameError,
            emailError: _suEmailError,
            passwordError: _suPassError,
            confirmError: _suConfirmError,
            onBack: () => _go(_Stage.welcome),
            onTogglePasswordVisibility: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onCreateAccount: _submitSignUp,
            onGuest: _submitGuest,
            onLogIn: () => _go(_Stage.login),
          ),
        _Stage.home => HomeScreen(
            userName: ref.watch(userNameProvider),
            onProfile: () => _go(_Stage.profile),
            onHabitTap: _openDetails,
            onNewRitual: _newHabit,
            onNavTap: (i) => switch (i) {
              1 => _go(_Stage.habits),
              2 => _go(_Stage.progress),
              3 => _go(_Stage.profile),
              _ => _noop(),
            },
          ),
        _Stage.habits => HabitsScreen(
            onProfile: () => _go(_Stage.profile),
            onHabitTap: _openDetails,
            onCreateHabit: _newHabit,
            onNavTap: (i) => switch (i) {
              0 => _go(_Stage.home),
              2 => _go(_Stage.progress),
              3 => _go(_Stage.profile),
              _ => _noop(),
            },
          ),
        _Stage.habitDetails => HabitDetailsScreen(
            onBack: _back,
            onEdit: _editCurrentHabit,
            onAvatar: () => _go(_Stage.profile),
            onEditRitual: _editCurrentHabit,
            onCreateHabit: _newHabit,
          ),
        _Stage.addHabit => AddHabitScreen(
            key: ValueKey('add-${ref.watch(editingHabitIdProvider)}'),
            onClose: _back,
            onAvatar: () => _go(_Stage.profile),
            onSaved: (habit) {
              if (habit.reminderTime != null && ref.read(settingsProvider).remindersOn) {
                _enableReminders();
              }
              final editing = ref.read(editingHabitIdProvider) != null;
              _messengerKey.currentState
                ?..clearSnackBars()
                ..showSnackBar(SnackBar(content: HabitSentence(
                  template: editing ? '{title} updated ✦' : '{title} ignited ✦',
                  title: habit.title,
                )));
              // Edits return to where they were opened from (details/list);
              // a new habit lands on the Habits list so it is visible at once.
              if (editing) {
                _back();
              } else {
                _go(_Stage.habits);
              }
            },
            onDiscard: _back,
          ),
        _Stage.profile => ProfileScreen(
            themeDark: _isDark,
            remindersOn: ref.watch(settingsProvider.select((s) => s.remindersOn)),
            soundOn: ref.watch(settingsProvider.select((s) => s.soundOn)),
            sparkAlertsWanted: ref.watch(sparkAlertPreferenceProvider).wanted,
            syncLabel: 'Local',
            syncSubtitle: 'Stored on this device · private & safe',
            onShare: _shareApp,
            onEdit: _showProfileSheet,
            onAvatarTap: _showAvatarSheet,
            onStatTap: (_) => _go(_Stage.progress),
            onPersonalDetails: _showProfileSheet,
            onCloudSync: () => _toast(
                'Your data lives on this device for now — Spark Cloud arrives with accounts ☁️'),
            onToggleReminders: _setReminders,
            onToggleSound: (v) => ref.read(settingsProvider.notifier).setSound(v),
            onToggleSparkAlerts: _setSparkAlertsPreference,
            onAppearance: _toggleTheme,
            onLanguage: _showLanguageSheet,
            onGuide: _showGuideSheet,
            onAbout: _showAboutSpark,
            onLogOut: _logout,
            onNavTap: (i) => switch (i) {
              0 => _go(_Stage.home),
              1 => _go(_Stage.habits),
              2 => _go(_Stage.progress),
              _ => _noop(),
            },
          ),
        _Stage.progress => ProgressScreen(
            onProfile: () => _go(_Stage.profile),
            onBell: () =>
                _toast('Set a reminder time when you create or edit a habit. 🔔'),
            onShare: _shareApp,
            onNavTap: (i) => switch (i) {
              0 => _go(_Stage.home),
              1 => _go(_Stage.habits),
              3 => _go(_Stage.profile),
              _ => _noop(),
            },
          ),
      },
    );
  }
}
