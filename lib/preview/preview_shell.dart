import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:daily_spark/state/add_habit_providers.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/details_providers.dart';

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
  late _Stage _stage = _initialStage();
  late final int _initialPage = _intParam('p', 0);
  late bool _isDark = _param('theme') == 'dark';
  Timer? _timer;
  bool _obscurePassword = false;

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
          if (mounted) setState(() => _stage = _Stage.onboarding);
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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


  void _go(_Stage stage) {
    _timer?.cancel();
    setState(() => _stage = stage);
  }

  void _toast(String message) {
    _messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = _isDark ? SparkPalette.darkPalette : SparkPalette.light;
    SparkPalette.active = palette;
    return MaterialApp(
      title: 'Daily Spark',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => SparkThemeScope(
        palette: palette,
        child: child ?? const SizedBox.shrink(),
      ),
      home: switch (_stage) {
        _Stage.splash => SplashScreen(onTap: () => _go(_Stage.onboarding)),
        _Stage.onboarding => OnboardingScreen(
            initialPage: _initialPage,
            onSkip: () => _go(_Stage.welcome),
            onFinished: () => _go(_Stage.welcome),
            onFooterLogin: () => _go(_Stage.welcome),
          ),
        _Stage.welcome => WelcomeScreen(
            onGetStarted: () => _go(_Stage.signUp),
            onLogin: () => _go(_Stage.login),
            onGuest: () => _toast('Guest mode — الشاشة الجاية ✦'),
          ),
        _Stage.login => LoginScreen(
            obscurePassword: _obscurePassword,
            onBack: () => _go(_Stage.welcome),
            onForgotPassword: () => _toast('Forgot password — later ✦'),
            onTogglePasswordVisibility: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onLogin: () => _go(_Stage.home),
            onGuest: () => _toast('Guest mode — الشاشة الجاية ✦'),
            onSignUp: () => _go(_Stage.signUp),
          ),
        _Stage.signUp => SignUpScreen(
            obscurePassword: _obscurePassword,
            onBack: () => _go(_Stage.welcome),
            onTogglePasswordVisibility: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onCreateAccount: () => _go(_Stage.home),
            onGuest: () => _toast('Guest mode — الشاشة الجاية ✦'),
            onLogIn: () => _go(_Stage.login),
          ),
        _Stage.home => HomeScreen(
            onProfile: () => _go(_Stage.profile),
            onHabitTap: _openDetails,
            onNewRitual: _newHabit,
            onNavTap: (i) => switch (i) {
              1 => _go(_Stage.habits),
              2 => _go(_Stage.progress),
              3 => _go(_Stage.profile),
              _ => _toast('Nav $i ✦'),
            },
          ),
        _Stage.habits => HabitsScreen(
            onProfile: () => _go(_Stage.profile),
            onSort: () => _toast('Sort & filter ✦'),
            onHabitTap: _openDetails,
            onCreateHabit: _newHabit,
            onNavTap: (i) => switch (i) {
              0 => _go(_Stage.home),
              2 => _go(_Stage.progress),
              3 => _go(_Stage.profile),
              _ => _toast('Nav $i ✦'),
            },
          ),
        _Stage.habitDetails => HabitDetailsScreen(
            onBack: () => _go(_Stage.habits),
            onEdit: _editCurrentHabit,
            onAvatar: () => _go(_Stage.profile),
            onEditRitual: _editCurrentHabit,
            onCreateHabit: _newHabit,
          ),
        _Stage.addHabit => AddHabitScreen(
            key: ValueKey('add-${ref.watch(editingHabitIdProvider)}'),
            onClose: () => _go(_Stage.habits),
            onAvatar: () => _go(_Stage.profile),
            onSaved: (habit) {
              final editing = ref.read(editingHabitIdProvider) != null;
              _toast(editing
                  ? '${habit.title} updated ✦'
                  : '${habit.title} ignited ✦');
              _go(_Stage.habits);
            },
            onDiscard: () => _go(_Stage.habits),
          ),
        _Stage.profile => ProfileScreen(
            themeDark: _isDark,
            onSettings: () => _toast('Settings ✦'),
            onShare: () => _toast('Share summary ✦'),
            onEdit: () => _toast('Edit profile ✦'),
            onStatTap: (i) => _toast('Stat $i ✦'),
            onPersonalDetails: () => _toast('Personal details ✦'),
            onCloudSync: () => _toast('Cloud sync ✦'),
            onToggleReminders: (v) => _toast('Reminders ${v ? 'on' : 'off'} ✦'),
            onToggleSound: (v) => _toast('Sound ${v ? 'on' : 'off'} ✦'),
            onAppearance: () => setState(() => _isDark = !_isDark),
            onLanguage: () => _toast('Language ✦'),
            onGuide: () => _toast('Ritual guide ✦'),
            onAbout: () => _toast('About ✦'),
            onLogOut: () => _go(_Stage.welcome),
            onNavTap: (i) => switch (i) {
              0 => _go(_Stage.home),
              1 => _go(_Stage.habits),
              2 => _go(_Stage.progress),
              _ => _toast('Nav $i ✦'),
            },
          ),
        _Stage.progress => ProgressScreen(
            onProfile: () => _toast('Profile ✦'),
            onBell: () => _toast('Notifications ✦'),
            onShare: () => _toast('Share achievement ✦'),
            onNavTap: (i) => switch (i) {
              0 => _go(_Stage.home),
              1 => _go(_Stage.habits),
              3 => _go(_Stage.profile),
              _ => _toast('Nav $i ✦'),
            },
          ),
      },
    );
  }
}
