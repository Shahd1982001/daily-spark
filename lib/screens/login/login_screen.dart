import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// PURE UI — Login.
/// No routing, no state, no network: the parent decides what each control means.
/// Figma: node 126:15085 (390 × 884).
class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    this.email = 'sarah.miller@example.com',
    this.password = 'masterRitual2024!',
    this.obscurePassword = false,
    this.onBack,
    this.onForgotPassword,
    this.onTogglePasswordVisibility,
    this.onLogin,
    this.onGuest,
    this.onSignUp,
  });

  final String email;
  final String password;
  final bool obscurePassword;

  final VoidCallback? onBack;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onTogglePasswordVisibility;
  final VoidCallback? onLogin;
  final VoidCallback? onGuest;
  final VoidCallback? onSignUp;

  static Color get _canvas => p.canvas;
  static Color get _ink => p.ink;
  static Color get _brown => p.body;
  static Color get _ember => p.ember;
  static Color get _deepEmber => p.emberDeep;
  static Color get _loginLink => p.emberDark;
  static Color get _outlineWarm => p.muted;
  static Color get _sage => p.sage;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16 * s),
              _TopBar(scale: s, onBack: onBack),
              SizedBox(height: 32 * s),

              // ── Title block ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EyebrowChip(scale: s),
                    SizedBox(height: 12 * s),
                    figmaText(
                      'Welcome back.',
                      size: 26 * s,
                      weight: FontWeight.w700,
                      letterSpacing: -0.65 * s,
                      lineHeight: 32 * s,
                      color: _ink,
                    ),
                    SizedBox(height: 7 * s),
                    Padding(
                      padding: EdgeInsets.only(right: 2 * s),
                      child: figmaText(
                        'Let\u2019s continue building your habits and nurturing '
                        'your daily rhythm.',
                        size: 14 * s,
                        weight: FontWeight.w400,
                        lineHeight: 23 * s,
                        color: _brown,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25 * s),

              // ── Streak reassurance banner ──────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: _StreakBanner(scale: s),
              ),
              SizedBox(height: 23 * s),

              // ── Form ───────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'EMAIL ADDRESS', scale: s),
                    SizedBox(height: 8 * s),
                    _InputField(
                      scale: s,
                      value: email,
                      icon: Icons.mail_outline_rounded,
                      iconWidth: 17 * s,
                      iconHeight: 16 * s,
                    ),
                    SizedBox(height: 19 * s),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _FieldLabel(text: 'PASSWORD', scale: s),
                        const Spacer(),
                        GestureDetector(
                          onTap: onForgotPassword,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.only(right: 2 * s, bottom: 2 * s),
                            child: figmaText(
                              'Forgot password?',
                              size: 12 * s,
                              weight: FontWeight.w600,
                              lineHeight: 16 * s,
                              color: _deepEmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * s),
                    _InputField(
                      scale: s,
                      value: password,
                      obscure: obscurePassword,
                      icon: Icons.lock_outline_rounded,
                      iconWidth: 14 * s,
                      iconHeight: 18 * s,
                      iconGap: 12 * s,
                      trailing: _EyeButton(
                        scale: s,
                        obscured: obscurePassword,
                        onTap: onTogglePasswordVisibility,
                      ),
                    ),
                    SizedBox(height: 28 * s),
                    _PrimaryButton(scale: s, onTap: onLogin),
                    SizedBox(height: 24 * s),
                    _OrDivider(scale: s),
                    SizedBox(height: 24 * s),
                    _GuestButton(scale: s, onTap: onGuest),
                    SizedBox(height: 38 * s),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          figmaText(
                            'Don\u2019t have an account? ',
                            size: 14 * s,
                            weight: FontWeight.w400,
                            lineHeight: 20 * s,
                            color: _brown,
                          ),
                          GestureDetector(
                            onTap: onSignUp,
                            behavior: HitTestBehavior.opaque,
                            child: figmaText(
                              'Sign Up',
                              size: 16 * s,
                              weight: FontWeight.w700,
                              lineHeight: 22 * s,
                              color: _loginLink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18 * s),
                    Center(child: _LegalLinks(scale: s)),
                    SizedBox(height: 120 * s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar — circular back button + soft brand chip
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.scale, this.onBack});

  final double scale;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44 * s,
              height: 44 * s,
              decoration: BoxDecoration(
                color: p.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4 * s,
                    offset: Offset(0, 1 * s),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18 * s,
                color: p.ink,
              ),
            ),
          ),
          Spacer(),
          Container(
            height: 28 * s,
            padding: EdgeInsets.symmetric(horizontal: 12 * s),
            decoration: BoxDecoration(
              color: p.panel,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/brand/spark_mark.png',
                  width: 16 * s,
                  height: 16 * s,
                  filterQuality: FilterQuality.high,
                ),
                SizedBox(width: 6 * s),
                figmaText(
                  'Daily Spark',
                  size: 12 * s,
                  weight: FontWeight.w600,
                  lineHeight: 16 * s,
                  color: p.ink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "WELCOME BACK" eyebrow
// ─────────────────────────────────────────────────────────────────────────────
class _EyebrowChip extends StatelessWidget {
  const _EyebrowChip({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 20 * s,
      padding: EdgeInsets.symmetric(horizontal: 12 * s),
      decoration: BoxDecoration(
        color: p.emberTile,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6 * s,
            height: 6 * s,
            decoration: BoxDecoration(
              color: p.emberDeep,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8 * s),
          figmaText(
            'WELCOME BACK',
            size: 10 * s,
            weight: FontWeight.w700,
            letterSpacing: 0.5 * s,
            lineHeight: 12 * s,
            color: p.emberDark,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak reassurance banner
// ─────────────────────────────────────────────────────────────────────────────
class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 60 * s,
      decoration: BoxDecoration(
        color: p.chipGold,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14 * s),
      child: Row(
        children: [
          Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              color: p.emberTile,
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 16 * s,
              color: p.ember,
            ),
          ),
          SizedBox(width: 12 * s),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              figmaText(
                'Your 21-day streak is waiting',
                size: 12 * s,
                weight: FontWeight.w600,
                lineHeight: 16 * s,
                color: p.ink,
              ),
              figmaText(
                'Check in today to keep momentum alive.',
                size: 12 * s,
                weight: FontWeight.w500,
                lineHeight: 16 * s,
                color: p.ochre,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.scale});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * scale),
      child: figmaText(
        text,
        size: 10 * scale,
        weight: FontWeight.w700,
        letterSpacing: 0.4 * scale,
        lineHeight: 12 * scale,
        color: p.body,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.scale,
    required this.value,
    required this.icon,
    required this.iconWidth,
    required this.iconHeight,
    this.obscure = false,
    this.iconGap,
    this.trailing,
  });

  final double scale;
  final String value;
  final IconData icon;
  final double iconWidth;
  final double iconHeight;
  final bool obscure;
  final double? iconGap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 52 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 18 * s, right: 14 * s),
      child: Row(
        children: [
          SizedBox(
            width: iconWidth,
            height: iconHeight,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(icon, color: p.muted),
            ),
          ),
          SizedBox(width: iconGap ?? 9 * s),
          Expanded(
            child: TextFormField(
              initialValue: value,
              obscureText: obscure,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14 * s,
                height: 18 / 14,
                letterSpacing: 0,
                fontWeight: FontWeight.w400,
                color: p.ink,
              ),
              cursorColor: p.ember,
              cursorWidth: 1.2 * s,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 8 * s),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _EyeButton extends StatelessWidget {
  const _EyeButton({required this.scale, required this.obscured, this.onTap});

  final double scale;
  final bool obscured;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32 * s,
        height: 32 * s,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: Icon(
          obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 18 * s,
          color: p.muted,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary CTA — ember gradient
// ─────────────────────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * s),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.emberLight, p.ember],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            figmaText(
              'Log In',
              size: 14 * s,
              weight: FontWeight.w600,
              lineHeight: 18 * s,
              color: p.surface,
            ),
            SizedBox(width: 9 * s),
            SizedBox(
              width: 12 * s,
              height: 12 * s,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Divider
// ─────────────────────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 12 * s,
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: p.bone),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * s),
            child: figmaText(
              'OR CONTINUE SEAMLESSLY',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.4 * s,
              lineHeight: 12 * s,
              color: p.muted,
            ),
          ),
          Expanded(
            child: Container(height: 1, color: p.bone),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Guest button
// ─────────────────────────────────────────────────────────────────────────────
class _GuestButton extends StatelessWidget {
  const _GuestButton({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48 * s,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16 * s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6 * s,
              offset: Offset(0, 1 * s),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 15 * s,
              height: 15 * s,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(Icons.explore_outlined, color: p.sage),
              ),
            ),
            SizedBox(width: 8 * s),
            figmaText(
              'Continue as Guest',
              size: 14 * s,
              weight: FontWeight.w500,
              lineHeight: 18 * s,
              color: p.ink,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legal links
// ─────────────────────────────────────────────────────────────────────────────
class _LegalLinks extends StatelessWidget {
  const _LegalLinks({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final style = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 10 * s,
      height: 12 / 10,
      letterSpacing: 0.4 * s,
      fontWeight: FontWeight.w600,
      color: p.body.withValues(alpha: 0.7),
      decoration: TextDecoration.none,
    );
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: style,
        children: [
          const TextSpan(text: 'Privacy Policy'),
          TextSpan(text: '  \u2022   ', style: style),
          const TextSpan(text: 'Terms of Service'),
          TextSpan(text: '  \u2022   ', style: style),
          const TextSpan(text: 'Support'),
        ],
      ),
    );
  }
}
