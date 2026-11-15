import 'package:flutter/material.dart';

import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';

/// Shared presentation helpers for a [Habit] — used by Home cards and
/// Habits tiles so a habit never looks different between screens.

IconData habitIcon(String key) => switch (key) {
      'book' => Icons.menu_book_outlined,
      'water' => Icons.water_drop_outlined,
      'meditation' => Icons.self_improvement,
      'walk' => Icons.directions_walk_rounded,
      'journal' => Icons.edit_note_rounded,
      'moon' => Icons.nightlight_round,
      'flame' => Icons.local_fire_department_rounded,
      'work' => Icons.work_outline_rounded,
      'language' => Icons.translate_rounded,
      _ => Icons.bolt_rounded,
    };

/// `HH:mm` → `8:00 AM` (empty when there is no reminder).
String habitTimeLabel(String? hhmm) {
  if (hhmm == null) return '';
  final parts = hhmm.split(':');
  if (parts.length != 2) return '';
  final hour = int.tryParse(parts[0]);
  if (hour == null) return '';
  final suffix = hour >= 12 ? 'PM' : 'AM';
  final display = hour % 12 == 0 ? 12 : hour % 12;
  return '$display:${parts[1]} $suffix';
}

/// Icon colour + plate colour for an accent token.
(Color, Color) habitAccentColours(HabitAccent accent) => switch (accent) {
      HabitAccent.sage => (p.success, p.mintSoft),
      HabitAccent.terracotta => (p.emberDark, p.creamSoft),
      HabitAccent.ochre => (p.ochre, p.chipGold),
      HabitAccent.slate => (p.body, p.bone),
    };

/// Meta chips for the Home card (`10 mins`, `8:00 AM`, …).
List<String> habitMetaParts(Habit habit) => [
      if (habit.targetAmount > 1) '${habit.targetAmount} ${habit.targetUnit}',
      if (habit.detailTag.isNotEmpty) habit.detailTag,
      if (habitTimeLabel(habit.reminderTime).isNotEmpty)
        habitTimeLabel(habit.reminderTime),
      if (habit.targetAmount <= 1 &&
          habit.detailTag.isEmpty &&
          habit.reminderTime == null)
        habit.category,
    ];

/// Single meta line for the Habits tile (`10 mins · Everyday · 8:00 AM`).
String habitMetaLine(Habit habit) {
  final parts = <String>[
    if (habit.targetAmount > 1) '${habit.targetAmount} ${habit.targetUnit}',
    habit.rhythm.label,
    if (habit.detailTag.isNotEmpty) habit.detailTag,
    if (habitTimeLabel(habit.reminderTime).isNotEmpty)
      habitTimeLabel(habit.reminderTime),
  ];
  if (parts.isEmpty) return habit.category;
  return parts.join(' \\u00b7 ');
}
