import 'package:daily_spark/l10n/strings.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/screens/home/widgets/habit_card_style.dart'
    show habitAccentColours, habitIcon, habitTimeLabel;
import 'package:daily_spark/state/add_habit_providers.dart';

/// Add / Edit Habit — the form is bound to [habitDraftProvider], so every tap
/// (symbol, aura, rhythm, days, dosage, reminder) is a real state change and
/// "Ignite" writes to the store.
///
/// Creating: empty draft. Editing: `editingHabitIdProvider` is set first, the
/// draft loads from the habit and the CTA becomes "Save Changes".
class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({
    super.key,
    this.onClose,
    this.onAvatar,
    this.onSaved,
    this.onDiscard,
  });

  final VoidCallback? onClose;
  final VoidCallback? onAvatar;
  final ValueChanged<Habit>? onSaved;
  final VoidCallback? onDiscard;

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  late final TextEditingController _title;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(habitDraftProvider);
    _title = TextEditingController(text: draft.title);
    _note = TextEditingController(text: draft.note);
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _isEditing => ref.read(editingHabitIdProvider) != null;

  Future<void> _pickTime() async {
    final draft = ref.read(habitDraftProvider);
    final parts = (draft.reminderTime ?? '08:30').split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 30) : 30,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: tr('Reminder time'),
      builder: (dialogContext, child) => Theme(
        data: Theme.of(dialogContext).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: p.ember,
            brightness: p.dark ? Brightness.dark : Brightness.light,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null) return;
    final hhmm = '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
    ref.read(habitDraftProvider.notifier).setReminderTime(hhmm);
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final habit = await ref.read(habitDraftProvider.notifier).save();
    if (habit == null) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              ref.read(habitDraftProvider).hasTitle
                  ? 'Pick at least one day for a custom rhythm'
                  : 'Give your ritual a name first',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    widget.onSaved?.call(habit);
    ref.read(habitDraftProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);
    final draft = ref.watch(habitDraftProvider);
    final notifier = ref.read(habitDraftProvider.notifier);

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
                  _SubBar(
                    scale: s,
                    category: draft.category,
                    editing: _isEditing,
                    hasContent: draft.hasTitle,
                  ),
                  SizedBox(height: 16 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _IdentitySection(
                      scale: s,
                      draft: draft,
                      titleController: _title,
                      noteController: _note,
                      onIconSelected: (key) => notifier.setIcon(key),
                      onAccentSelected: (accent) => notifier.setAccent(accent),
                      onTitleChanged: notifier.setTitle,
                      onNoteChanged: notifier.setNote,
                    ),
                  ),
                  SizedBox(height: 27 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _RhythmSection(
                      scale: s,
                      draft: draft,
                      onRhythmSelected: notifier.setRhythm,
                      onDayToggled: notifier.toggleDay,
                    ),
                  ),
                  SizedBox(height: 30 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _TargetSection(
                      scale: s,
                      draft: draft,
                      onDecrement: () => notifier.nudgeTarget(-draft.step),
                      onIncrement: () => notifier.nudgeTarget(draft.step),
                      onPresetSelected: notifier.setTarget,
                    ),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _ReminderSection(
                      scale: s,
                      draft: draft,
                      onReminderToggled: () => notifier
                          .setReminderEnabled(!draft.reminderEnabled),
                      onTimeTap: _pickTime,
                    ),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _SparkTip(scale: s, draft: draft),
                  ),
                  SizedBox(height: 32 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _StickyActions(
                      scale: s,
                      label: _isEditing ? 'Save Changes' : 'Ignite This Habit',
                      enabled: draft.hasTitle,
                      onIgnite: _save,
                      onDiscard: widget.onDiscard ?? widget.onClose,
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
            child: _AddHabitHeader(
              scale: s,
              title: _isEditing ? 'Edit Habit' : 'New Habit',
              onClose: widget.onClose,
              onAvatar: widget.onAvatar,
            ),
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
  const _AddHabitHeader({
    required this.scale,
    required this.title,
    this.onClose,
    this.onAvatar,
  });

  final double scale;
  final String title;
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
                top: 20 * s,
                child: figmaText(
                  title,
                  size: 18 * s,
                  weight: FontWeight.w600,
                  letterSpacing: -0.18 * s,
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
                      color: p.dark ? p.chipEmber : p.emberDeep,
                      shape: BoxShape.circle,
                      border: p.dark
                          ? Border.all(
                              color: p.ember.withValues(alpha: 0.30),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: 16 * s,
                      color: p.dark ? p.ember : Colors.white,
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
// Sub bar
// ─────────────────────────────────────────────────────────────────────────────
class _SubBar extends StatelessWidget {
  const _SubBar({
    required this.scale,
    required this.category,
    required this.editing,
    required this.hasContent,
  });

  final double scale;
  final String category;
  final bool editing;
  final bool hasContent;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final badge = editing
        ? 'EDITING'
        : (hasContent ? 'DRAFT SAVED' : 'NEW RITUAL');
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 8 * s),
      child: Row(
        children: [
          Container(
            height: 24 * s,
            constraints: BoxConstraints(maxWidth: 112 * s),
            padding: EdgeInsets.symmetric(horizontal: 12 * s),
            decoration: BoxDecoration(
              color: p.bone,
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
                SizedBox(width: 6 * s),
                Flexible(
                  child: figmaText(
                    category,
                    size: 12 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.3 * s,
                    lineHeight: 16 * s,
                    color: p.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
          Expanded(
            child: figmaText(
              'Step 1 of 1',
              size: 12 * s,
              weight: FontWeight.w500,
              letterSpacing: 0.24 * s,
              lineHeight: 16 * s,
              color: p.muted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            height: 20 * s,
            padding: EdgeInsets.symmetric(horizontal: 10 * s),
            decoration: BoxDecoration(
              color: p.chipGold,
              borderRadius: BorderRadius.all(Radius.circular(999)),
              border: p.dark
                  ? Border.all(color: p.goldBorder, width: 1)
                  : null,
            ),
            child: Center(
              child: figmaText(
                badge,
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.5 * s,
                lineHeight: 12 * s,
                color: p.dark ? p.onEmberSoft : p.onGold,
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
  const _IdentitySection({
    required this.scale,
    required this.draft,
    required this.titleController,
    required this.noteController,
    this.onIconSelected,
    this.onAccentSelected,
    this.onTitleChanged,
    this.onNoteChanged,
  });

  final double scale;
  final HabitDraft draft;
  final TextEditingController titleController;
  final TextEditingController noteController;
  final ValueChanged<String>? onIconSelected;
  final ValueChanged<HabitAccent>? onAccentSelected;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onNoteChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final (iconColor, plateColor) = habitAccentColours(draft.accent);
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
                color: plateColor,
                borderRadius: BorderRadius.circular(16 * s),
              ),
              child: Icon(
                habitIcon(draft.iconKey),
                size: 26 * s,
                color: iconColor,
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
          // input well (dark frame keeps a raised field here)
          Positioned(
            left: 16 * s,
            top: 20 * s,
            child: Container(
              width: 326 * s,
              height: 76 * s,
              decoration: BoxDecoration(
                color: p.dark ? p.raised : Colors.transparent,
                borderRadius: BorderRadius.circular(16 * s),
                border: p.dark
                    ? Border.all(
                        color: p.bone.withValues(alpha: 0.55), width: 1 * s)
                    : null,
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
            width: 232 * s,
            child: TextField(
              controller: titleController,
              onChanged: onTitleChanged,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: p.ember,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 22 * s,
                height: 28 / 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.55 * s,
                color: p.ink,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: tr('Name your ritual'),
                hintStyle: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.55 * s,
                  color: p.muted.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          Positioned(
            left: 88 * s,
            top: 64 * s,
            width: 232 * s,
            child: TextField(
              controller: noteController,
              onChanged: onNoteChanged,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: p.ember,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12 * s,
                height: 16 / 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.12 * s,
                color: p.body,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: tr('What is this ritual for?'),
                hintStyle: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12 * s,
                  color: p.muted.withValues(alpha: 0.75),
                ),
              ),
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
                for (var i = 0; i < habitIconChoices.length; i++) ...[
                  if (i > 0) SizedBox(width: 8 * s),
                  GestureDetector(
                    onTap: () => onIconSelected?.call(habitIconChoices[i]),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 47 * s,
                      height: 44 * s,
                      decoration: BoxDecoration(
                        color: habitIconChoices[i] == draft.iconKey
                            ? p.ember
                            : p.container,
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Icon(
                        habitIcon(habitIconChoices[i]),
                        size: 20 * s,
                        color: habitIconChoices[i] == draft.iconKey
                            ? Colors.white
                            : p.body,
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
                for (var i = 0; i < HabitAccent.values.length; i++) ...[
                  if (i > 0) SizedBox(width: 10 * s),
                  GestureDetector(
                    onTap: () =>
                        onAccentSelected?.call(HabitAccent.values[i]),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 24 * s,
                      height: 24 * s,
                      decoration: BoxDecoration(
                        color: _accentColour(HabitAccent.values[i]),
                        shape: BoxShape.circle,
                        border: HabitAccent.values[i] == draft.accent
                            ? Border.all(
                                color: p.dark
                                    ? const Color(0xFFF5F3EF)
                                    : p.emberDeep,
                                width: 2 * s)
                            : null,
                      ),
                      child: HabitAccent.values[i] == draft.accent
                          ? Icon(Icons.check_rounded,
                              size: 11 * s, color: Colors.white)
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

  Color _accentColour(HabitAccent accent) => switch (accent) {
        HabitAccent.terracotta => p.emberDeep,
        HabitAccent.sage => p.sage,
        HabitAccent.ochre => p.ochre,
        HabitAccent.slate => p.dark ? const Color(0xFF8E8A85) : p.slate,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 2 — rhythm
// ─────────────────────────────────────────────────────────────────────────────
class _RhythmSection extends StatelessWidget {
  const _RhythmSection({
    required this.scale,
    required this.draft,
    this.onRhythmSelected,
    this.onDayToggled,
  });

  final double scale;
  final HabitDraft draft;
  final ValueChanged<HabitRhythm>? onRhythmSelected;
  final ValueChanged<int>? onDayToggled;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final s = scale;
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
                color: p.chipGreen,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Center(
                child: figmaText(
                  draft.category,
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
                  for (var i = 0; i < HabitRhythm.values.length; i++) ...[
                    if (i > 0) SizedBox(width: 6 * s),
                    GestureDetector(
                      onTap: () =>
                          onRhythmSelected?.call(HabitRhythm.values[i]),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 75 * s,
                        height: 32 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: HabitRhythm.values[i] == draft.rhythm
                              ? p.ember
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8 * s),
                        ),
                        child: figmaText(
                          HabitRhythm.values[i].label,
                          size: 12 * s,
                          weight: HabitRhythm.values[i] == draft.rhythm
                              ? FontWeight.w600
                              : FontWeight.w500,
                          letterSpacing: 0.24 * s,
                          lineHeight: 16 * s,
                          color: HabitRhythm.values[i] == draft.rhythm
                              ? Colors.white
                              : p.body,
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
                for (var i = 0; i < _days.length; i++) ...[
                  if (i > 0) SizedBox(width: 4 * s),
                  GestureDetector(
                    onTap: () => onDayToggled?.call(i + 1),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 43 * s,
                      height: 37 * s,
                      decoration: BoxDecoration(
                        color: draft.days.contains(i + 1)
                            ? (p.dark ? p.chipGreen : p.success)
                            : p.panel,
                        borderRadius: BorderRadius.circular(12 * s),
                        border: draft.days.contains(i + 1) && p.dark
                            ? Border.all(
                                color: p.sage.withValues(alpha: 0.35),
                                width: 1 * s)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          figmaText(
                            Strings.locale.languageCode == 'en' ? _days[i] : tr(const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'][i]),
                            size: 10 * s,
                            weight: FontWeight.w600,
                            letterSpacing: 0.4 * s,
                            lineHeight: 12 * s,
                            color: draft.days.contains(i + 1)
                                ? (p.dark ? p.sage : p.surface)
                                : p.muted,
                          ),
                          SizedBox(height: 2 * s),
                          Icon(
                            draft.days.contains(i + 1)
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            size: 10 * s,
                            color: draft.days.contains(i + 1)
                                ? (p.dark ? p.sage : Colors.white)
                                : p.muted.withValues(alpha: 0.6),
                          ),
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
    required this.draft,
    this.onDecrement,
    this.onIncrement,
    this.onPresetSelected,
  });

  final double scale;
  final HabitDraft draft;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final ValueChanged<int>? onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final presets = draft.presets;
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
                color: p.chipGold,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Center(
                child: figmaText(
                  _unitTitle(draft.unit),
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
                          '${draft.targetAmount}',
                          size: 40 * s,
                          weight: FontWeight.w700,
                          letterSpacing: -1 * s,
                          lineHeight: 40 * s,
                          color: p.ink,
                        ),
                        SizedBox(width: 6 * s),
                        figmaText(
                          tr('{unit} / day', {'unit': tr(draft.unit)}),
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
                        child: Icon(Icons.add_rounded,
                            size: 16 * s, color: Colors.white),
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
                  onTap: () => onPresetSelected?.call(presets[i]),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 82 * s),
                    padding: EdgeInsets.symmetric(horizontal: 14 * s),
                    height: 28 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: presets[i] == draft.targetAmount
                          ? p.ember
                          : p.container,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    child: figmaText(
                      '${presets[i]} ${tr(draft.unit)}',
                      size: 12 * s,
                      weight: presets[i] == draft.targetAmount
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: 0.24 * s,
                      lineHeight: 16 * s,
                      color: presets[i] == draft.targetAmount
                          ? Colors.white
                          : p.body,
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

  static String _unitTitle(String unit) =>
      unit.isEmpty ? unit : (Strings.locale.languageCode == 'en' ? unit[0].toUpperCase() + unit.substring(1) : tr(unit));
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 4 — gentle reminder
// ─────────────────────────────────────────────────────────────────────────────
class _ReminderSection extends StatelessWidget {
  const _ReminderSection({
    required this.scale,
    required this.draft,
    this.onReminderToggled,
    this.onTimeTap,
  });

  final double scale;
  final HabitDraft draft;
  final VoidCallback? onReminderToggled;
  final VoidCallback? onTimeTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final enabled = draft.reminderEnabled;
    final timeLabel = habitTimeLabel(draft.reminderTime);
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
                color: enabled ? p.chipGreen : p.panel,
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Icon(
                enabled
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none_rounded,
                size: 19 * s,
                color: enabled ? p.pine : p.muted,
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44 * s,
                height: 24 * s,
                decoration: BoxDecoration(
                  color: enabled ? p.ember : p.container,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: Align(
                  alignment:
                      enabled ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2 * s),
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
            child: GestureDetector(
              onTap: enabled ? onTimeTap : onReminderToggled,
              behavior: HitTestBehavior.opaque,
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
                      child: Container(
                        width: 112 * s,
                        height: 34 * s,
                        decoration: BoxDecoration(
                          color: enabled ? p.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(8 * s),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: figmaText(
                                enabled
                                    ? (timeLabel.isEmpty
                                        ? 'Set a time'
                                        : timeLabel)
                                    : 'No reminder',
                                size: enabled ? 16 * s : 13 * s,
                                weight: FontWeight.w600,
                                letterSpacing: -0.08 * s,
                                lineHeight: 22 * s,
                                color: enabled ? p.emberDeep : p.muted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (enabled) ...[
                              SizedBox(width: 6 * s),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16 * s,
                                color: p.emberDeep,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
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
// Section 5 — spark tip
// ─────────────────────────────────────────────────────────────────────────────
class _SparkTip extends StatelessWidget {
  const _SparkTip({required this.scale, required this.draft});

  final double scale;
  final HabitDraft draft;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final verb = tr(switch (draft.unit) {
      'pages' => 'read',
      'ml' => 'drink',
      'mins' => 'sit for',
      'entry' => 'write',
      _ => 'complete',
    });
    final cue = tr('Right after my {category} routine, I will {verb} {amount} {unit}.', {
      'category': tr(draft.category).toLowerCase(),
      'verb': verb,
      'amount': '${draft.targetAmount}',
      'unit': tr(draft.unit),
    });
    return Container(
      width: 358 * s,
      height: 111 * s,
      padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 16 * s),
      decoration: BoxDecoration(
        color: p.chipGold,
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32 * s,
            height: 32 * s,
            decoration: BoxDecoration(
              color: p.chipGold,
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
                  tr('Tie this ritual directly after an established loop: {cue}',
                    {'cue': cue}),
                  size: 12 * s,
                  weight: FontWeight.w400,
                  letterSpacing: 0.12 * s,
                  lineHeight: 16 * s,
                  color: p.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
  const _StickyActions({
    required this.scale,
    required this.label,
    required this.enabled,
    this.onIgnite,
    this.onDiscard,
  });

  final double scale;
  final String label;
  final bool enabled;
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
              gradient: enabled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [p.emberLight, p.ember],
                    )
                  : null,
              color: enabled ? null : p.container,
              borderRadius: BorderRadius.all(Radius.circular(999)),
              boxShadow: [
                BoxShadow(
                  color: p.ember.withValues(alpha: enabled ? 0.28 : 0),
                  blurRadius: 18 * s,
                  offset: Offset(0, 6 * s),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 15 * s,
                  color: enabled ? Colors.white : p.muted,
                ),
                SizedBox(width: 8 * s),
                figmaText(
                  label,
                  size: 14 * s,
                  weight: FontWeight.w600,
                  letterSpacing: 0.14 * s,
                  lineHeight: 18 * s,
                  color: enabled ? Colors.white : p.muted,
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
