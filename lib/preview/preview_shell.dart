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

class _PreviewShellState extends ConsumerState<PreviewShell> {
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
  }

  /// Enters the app without an account.
  Future<void> _submitGuest() async {
    await ref.read(authProvider.notifier).signInAsGuest();
    if (!mounted) return;
    setState(_history.clear);
    _go(_Stage.home);
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
    // Adopt the persisted theme once it loads (?theme=… still forces it).
    ref.listen(settingsProvider, (prev, next) {
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
            syncLabel: 'Local',
            syncSubtitle: 'Stored on this device · private & safe',
            onShare: _shareApp,
            onEdit: _showProfileSheet,
            onStatTap: (_) => _go(_Stage.progress),
            onPersonalDetails: _showProfileSheet,
            onCloudSync: () => _toast(
                'Your data lives on this device for now — Spark Cloud arrives with accounts ☁️'),
            onToggleReminders: (v) =>
                ref.read(settingsProvider.notifier).setReminders(v),
            onToggleSound: (v) => ref.read(settingsProvider.notifier).setSound(v),
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
                _toast('Notifications arrive with the accounts update 🔔'),
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
