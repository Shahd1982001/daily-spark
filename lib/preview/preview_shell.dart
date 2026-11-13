import 'dart:async';

import 'package:flutter/material.dart';
import 'package:daily_spark/design_system/theme/app_theme.dart';
import 'package:daily_spark/screens/onboarding/onboarding_screen.dart';
import 'package:daily_spark/screens/splash/splash_screen.dart';
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

enum _Stage { splash, onboarding, welcome }

class _PreviewShellState extends State<PreviewShell> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  late _Stage _stage = _initialStage();
  late final int _initialPage = _intParam('p', 0);
  Timer? _timer;

  static String? _param(String key) =>
      Uri.base.queryParameters[key]?.toLowerCase();

  static int _intParam(String key, int fallback) =>
      int.tryParse(Uri.base.queryParameters[key] ?? '') ?? fallback;

  static _Stage _initialStage() => switch (_param('s')) {
        'onboarding' => _Stage.onboarding,
        'welcome' => _Stage.welcome,
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
            onGetStarted: () => _toast('Sign Up — الشاشة الجاية ✦'),
            onLogin: () => _toast('Login — الشاشة الجاية ✦'),
            onGuest: () => _toast('Guest mode — الشاشة الجاية ✦'),
          ),
      },
    );
  }
}
