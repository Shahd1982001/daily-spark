import 'dart:async';

import 'package:flutter/material.dart';
import 'package:daily_spark/design_system/theme/app_colors.dart';
import 'package:daily_spark/design_system/theme/app_spacing.dart';
import 'package:daily_spark/design_system/theme/app_theme.dart';
import 'package:daily_spark/design_system/theme/app_typography.dart';
import 'package:daily_spark/screens/onboarding/onboarding_screen.dart';
import 'package:daily_spark/screens/splash/splash_screen.dart';
import 'package:daily_spark/screens/welcome/welcome_screen.dart';

/// ⚠️ TEMPORARY PREVIEW SHELL — scaffolding only, zero business logic.
/// Purpose: click through the pure design screens before we choose
/// Provider vs Riverpod. It will be replaced by the real app shell later.
class PreviewShell extends StatefulWidget {
  const PreviewShell({super.key});

  @override
  State<PreviewShell> createState() => _PreviewShellState();
}

enum _Stage { splash, onboarding, welcome }

class _PreviewShellState extends State<PreviewShell> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  _Stage _stage = _Stage.splash;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _stage = _Stage.onboarding);
    });
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
      title: 'Daily Spark — Design Preview',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      builder: (context, child) => Stack(
        children: [
          if (child != null) Positioned.fill(child: child),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _PreviewBar(
              stage: _stage,
              onSelect: _go,
            ),
          ),
        ],
      ),
      home: switch (_stage) {
        _Stage.splash => GestureDetector(
            onTap: () => _go(_Stage.onboarding),
            child: const SplashScreen(),
          ),
        _Stage.onboarding => OnboardingScreen(
            onSkip: () => _go(_Stage.welcome),
            onFinished: () => _go(_Stage.welcome),
            onFooterLogin: () => _go(_Stage.welcome),
          ),
        _Stage.welcome => WelcomeScreen(
            onBack: () => _go(_Stage.onboarding),
            onGetStarted: () => _toast('Sign Up — الشاشة الجاية ✦'),
            onLogin: () => _toast('Login — الشاشة الجاية ✦'),
            onGuest: () => _toast('Guest mode — الشاشة الجاية ✦'),
          ),
      },
    );
  }
}

/// Tiny dev-only switcher so we can jump between design screens.
class _PreviewBar extends StatelessWidget {
  const _PreviewBar({required this.stage, required this.onSelect});

  final _Stage stage;
  final ValueChanged<_Stage> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.s12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.onBackground.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tab('Splash', _Stage.splash),
              _tab('Onboarding', _Stage.onboarding),
              _tab('Welcome', _Stage.welcome),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, _Stage value) {
    final active = stage == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.sparkOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppText.interactiveLabel.copyWith(
            color: active ? Colors.white : Colors.white70,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
