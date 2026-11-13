import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;

/// PURE UI — Add Habit ("New Habit").
/// No state container, no network: selections are reported to the parent.
/// Figma: node 126:16871 — 390 × 844 viewport, 1268 of content.
class AddHabitScreen extends StatelessWidget {
  const AddHabitScreen({
    super.key,
    this.onClose,
    this.onAvatar,
    this.onIconSelected,
    this.onAccentSelected,
    this.onRhythmSelected,
    this.onDayToggled,
    this.onDecrement,
    this.onIncrement,
    this.onPresetSelected,
    this.onReminderToggled,
    this.onTimeTap,
    this.onIgnite,
    this.onDiscard,
  });

  final VoidCallback? onClose;
  final VoidCallback? onAvatar;
  final ValueChanged<int>? onIconSelected;
  final ValueChanged<int>? onAccentSelected;
  final ValueChanged<int>? onRhythmSelected;
  final ValueChanged<int>? onDayToggled;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final ValueChanged<int>? onPresetSelected;
  final VoidCallback? onReminderToggled;
  final VoidCallback? onTimeTap;
  final VoidCallback? onIgnite;
  final VoidCallback? onDiscard;

  static Color get _ink => p.ink;
  static Color get _brown => p.body;
  static Color get _muted => p.muted;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    return Scaffold(
      backgroundColor: p.canvas,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 64 * s, bottom: 24 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SubBar(scale: s),
                  SizedBox(height: 16 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _IdentitySection(
                      scale: s,
                      onIconSelected: onIconSelected,
                      onAccentSelected: onAccentSelected,
                    ),
                  ),
                  SizedBox(height: 27 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _RhythmSection(
                      scale: s,
                      onRhythmSelected: onRhythmSelected,
                      onDayToggled: onDayToggled,
                    ),
                  ),
                  SizedBox(height: 30 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _TargetSection(
                      scale: s,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                      onPresetSelected: onPresetSelected,
                    ),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _ReminderSection(
                      scale: s,
                      onReminderToggled: onReminderToggled,
                      onTimeTap: onTimeTap,
                    ),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _SparkTip(scale: s),
                  ),
                  SizedBox(height: 32 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _StickyActions(
                      scale: s,
                      onIgnite: onIgnite,
                      onDiscard: onDiscard,
                    ),
                  ),
                  SizedBox(height: 47 * s),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _AddHabitHeader(scale: s, onClose: onClose, onAvatar: onAvatar),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _AddHabitHeader extends StatelessWidget {
  const _AddHabitHeader({required this.scale, this.onClose, this.onAvatar});

  final double scale;
  final VoidCallback? onClose;
  final VoidCallback? onAvatar;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12 * s, sigmaY: 12 * s),
        child: Container(
          height: 64 * s,
          color: p.canvas.withValues(alpha: 0.8),
          child: Stack(
            children: [
              Positioned(
                left: 16 * s,
                top: 10 * s,
                child: GestureDetector(
                  onTap: onClose,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44 * s,
                    height: 44 * s,
                    decoration: BoxDecoration(
                      color: p.panel,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18 * s,
                      color: p.ink,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 68 * s,
                top: 16 * s,
                child: Image.asset(
                  'assets/brand/home_logo.png',
                  width: 32 * s,
                  height: 32 * s,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                left: 174 * s,
                top: 20 * s,
                child: figmaText(
                  'New Habit',
                  size: 18 * s,
                  weight: FontWeight.w600,
                  letterSpacing: -0.45 * s,
                  lineHeight: 24 * s,
                  color: p.ink,
                ),
              ),
              Positioned(
                left: 342 * s,
                top: 16 * s,
                child: GestureDetector(
                  onTap: onAvatar,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32 * s,
                    height: 32 * s,
                    decoration: BoxDecoration(
                      color: p.emberDeep,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 16 * s,
                      color: Colors.white,
                    ),
                  ),
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
// Sub-bar
// ─────────────────────────────────────────────────────────────────────────────
class _SubBar extends StatelessWidget {
  const _SubBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 8 * s),
      child: Row(
        children: [
          Container(
            height: 24 * s,
            padding: EdgeInsets.symmetric(horizontal: 12 * s),
            decoration: BoxDecoration(
              color: p.bone,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6 * s,
                  height: 6 * s,
                  decoration: BoxDecoration(
                    color: p.emberDeep,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6 * s),
                figmaText(
                  'Daily Ritual',
                  size: 12 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.3 * s,
                  lineHeight: 16 * s,
                  color: p.body,
                ),
              ],
            ),
          ),
          SizedBox(width: 11 * s),
          figmaText(
            '\u2022',
            size: 10 * s,
            weight: FontWeight.w600,
            letterSpacing: 0.4 * s,
            lineHeight: 12 * s,
            color: p.warmBorder,
          ),
          SizedBox(width: 11 * s),
          figmaText(
            'Step 1 of 1',
            size: 12 * s,
            weight: FontWeight.w500,
            letterSpacing: 0.24 * s,
            lineHeight: 16 * s,
            color: p.muted,
          ),
          Spacer(),
          Container(
            height: 20 * s,
            padding: EdgeInsets.symmetric(horizontal: 10 * s),
            decoration: BoxDecoration(
              color: p.goldSoft,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Center(
              child: figmaText(
                'DRAFT SAVED',
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.5 * s,
                lineHeight: 12 * s,
                color: p.onGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 1 — identity
// ─────────────────────────────────────────────────────────────────────────────
class _IdentitySection extends StatelessWidget {
  _IdentitySection({
    required this.scale,
    this.onIconSelected,
    this.onAccentSelected,
  });

  final double scale;
  final ValueChanged<int>? onIconSelected;
  final ValueChanged<int>? onAccentSelected;

  static const _icons = [
    Icons.menu_book_rounded,
    Icons.water_drop_outlined,
    Icons.self_improvement,
    Icons.directions_walk_rounded,
    Icons.bedtime_outlined,
    Icons.local_fire_department_rounded,
  ];

  static get _accents => [
    p.emberDeep,
    p.sage,
    p.ochre,
    p.slate,
  ];

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 221 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          // icon tile + edit badge
          Positioned(
            left: 16 * s,
            top: 16 * s,
            child: Container(
              width: 56 * s,
              height: 56 * s,
              decoration: BoxDecoration(
                color: p.emberSoft,
                borderRadius: BorderRadius.circular(16 * s),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 26 * s,
                color: p.emberDeep,
              ),
            ),
          ),
          Positioned(
            left: 56 * s,
            top: 56 * s,
            child: Container(
              width: 20 * s,
              height: 20 * s,
              decoration: BoxDecoration(
                color: p.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 14 * s,
                  height: 14 * s,
                  decoration: BoxDecoration(
                    color: p.emberDeep,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit, size: 8 * s, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            left: 88 * s,
            top: 16 * s,
            child: figmaText(
              'HABIT TITLE',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: p.muted,
            ),
          ),
          Positioned(
            left: 88 * s,
            top: 30 * s,
            child: figmaText(
              'Mindful Reading',
              size: 22 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.55 * s,
              lineHeight: 28 * s,
              color: p.ink,
            ),
          ),
          Positioned(
            left: 88 * s,
            top: 64 * s,
            child: figmaText(
              'Building intellectual stillness & depth',
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: p.muted,
            ),
          ),
          // symbol tokens
          Positioned(
            left: 16 * s,
            top: 100 * s,
            child: figmaText(
              'SYMBOL TOKEN',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: p.muted,
            ),
          ),
          Positioned(
            left: 16 * s,
            top: 116 * s,
            child: Row(
              children: [
                for (var i = 0; i < _icons.length; i++) ...[
                  if (i > 0) SizedBox(width: 8 * s),
                  GestureDetector(
                    onTap: () => onIconSelected?.call(i),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 47 * s,
                      height: 44 * s,
                      decoration: BoxDecoration(
                        color: i == 0 ? p.ember : p.container,
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Icon(
                        _icons[i],
                        size: 20 * s,
                        color: i == 0 ? Colors.white : p.body,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // aura accents
          Positioned(
            left: 16 * s,
            top: 187 * s,
            child: figmaText(
              'AURA ACCENT',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: p.muted,
            ),
          ),
          Positioned(
            left: 216 * s,
            top: 181 * s,
            child: Row(
              children: [
                for (var i = 0; i < _accents.length; i++) ...[
                  if (i > 0) SizedBox(width: 10 * s),
                  GestureDetector(
                    onTap: () => onAccentSelected?.call(i),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 24 * s,
                      height: 24 * s,
                      decoration: BoxDecoration(
                        color: _accents[i],
                        shape: BoxShape.circle,
                      ),
                      child: i == 0
                          ? Icon(Icons.check_rounded, size: 12 * s, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 2 — rhythm
// ─────────────────────────────────────────────────────────────────────────────
class _RhythmSection extends StatelessWidget {
  const _RhythmSection({
    required this.scale,
    this.onRhythmSelected,
    this.onDayToggled,
  });

  final double scale;
  final ValueChanged<int>? onRhythmSelected;
  final ValueChanged<int>? onDayToggled;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const rhythms = ['Every Day', 'Weekdays', 'Weekends', 'Custom'];
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      width: 358 * s,
      height: 187 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 16 * s,
            child: figmaText(
              'Rhythm & Repeat',
              size: 18 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.45 * s,
              lineHeight: 24 * s,
              color: p.ink,
            ),
          ),
          Positioned(
            left: 269 * s,
            top: 20 * s,
            child: Container(
              height: 16 * s,
              padding: EdgeInsets.symmetric(horizontal: 8 * s),
              decoration: BoxDecoration(
                color: p.mint,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Center(
                child: figmaText(
                  'Daily Ritual',
                  size: 10 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.4 * s,
                  lineHeight: 12 * s,
                  color: p.sage,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16 * s,
            top: 42 * s,
            child: figmaText(
              'Small steps compound into permanent transformations',
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: p.muted,
            ),
          ),
          // segmented presets
          Positioned(
            left: 16 * s,
            top: 74 * s,
            child: Container(
              width: 326 * s,
              height: 40 * s,
              decoration: BoxDecoration(
                color: p.panel,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              padding: EdgeInsets.all(4 * s),
              child: Row(
                children: [
                  for (var i = 0; i < rhythms.length; i++) ...[
                    if (i > 0) SizedBox(width: 6 * s),
                    GestureDetector(
                      onTap: () => onRhythmSelected?.call(i),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 75 * s,
                        height: 32 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i == 0 ? p.ember : Colors.transparent,
                          borderRadius: BorderRadius.circular(8 * s),
                        ),
                        child: figmaText(
                          rhythms[i],
                          size: 12 * s,
                          weight: i == 0 ? FontWeight.w600 : FontWeight.w500,
                          letterSpacing: 0.24 * s,
                          lineHeight: 16 * s,
                          color: i == 0 ? Colors.white : p.body,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // day toggles
          Positioned(
            left: 16 * s,
            top: 130 * s,
            child: Row(
              children: [
                for (var i = 0; i < days.length; i++) ...[
                  if (i > 0) SizedBox(width: 4 * s),
                  GestureDetector(
                    onTap: () => onDayToggled?.call(i),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 43 * s,
                      height: 37 * s,
                      decoration: BoxDecoration(
                        color: p.success,
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          figmaText(
                            days[i],
                            size: 10 * s,
                            weight: FontWeight.w600,
                            letterSpacing: 0.4 * s,
                            lineHeight: 12 * s,
                            color: p.surface,
                          ),
                          SizedBox(height: 2 * s),
                          Icon(Icons.check_rounded, size: 10 * s, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 3 — daily target
// ─────────────────────────────────────────────────────────────────────────────
class _TargetSection extends StatelessWidget {
  const _TargetSection({
    required this.scale,
    this.onDecrement,
    this.onIncrement,
    this.onPresetSelected,
  });

  final double scale;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final ValueChanged<int>? onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const presets = ['10 pages', '20 pages', '35 pages', '50 pages'];
    const widths = [82.0, 84.0, 83.0, 84.0];
    return Container(
      width: 358 * s,
      height: 207 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 16 * s,
            child: figmaText(
              'Daily Target',
              size: 18 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.45 * s,
              lineHeight: 24 * s,
              color: p.ink,
            ),
          ),
          Positioned(
            left: 285 * s,
            top: 25 * s,
            child: Container(
              height: 24 * s,
              padding: EdgeInsets.symmetric(horizontal: 10 * s),
              decoration: BoxDecoration(
                color: p.goldSoft,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Center(
                child: figmaText(
                  'Pages',
                  size: 12 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.24 * s,
                  lineHeight: 16 * s,
                  color: p.ochre,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16 * s,
            top: 42 * s,
            child: figmaText(
              'Flexible metric to measure steady momentum',
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: p.muted,
            ),
          ),
          // stepper
          Positioned(
            left: 16 * s,
            top: 74 * s,
            child: Container(
              width: 326 * s,
              height: 69 * s,
              decoration: BoxDecoration(
                color: p.panel,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 16 * s,
                    top: 8 * s,
                    child: figmaText(
                      'TARGET DOSAGE',
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.5 * s,
                      lineHeight: 12 * s,
                      color: p.muted,
                    ),
                  ),
                  Positioned(
                    left: 16 * s,
                    top: 20 * s,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        figmaText(
                          '20',
                          size: 40 * s,
                          weight: FontWeight.w700,
                          letterSpacing: -1 * s,
                          lineHeight: 40 * s,
                          color: p.ink,
                        ),
                        SizedBox(width: 6 * s),
                        figmaText(
                          'pages / day',
                          size: 16 * s,
                          weight: FontWeight.w500,
                          letterSpacing: -0.08 * s,
                          lineHeight: 22 * s,
                          color: p.muted,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 222 * s,
                    top: 14 * s,
                    child: GestureDetector(
                      onTap: onDecrement,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40 * s,
                        height: 40 * s,
                        decoration: BoxDecoration(
                          color: p.bone,
                          borderRadius: BorderRadius.circular(12 * s),
                        ),
                        child: Icon(Icons.remove_rounded,
                            size: 16 * s, color: p.ink),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 270 * s,
                    top: 14 * s,
                    child: GestureDetector(
                      onTap: onIncrement,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40 * s,
                        height: 40 * s,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [p.emberLight, p.ember],
                          ),
                          borderRadius: BorderRadius.circular(12 * s),
                        ),
                        child: Icon(Icons.add_rounded, size: 16 * s, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // quick presets
          Positioned(
            left: 16 * s,
            top: 159 * s,
            child: SizedBox(
              width: 326 * s,
              height: 28 * s,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: presets.length,
                separatorBuilder: (_, __) => SizedBox(width: 7 * s),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => onPresetSelected?.call(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: widths[i] * s,
                    height: 28 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == 1 ? p.ember : p.container,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: figmaText(
                      presets[i],
                      size: 12 * s,
                      weight: i == 1 ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.24 * s,
                      lineHeight: 16 * s,
                      color: i == 1 ? Colors.white : p.body,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 4 — gentle reminder
// ─────────────────────────────────────────────────────────────────────────────
class _ReminderSection extends StatelessWidget {
  const _ReminderSection({
    required this.scale,
    this.onReminderToggled,
    this.onTimeTap,
  });

  final double scale;
  final VoidCallback? onReminderToggled;
  final VoidCallback? onTimeTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 138 * s,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4 * s,
            offset: Offset(0, 1 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 16 * s,
            child: Container(
              width: 40 * s,
              height: 40 * s,
              decoration: BoxDecoration(
                color: p.mint,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 19 * s,
                color: p.pine,
              ),
            ),
          ),
          Positioned(
            left: 64 * s,
            top: 17 * s,
            child: figmaText(
              'Daily Reminder',
              size: 16 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.4 * s,
              lineHeight: 22 * s,
              color: p.ink,
            ),
          ),
          Positioned(
            left: 64 * s,
            top: 39 * s,
            child: figmaText(
              'A quiet chime to anchor your focus',
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: p.muted,
            ),
          ),
          // switch
          Positioned(
            right: 16 * s,
            top: 22 * s,
            child: GestureDetector(
              onTap: onReminderToggled,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 44 * s,
                height: 24 * s,
                decoration: BoxDecoration(
                  color: p.ember,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 2 * s),
                    child: Container(
                      width: 20 * s,
                      height: 20 * s,
                      decoration: BoxDecoration(
                        color: p.surface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // scheduled moment
          Positioned(
            left: 16 * s,
            top: 72 * s,
            child: Container(
              width: 326 * s,
              height: 50 * s,
              decoration: BoxDecoration(
                color: p.panel,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 12 * s,
                    top: 17 * s,
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 15 * s,
                          color: p.muted,
                        ),
                        SizedBox(width: 8 * s),
                        figmaText(
                          'Scheduled Moment',
                          size: 12 * s,
                          weight: FontWeight.w500,
                          letterSpacing: 0.24 * s,
                          lineHeight: 16 * s,
                          color: p.ink,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12 * s,
                    top: 8 * s,
                    child: GestureDetector(
                      onTap: onTimeTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 112 * s,
                        height: 34 * s,
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(8 * s),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            figmaText(
                              '08:30 PM',
                              size: 16 * s,
                              weight: FontWeight.w600,
                              letterSpacing: -0.08 * s,
                              lineHeight: 22 * s,
                              color: p.emberDeep,
                            ),
                            SizedBox(width: 6 * s),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16 * s,
                              color: p.emberDeep,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 5 — spark tip
// ─────────────────────────────────────────────────────────────────────────────
class _SparkTip extends StatelessWidget {
  const _SparkTip({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 111 * s,
      padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 16 * s),
      decoration: BoxDecoration(
        color: p.goldSoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              color: p.goldSoft,
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 17 * s,
              color: p.onGold,
            ),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                figmaText(
                  'Spark Stacking Tip',
                  size: 14 * s,
                  weight: FontWeight.w600,
                  letterSpacing: -0.35 * s,
                  lineHeight: 18 * s,
                  color: p.onGold,
                ),
                SizedBox(height: 2 * s),
                figmaText(
                  'Tie this ritual directly after an established loop: '
                  '\u201cRight after I turn off the bedside lamp, I will read '
                  '20 pages.\u201d',
                  size: 12 * s,
                  weight: FontWeight.w400,
                  letterSpacing: 0.12 * s,
                  lineHeight: 16 * s,
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
// Section 6 — sticky actions
// ─────────────────────────────────────────────────────────────────────────────
class _StickyActions extends StatelessWidget {
  const _StickyActions({required this.scale, this.onIgnite, this.onDiscard});

  final double scale;
  final VoidCallback? onIgnite;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      children: [
        GestureDetector(
          onTap: onIgnite,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 358 * s,
            height: 56 * s,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [p.emberLight, p.ember],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: p.ember.withValues(alpha: 0.28),
                  blurRadius: 18 * s,
                  offset: Offset(0, 6 * s),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 15 * s, color: Colors.white),
                SizedBox(width: 8 * s),
                figmaText(
                  'Ignite This Habit',
                  size: 14 * s,
                  weight: FontWeight.w600,
                  letterSpacing: 0.14 * s,
                  lineHeight: 18 * s,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4 * s),
        GestureDetector(
          onTap: onDiscard,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 32 * s,
            child: Center(
              child: figmaText(
                'Discard and return',
                size: 12 * s,
                weight: FontWeight.w500,
                letterSpacing: 0.24 * s,
                lineHeight: 16 * s,
                color: p.muted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
