import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/habit.dart';
import 'habit_providers.dart';

/// Which habit the form is editing (`null` → creating a new one).
final editingHabitIdProvider = StateProvider<String?>((ref) => null);

/// The icon tokens offered by the identity card, in design order.
const habitIconChoices = <String>[
  'book',
  'water',
  'meditation',
  'walk',
  'moon',
  'flame',
];

/// The unit that comes with an icon — picking a symbol sets the dosage unit,
/// so the target card always reads "20 pages / day" or "1500 ml / day" without
/// a second choice the design does not have.
String unitForIcon(String iconKey) => switch (iconKey) {
      'book' => 'pages',
      'water' => 'ml',
      'meditation' => 'mins',
      'walk' => 'mins',
      'moon' => 'mins',
      'flame' => 'times',
      _ => 'times',
    };

/// Quick picks for the target row, per unit.
List<int> presetsForUnit(String unit) => switch (unit) {
      'pages' => const [10, 20, 35, 50],
      'ml' => const [250, 500, 1000, 1500],
      'mins' => const [5, 10, 20, 30],
      _ => const [1, 2, 3, 5],
    };

/// How much a single `+` / `−` tap moves the target.
int stepForUnit(String unit) => switch (unit) {
      'pages' => 5,
      'ml' => 250,
      'mins' => 5,
      _ => 1,
    };

int _defaultForUnit(String unit) => switch (unit) {
      'pages' => 20,
      'ml' => 1500,
      'mins' => 10,
      _ => 1,
    };

/// Day-part chip derived from the reminder (`Morning`, `Evening`, ...).
String categoryFor(String? reminderTime) {
  final hour = int.tryParse((reminderTime ?? '').split(':').first);
  if (hour == null) return 'Anytime';
  if (hour < 12) return 'Morning';
  if (hour < 17) return 'Afternoon';
  if (hour < 21) return 'Evening';
  return 'Night';
}

/// Everything the Add-Habit form holds while it is being filled in.
class HabitDraft {
  const HabitDraft({
    this.title = '',
    this.note = '',
    this.iconKey = 'book',
    this.accent = HabitAccent.terracotta,
    this.rhythm = HabitRhythm.everyDay,
    this.days = const {1, 2, 3, 4, 5, 6, 7},
    this.targetAmount = 20,
    this.reminderEnabled = false,
    this.reminderTime,
  });

  final String title;
  final String note;
  final String iconKey;
  final HabitAccent accent;
  final HabitRhythm rhythm;
  final Set<int> days;
  final int targetAmount;
  final bool reminderEnabled;
  final String? reminderTime;

  /// `pages`, `ml`, `mins`, …
  String get unit => unitForIcon(iconKey);

  /// `Morning` / `Evening` / `Anytime`.
  String get category => categoryFor(reminderEnabled ? reminderTime : null);

  List<int> get presets => presetsForUnit(unit);
  int get step => stepForUnit(unit);

  bool get hasTitle => title.trim().isNotEmpty;

  /// A custom rhythm needs at least one day.
  bool get isValid =>
      hasTitle && (rhythm != HabitRhythm.custom || days.isNotEmpty);

  HabitDraft copyWith({
    String? title,
    String? note,
    String? iconKey,
    HabitAccent? accent,
    HabitRhythm? rhythm,
    Set<int>? days,
    int? targetAmount,
    bool? reminderEnabled,
    String? reminderTime,
    bool clearReminderTime = false,
  }) =>
      HabitDraft(
        title: title ?? this.title,
        note: note ?? this.note,
        iconKey: iconKey ?? this.iconKey,
        accent: accent ?? this.accent,
        rhythm: rhythm ?? this.rhythm,
        days: days ?? this.days,
        targetAmount: targetAmount ?? this.targetAmount,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        reminderTime:
            clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      );

  factory HabitDraft.fromHabit(Habit habit) => HabitDraft(
        title: habit.title,
        note: habit.note,
        iconKey: habit.iconKey,
        accent: habit.accent,
        rhythm: habit.rhythm,
        days: habit.days,
        targetAmount: habit.targetAmount,
        reminderEnabled: habit.reminderTime != null,
        reminderTime: habit.reminderTime,
      );
}

/// The live form state.
final habitDraftProvider =
    NotifierProvider<HabitDraftController, HabitDraft>(HabitDraftController.new);

class HabitDraftController extends Notifier<HabitDraft> {
  @override
  HabitDraft build() {
    final editingId = ref.watch(editingHabitIdProvider);
    if (editingId == null) return const HabitDraft();
    final snapshot = ref.read(habitsProvider).valueOrNull;
    final habit = snapshot?.habitById(editingId);
    return habit == null ? const HabitDraft() : HabitDraft.fromHabit(habit);
  }

  HabitDraft get draft => state;

  void setTitle(String value) => state = state.copyWith(title: value);

  void setNote(String value) => state = state.copyWith(note: value);

  /// Picking a symbol also re-bases the target on that symbol's unit.
  void setIcon(String iconKey) {
    final unit = unitForIcon(iconKey);
    final previousUnit = state.unit;
    final keepAmount = unit == previousUnit;
    state = state.copyWith(
      iconKey: iconKey,
      targetAmount: keepAmount ? state.targetAmount : _defaultForUnit(unit),
    );
  }

  void setAccent(HabitAccent accent) => state = state.copyWith(accent: accent);

  void setRhythm(HabitRhythm rhythm) {
    final days = switch (rhythm) {
      HabitRhythm.everyDay => const {1, 2, 3, 4, 5, 6, 7},
      HabitRhythm.weekdays => const {1, 2, 3, 4, 5},
      HabitRhythm.weekends => const {6, 7},
      HabitRhythm.custom => state.days,
    };
    state = state.copyWith(rhythm: rhythm, days: days);
  }

  /// Tapping a day always switches to a custom rhythm.
  void toggleDay(int weekday) {
    final days = {...state.days};
    if (!days.remove(weekday)) days.add(weekday);
    state = state.copyWith(rhythm: HabitRhythm.custom, days: days);
  }

  void nudgeTarget(int delta) {
    final next = state.targetAmount + delta;
    state = state.copyWith(targetAmount: next < 1 ? 1 : next);
  }

  void setTarget(int amount) =>
      state = state.copyWith(targetAmount: amount < 1 ? 1 : amount);

  void setReminderEnabled(bool enabled) {
    if (enabled) {
      state = state.copyWith(
        reminderEnabled: true,
        reminderTime: state.reminderTime ?? '08:30',
      );
    } else {
      state = state.copyWith(reminderEnabled: false);
    }
  }

  void setReminderTime(String hhmm) => state = state.copyWith(
        reminderTime: hhmm,
        reminderEnabled: true,
      );

  /// Writes the draft to the store. Returns the saved habit, or `null` when the
  /// draft is not valid yet (the screen then asks for a name).
  Future<Habit?> save() async {
    final draft = state;
    if (!draft.isValid) return null;

    final controller = ref.read(habitsProvider.notifier);
    final editingId = ref.read(editingHabitIdProvider);
    final snapshot = ref.read(habitsProvider).valueOrNull;
    final existing = editingId == null ? null : snapshot?.habitById(editingId);

    final reminder = draft.reminderEnabled ? draft.reminderTime : null;

    if (existing != null) {
      final updated = existing.copyWith(
        title: draft.title.trim(),
        note: draft.note.trim(),
        iconKey: draft.iconKey,
        accent: draft.accent,
        rhythm: draft.rhythm,
        days: draft.days,
        targetAmount: draft.targetAmount,
        targetUnit: draft.unit,
        reminderTime: reminder,
        clearReminder: reminder == null,
        category: draft.category,
      );
      await controller.updateHabit(updated);
      return updated;
    }

    final sortOrder = snapshot?.habits
            .map((h) => h.sortOrder)
            .fold<int>(0, (a, b) => a > b ? a : b) ??
        0;
    final habit = Habit(
      id: 'h_${DateTime.now().microsecondsSinceEpoch}',
      title: draft.title.trim(),
      note: draft.note.trim(),
      iconKey: draft.iconKey,
      accent: draft.accent,
      rhythm: draft.rhythm,
      days: draft.days,
      targetAmount: draft.targetAmount,
      targetUnit: draft.unit,
      reminderTime: reminder,
      category: draft.category,
      sortOrder: sortOrder + 1,
      createdAt: DateTime.now(),
    );
    await controller.addHabit(habit);
    return habit;
  }

  /// Clears the form (after saving or discarding).
  void reset() {
    ref.read(editingHabitIdProvider.notifier).state = null;
    state = const HabitDraft();
  }
}
