import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// PURE UI — Sign Up.
/// No routing, no state, no network: the parent decides what each control means.
/// Figma: node 126:17220 — visible frame 390 × 844 (content 390 × 970, scrolls).
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({
    super.key,
    this.fullName = '',
    this.email = '',
    this.password = 'SuperSecret123',
    this.confirmPassword = 'SuperSecret123',
    this.obscurePassword = false,
    this.onBack,
    this.onTogglePasswordVisibility,
    this.onCreateAccount,
    this.onGuest,
    this.onLogIn,
  });

  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;

  final VoidCallback? onBack;
  final VoidCallback? onTogglePasswordVisibility;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onGuest;
  final VoidCallback? onLogIn;

  static Color get _canvas => p.canvas;
  static Color get _ink => p.ink;
  static Color get _brown => p.body;
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
              SizedBox(height: 8 * s),
              _TopBar(scale: s, onBack: onBack),
              SizedBox(height: 28 * s),

              // ── Editorial headline ─────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _JourneyChip(scale: s),
                    SizedBox(height: 8 * s),
                    figmaText(
                      'Create your account.',
                      size: 26 * s,
                      weight: FontWeight.w600,
                      letterSpacing: -0.52 * s,
                      lineHeight: 32 * s,
                      color: _ink,
                    ),
                    SizedBox(height: 12 * s),
                    figmaText(
                      'Start building habits that stick and ignite your daily '
                      'rhythm.',
                      size: 14 * s,
                      weight: FontWeight.w400,
                      lineHeight: 20 * s,
                      color: _brown,
                    ),
                    SizedBox(height: 12 * s),
                  ],
                ),
              ),

              // ── Delight motivation pill ────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: _MotivationPill(scale: s),
              ),
              SizedBox(height: 24 * s),

              // ── Form ───────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label(text: 'FULL NAME', scale: s),
                    SizedBox(height: 6 * s),
                    _Field(
                      scale: s,
                      value: fullName,
                      hint: 'e.g. Maya Lin',
                      icon: Icons.person_outline_rounded,
                      iconBox: const Size(13, 13),
                    ),
                    SizedBox(height: 16 * s),
                    _Label(text: 'EMAIL ADDRESS', scale: s),
                    SizedBox(height: 6 * s),
                    _Field(
                      scale: s,
                      value: email,
                      hint: 'maya.lin@example.com',
                      icon: Icons.mail_outline_rounded,
                      iconBox: const Size(17, 14),
                      gapAfterIcon: 12,
                    ),
                    SizedBox(height: 16 * s),

                    // PASSWORD + rule hint
                    SizedBox(
                      height: 12 * s,
                      child: Row(
                        children: [
                          _Label(text: 'PASSWORD', scale: s),
                          const Spacer(),
                          Container(
                            width: 6 * s,
                            height: 6 * s,
                            margin: EdgeInsets.only(right: 6 * s, top: 1 * s),
                            decoration: BoxDecoration(
                              color: _sage,
                              shape: BoxShape.circle,
                            ),
                          ),
                          figmaText(
                            '8+ chars \u2022 1 number',
                            size: 10 * s,
                            weight: FontWeight.w500,
                            letterSpacing: 0.4 * s,
                            lineHeight: 12 * s,
                            color: _sage,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    _Field(
                      scale: s,
                      value: password,
                      obscure: obscurePassword,
                      letterSpacing: 1.4,
                      icon: Icons.lock_outline_rounded,
                      iconBox: const Size(13, 18),
                      trailing: _EyeButton(
                        scale: s,
                        obscured: obscurePassword,
                        onTap: onTogglePasswordVisibility,
                      ),
                    ),
                    SizedBox(height: 16 * s),

                    // CONFIRM PASSWORD + match badge
                    SizedBox(
                      height: 16 * s,
                      child: Row(
                        children: [
                          _Label(text: 'CONFIRM PASSWORD', scale: s),
                          Spacer(),
                          Container(
                            height: 16 * s,
                            padding: EdgeInsets.symmetric(horizontal: 8 * s),
                            decoration: BoxDecoration(
                              color: p.chipGreen,
                              borderRadius: BorderRadius.all(Radius.circular(999)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 8 * s,
                                  height: 6 * s,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Icon(Icons.check,
                                        color: p.pine),
                                  ),
                                ),
                                SizedBox(width: 4 * s),
                                figmaText(
                                  'Passwords match',
                                  size: 10 * s,
                                  weight: FontWeight.w500,
                                  letterSpacing: 0.4 * s,
                                  lineHeight: 12 * s,
                                  color: p.pine,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    _Field(
                      scale: s,
                      value: confirmPassword,
                      obscure: obscurePassword,
                      letterSpacing: 1.4,
                      icon: Icons.lock_reset_rounded,
                      iconBox: Size(17, 17),
                      gapAfterIcon: 12,
                      trailing: SizedBox(
                        width: 17 * s,
                        height: 17 * s,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(Icons.check_circle, color: p.sage),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * s),
                    _StrengthMeter(scale: s),
                    SizedBox(height: 24 * s),
                    _CreateAccountButton(scale: s, onTap: onCreateAccount),
                    SizedBox(height: 24 * s),
                    _OrDivider(scale: s),
                    SizedBox(height: 24 * s),
                    _GuestButton(scale: s, onTap: onGuest),
                    SizedBox(height: 32 * s),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          figmaText(
                            'Already have an account? ',
                            size: 14 * s,
                            weight: FontWeight.w400,
                            lineHeight: 20 * s,
                            color: _brown,
                          ),
                          GestureDetector(
                            onTap: onLogIn,
                            behavior: HitTestBehavior.opaque,
                            child: figmaText(
                              'Log In',
                              size: 16 * s,
                              weight: FontWeight.w600,
                              letterSpacing: -0.08 * s,
                              lineHeight: 22 * s,
                              color: _loginLink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 39 * s),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12 * s,
                            height: 19 / 12,
                            letterSpacing: 0.12 * s,
                            color: _outlineWarm,
                            decoration: TextDecoration.none,
                          ),
                          children: [
                            const TextSpan(text: 'By signing up, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: _brown,
                                decoration: TextDecoration.underline,
                                decorationColor: _brown.withValues(alpha: 0.4),
                              ),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: _brown,
                                decoration: TextDecoration.underline,
                                decorationColor: _brown.withValues(alpha: 0.4),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32 * s),
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
// Top bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.scale, this.onBack});

  final double scale;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44 * s,
              height: 44 * s,
              decoration: BoxDecoration(
                color: p.container,
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
            height: 32 * s,
            padding: EdgeInsets.symmetric(horizontal: 12 * s),
            decoration: BoxDecoration(
              color: p.panel,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                figmaText(
                  '\u2726',
                  size: 14 * s,
                  weight: FontWeight.w400,
                  lineHeight: 20 * s,
                  color: p.emberDeep,
                ),
                SizedBox(width: 7 * s),
                figmaText(
                  'DAILY SPARK',
                  size: 10 * s,
                  weight: FontWeight.w600,
                  letterSpacing: 0.5 * s,
                  lineHeight: 12 * s,
                  color: p.body,
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
// "• START YOUR JOURNEY" chip
// ─────────────────────────────────────────────────────────────────────────────
class _JourneyChip extends StatelessWidget {
  const _JourneyChip({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 20 * s,
      padding: EdgeInsets.symmetric(horizontal: 10 * s),
      decoration: BoxDecoration(
        color: p.emberTile,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: figmaText(
        '\u2022 START YOUR JOURNEY',
        size: 10 * s,
        weight: FontWeight.w600,
        letterSpacing: 1 * s,
        lineHeight: 12 * s,
        color: p.emberDark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delight motivation pill
// ─────────────────────────────────────────────────────────────────────────────
class _MotivationPill extends StatelessWidget {
  const _MotivationPill({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 56 * s,
      padding: EdgeInsets.symmetric(horizontal: 12 * s),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Row(
        children: [
          Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              color: p.mintSoft,
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              size: 17 * s,
              color: p.success,
            ),
          ),
          SizedBox(width: 10 * s),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              figmaText(
                '14-day streak boost unlocked',
                size: 12 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.24 * s,
                lineHeight: 16 * s,
                color: p.ink,
              ),
              figmaText(
                'Join 45,000+ mindful daily ritual builders',
                size: 12 * s,
                weight: FontWeight.w400,
                letterSpacing: 0.12 * s,
                lineHeight: 16 * s,
                color: p.body,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field pieces
// ─────────────────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label({required this.text, required this.scale});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return figmaText(
      text,
      size: 10 * scale,
      weight: FontWeight.w600,
      letterSpacing: 0.5 * scale,
      lineHeight: 12 * scale,
      color: p.body,
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.scale,
    required this.value,
    required this.icon,
    required this.iconBox,
    this.hint,
    this.obscure = false,
    this.letterSpacing = 0,
    this.gapAfterIcon = 12,
    this.trailing,
  });

  final double scale;
  final String value;
  final String? hint;
  final IconData icon;
  final Size iconBox;
  final bool obscure;
  final double letterSpacing;
  final double gapAfterIcon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final isEmpty = value.isEmpty;
    return Container(
      height: 52 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 14 * s, right: 12 * s),
      child: Row(
        children: [
          SizedBox(
            width: iconBox.width * s,
            height: iconBox.height * s,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(icon, color: p.muted),
            ),
          ),
          SizedBox(width: gapAfterIcon * s),
          Expanded(
            child: TextFormField(
              initialValue: value,
              obscureText: obscure,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14 * s,
                height: 18 / 14,
                letterSpacing: letterSpacing * s,
                fontWeight: FontWeight.w400,
                color: isEmpty ? p.muted : p.ink,
              ),
              cursorColor: p.ember,
              cursorWidth: 1.2 * s,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: isEmpty ? hint : null,
                hintStyle: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14 * s,
                  height: 18 / 14,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w400,
                  color: p.muted,
                ),
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
      child: SizedBox(
        width: 26 * s,
        height: 24 * s,
        child: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 18 * s,
          color: p.muted,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Password strength meter — 4 segments
// ─────────────────────────────────────────────────────────────────────────────
class _StrengthMeter extends StatelessWidget {
  _StrengthMeter({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final filled = p.success;
    final colors = [filled, filled, filled, Color(0xFFA1D1B5)];
    return SizedBox(
      height: 4 * s,
      child: Row(
        children: [
          for (var i = 0; i < colors.length; i++) ...[
            if (i > 0) SizedBox(width: 6 * s),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Actions
// ─────────────────────────────────────────────────────────────────────────────
class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * s),
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
              'Create Account',
              size: 14 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.14 * s,
              lineHeight: 18 * s,
              color: p.surface,
            ),
            SizedBox(width: 8 * s),
            SizedBox(
              width: 13 * s,
              height: 13 * s,
              child: const FittedBox(
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
          Expanded(child: Container(height: 1, color: p.bone)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * s),
            child: figmaText(
              'OR CONTINUE SEAMLESSLY',
              size: 10 * s,
              weight: FontWeight.w500,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: p.muted,
            ),
          ),
          Expanded(child: Container(height: 1, color: p.bone)),
        ],
      ),
    );
  }
}

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
        height: 52 * s,
        decoration: BoxDecoration(
          color: p.panel,
          borderRadius: BorderRadius.circular(12 * s),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 17 * s,
              height: 17 * s,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(Icons.explore_outlined, color: p.body),
              ),
            ),
            SizedBox(width: 9 * s),
            figmaText(
              'Continue as Guest',
              size: 14 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.14 * s,
              lineHeight: 18 * s,
              color: p.ink,
            ),
          ],
        ),
      ),
    );
  }
}
