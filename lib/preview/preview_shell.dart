import 'dart:async';

import 'package:flutter/material.dart';
import 'package:daily_spark/design_system/theme/app_theme.dart';
import 'package:daily_spark/screens/onboarding/onboarding_screen.dart';
import 'package:daily_spark/screens/splash/splash_screen.dart';
import 'package:daily_spark/screens/home/home_screen.dart';
import 'package:daily_spark/screens/login/login_screen.dart';
import 'package:daily_spark/screens/sign_up/sign_up_screen.dart';
import 'package:daily_spark/screens/welcome/welcome_screen.dart';

/// ⚠️ TEMPORARY PREVIEW SHELL — scaffolding only, zero business logic.
///
/// It shows the pure design screens exactly as drawn in Figma (no dev bar,
/// no overlay of any kind). Screens are reachable by URL while we review:
///
///   /?s=onboarding&p=2   → onboarding page 2
///   /?s=welcome          → welcome screen
///
/// This shell will be replaced by the real app router later.
class PreviewShell extends StatefulWidget {
  const PreviewShell({super.key});

  @override
  State<PreviewShell> createState() => _PreviewShellState();
}

enum _Stage { splash, onboarding, welcome, login, signUp, home }

class _PreviewShellState extends State<PreviewShell> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  late _Stage _stage = _initialStage();
  late final int _initialPage = _intParam('p', 0);
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
        _ => _Stage.splash,
      };

  @override
  void initState() {
    super.initState();
    if (_stage == _Stage.splash) {
      _timer = Timer(const Duration(milliseconds: 2600), () {
        if (mounted) setState(() => _stage = _Stage.onboarding);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    return MaterialApp(
      title: 'Daily Spark',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
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
            onProfile: () => _toast('Profile — later ✦'),
            onToggleHabit: (i) => _toast('Habit $i toggled ✦'),
            onHabitTap: (i) => _toast('Habit $i — details later ✦'),
            onNewRitual: () => _toast('New Ritual — later ✦'),
            onFilterChanged: (i) => _toast('Filter $i ✦'),
            onNavTap: (i) => _toast('Nav $i ✦'),
          ),
      },
    );
  }
}
