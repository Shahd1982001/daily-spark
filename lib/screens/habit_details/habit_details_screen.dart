import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_spark/design_system/theme/spark_palette.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/screens/habit_details/widgets/consistency_card.dart';
import 'package:daily_spark/screens/habit_details/widgets/details_hero_card.dart';
import 'package:daily_spark/screens/habit_details/widgets/editorial_card.dart';
import 'package:daily_spark/screens/habit_details/widgets/habit_loop_card.dart';
import 'package:daily_spark/screens/habit_details/widgets/stats_mosaic.dart';
import 'package:daily_spark/screens/habit_details/widgets/today_progress_card.dart';
import 'package:daily_spark/screens/home/widgets/habit_card_style.dart'
    show habitAccentColours, habitIcon, habitTimeLabel;
import 'package:daily_spark/state/details_providers.dart';
import 'package:daily_spark/state/habit_providers.dart';

/// Habit Details — every card is computed from the store for one habit.
///
/// The habit is chosen by [selectedHabitIdProvider] (set from the card the user
/// tapped); when there is no habit at all the screen shows its empty state
/// instead of a fake "Mindful Reading" demo.
class HabitDetailsScreen extends ConsumerWidget {
  const HabitDetailsScreen({
    super.key,
    this.onBack,
    this.onEdit,
    this.onAvatar,
    this.onEditRitual,
    this.onCreateHabit,
  });

  final VoidCallback? onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onAvatar;
  final VoidCallback? onEditRitual;
  final VoidCallback? onCreateHabit;

  static Color get _canvas => p.canvas;
  static Color get _ink => p.ink;
  static Color get _brown => p.body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);
    final detail = ref.watch(habitDetailProvider);

    return Scaffold(
      backgroundColor: _canvas,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 64 * s, bottom: 24 * s),
              child: detail == null
                  ? Padding(
                      padding: EdgeInsets.only(top: 16 * s),
                      child: _emptyState(s),
                    )
                  : _content(context, ref, s, detail),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _DetailsHeader(
              scale: s,
              onBack: onBack,
              onEdit: onEdit,
              onAvatar: onAvatar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    double s,
    HabitDetail detail,
  ) {
    final habit = detail.habit;
    final rider = ref.read(habitsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: _ChipRow(scale: s, habit: habit),
        ),
        SizedBox(height: 12 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: _TitleBlock(scale: s, habit: habit),
        ),
        SizedBox(height: 20 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: DetailsHeroCard(
            scale: s,
            weekPercent: detail.weekPercent,
            streak: detail.streak,
            headline: detail.headline,
            subline: detail.subline,
            trendLabel: detail.trendLabel,
            anchorLabel: _anchorLabel(habit),
            primeTag: habit.reminderTime == null ? 'FLEXIBLE' : 'PRIME TIME',
            isEvening: _isEvening(habit),
          ),
        ),
        SizedBox(height: 24 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: TodayProgressCard(
            scale: s,
            targetLabel: 'Target: ${detail.targetAmount} '
                '${_unitTitle(habit.targetUnit)}',
            amount: detail.amountToday,
            targetAmount: detail.targetAmount,
            unitLabel: habit.targetUnit,
            isDone: detail.doneToday,
            insight: _insight(detail),
            stepSmall: detail.steps.$1,
            stepLarge: detail.steps.$2,
            onDecrement: () => rider.stepAmount(habit.id, -detail.steps.$1),
            onStepSmall: () => rider.stepAmount(habit.id, detail.steps.$1),
            onStepLarge: () => rider.stepAmount(habit.id, detail.steps.$2),
            onToggleComplete: () => rider.toggle(habit.id),
          ),
        ),
        SizedBox(height: 24 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: ConsistencyCard(scale: s, detail: detail),
        ),
        SizedBox(height: 24 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: StatsMosaic(
            scale: s,
            currentRun: detail.streak == 1
                ? '1 Day'
                : '${detail.streak} Days',
            bestRecord: detail.bestStreak == 1
                ? '1 Day'
                : '${detail.bestStreak} Days',
            bestCaption: bestRecordCaption(detail),
            totalLabel: 'TOTAL ${habit.targetUnit.toUpperCase()}',
            totalValue: '${groupDigits(detail.totalAmount)} '
                '${_shortUnit(habit.targetUnit)}',
            totalCaption: detail.totalCompletions == 1
                ? '1 check-in'
                : '${groupDigits(detail.totalCompletions)} check-ins',
            consistency: '${detail.consistency}%',
            sinceLabel: 'Lifetime success rate',
          ),
        ),
        SizedBox(height: 24 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: HabitLoopCard(
            scale: s,
            cadence: _cadence(habit),
            anchor: _anchorLabel(habit),
            dosage: '${habit.targetAmount} ${habit.targetUnit} / day',
            cue: _cue(habit),
          ),
        ),
        if (habit.detailTag.isNotEmpty) ...[
          SizedBox(height: 24 * s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * s),
            child: EditorialCard(
              scale: s,
              tag: 'Current Read',
              title: habit.detailTag,
              quote: habit.note.isEmpty
                  ? '\u201cEvery page is a quiet conversation.\u201d'
                  : '\u201c${habit.note}\u201d',
            ),
          ),
        ],
        SizedBox(height: 24 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: _ActionCenter(
            scale: s,
            onEditRitual: onEditRitual,
            onArchive: () => _archive(context, ref, detail),
            onDelete: () => _confirmDelete(context, ref, detail),
          ),
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    HabitDetail detail,
  ) async {
    await ref.read(habitsProvider.notifier).archiveHabit(detail.habit.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${detail.habit.title} moved to your vault'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    onBack?.call();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    HabitDetail detail,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete this ritual?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: p.ink,
          ),
        ),
        content: Text(
          '${detail.habit.title} and its history will be removed permanently.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            height: 1.4,
            color: p.body,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Keep it',
              style: TextStyle(
                color: p.body,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: p.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(habitsProvider.notifier).deleteHabit(detail.habit.id);
    if (!context.mounted) return;
    onBack?.call();
  }

  // ── Copy helpers (all derived from the habit, never hardcoded) ─────────────

  static String _unitTitle(String unit) =>
      unit.isEmpty ? unit : unit[0].toUpperCase() + unit.substring(1);

  static String _shortUnit(String unit) => switch (unit) {
        'pages' => 'pgs',
        'mins' => 'mins',
        'ml' => 'ml',
        'entry' => 'entries',
        _ => unit,
      };

  static bool _isEvening(Habit habit) {
    final hour = int.tryParse((habit.reminderTime ?? '').split(':').first);
    return hour != null && hour >= 17;
  }

  static String _anchorLabel(Habit habit) {
    final time = habitTimeLabel(habit.reminderTime);
    if (time.isEmpty) return 'Anytime during the day';
    return '$time \u00b7 ${habit.category} anchor';
  }

  static String _cadence(Habit habit) {
    final label = habit.rhythm.label;
    if (habit.rhythm == HabitRhythm.custom) {
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final days = (habit.days.toList()..sort())
          .where((d) => d >= 1 && d <= 7)
          .map((d) => names[d - 1])
          .join(' \u00b7 ');
      return days.isEmpty ? label : '$label ($days)';
    }
    return '$label (${habit.category})';
  }

  static String _cue(Habit habit) {
    final verb = switch (habit.targetUnit) {
      'pages' => 'read',
      'mins' => 'sit for',
      'ml' => 'drink',
      'entry' => 'write',
      _ => 'complete',
    };
    final trigger = habit.category.toLowerCase();
    return '\u201cRight after my $trigger routine, I will $verb '
        '${habit.targetAmount} ${habit.targetUnit}.\u201d';
  }

  static String _insight(HabitDetail detail) {
    final unit = detail.habit.targetUnit;
    if (detail.doneToday) {
      return 'Goal achieved today! ${detail.targetAmount} $unit '
          'absorbed with pure presence.';
    }
    if (detail.amountToday > 0) {
      return '${detail.remaining} $unit to go \u2014 you are '
          '${detail.todayPercent}% there, keep the spark alive.';
    }
    if (detail.streak > 0) {
      return 'One small step today keeps your ${detail.streak}-day '
          'rhythm alive.';
    }
    return 'Start with a single $unit \u2014 momentum follows the first move.';
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _emptyState(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: Container(
        width: 358 * s,
        padding: EdgeInsets.fromLTRB(24 * s, 28 * s, 24 * s, 26 * s),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: p.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48 * s,
              height: 48 * s,
              decoration: BoxDecoration(color: p.chipEmber, shape: BoxShape.circle),
              child: Center(
                child: Image.asset(
                  'assets/brand/spark_logo.png',
                  width: 26 * s,
                  height: 26 * s,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            SizedBox(height: 18 * s),
            figmaText(
              'No ritual to open yet',
              size: 20 * s,
              weight: FontWeight.w600,
              letterSpacing: -0.5 * s,
              lineHeight: 26 * s,
              color: _ink,
            ),
            SizedBox(height: 6 * s),
            figmaText(
              'Create your first habit and this page fills itself: today\u2019s '
              'progress, month consistency, streaks and the loop behind it.',
              size: 13 * s,
              weight: FontWeight.w400,
              lineHeight: 20 * s,
              color: _brown,
              width: 300 * s,
            ),
            SizedBox(height: 18 * s),
            GestureDetector(
              onTap: onCreateHabit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 44 * s,
                padding: EdgeInsets.symmetric(horizontal: 18 * s),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [p.emberLight, p.ember],
                  ),
                  borderRadius: BorderRadius.circular(12 * s),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16 * s, color: Colors.white),
                    SizedBox(width: 6 * s),
                    figmaText(
                      'Create a habit',
                      size: 13 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.13 * s,
                      lineHeight: 18 * s,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Frosted header
// ─────────────────────────────────────────────────────────────────────────────
class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({
    required this.scale,
    this.onBack,
    this.onEdit,
    this.onAvatar,
  });

  final double scale;
  final VoidCallback? onBack;
  final VoidCallback? onEdit;
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
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44 * s,
                    height: 44 * s,
                    decoration: BoxDecoration(
                      color: p.panel,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
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
                  'Habit Details',
                  size: 18 * s,
                  weight: FontWeight.w600,
                  letterSpacing: -0.18 * s,
                  lineHeight: 24 * s,
                  color: p.ink,
                ),
              ),
              Positioned(
                left: 288 * s,
                top: 10 * s,
                child: GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 46 * s,
                    height: 44 * s,
                    decoration: BoxDecoration(
                      color: p.panel,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16 * s,
                      color: p.ink,
                    ),
                  ),
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
// Chips
// ─────────────────────────────────────────────────────────────────────────────
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.scale, required this.habit});

  final double scale;
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Container(
          height: 20 * s,
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
          decoration: BoxDecoration(
            color: p.chipEmber,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          child: Row(
            children: [
              Icon(
                habitIcon(habit.iconKey),
                size: 13 * s,
                color: p.onEmberSoft,
              ),
              SizedBox(width: 4 * s),
              figmaText(
                habit.category.toUpperCase(),
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.5 * s,
                lineHeight: 12 * s,
                color: p.onEmberSoft,
              ),
            ],
          ),
        ),
        Spacer(),
        Container(
          height: 20 * s,
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
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
                  color: habit.isArchived ? p.ochre : p.sage,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6 * s),
              figmaText(
                habit.isArchived ? 'In the Vault' : 'Active Focus',
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.4 * s,
                lineHeight: 12 * s,
                color: p.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Title block
// ─────────────────────────────────────────────────────────────────────────────
class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.scale, required this.habit});

  final double scale;
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final (iconColor, plateColor) = habitAccentColours(habit.accent);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56 * s,
          height: 56 * s,
          decoration: BoxDecoration(
            color: plateColor,
            borderRadius: BorderRadius.circular(16 * s),
          ),
          child: Icon(
            habitIcon(habit.iconKey),
            size: 26 * s,
            color: iconColor,
          ),
        ),
        SizedBox(width: 16 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              figmaText(
                habit.title,
                size: 22 * s,
                weight: FontWeight.w600,
                letterSpacing: -0.55 * s,
                lineHeight: 28 * s,
                color: p.ink,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2 * s),
              figmaText(
                habit.note.isEmpty ? habit.category : habit.note,
                size: 14 * s,
                weight: FontWeight.w400,
                lineHeight: 20 * s,
                color: p.body,
                width: 168 * s,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action center
// ─────────────────────────────────────────────────────────────────────────────
class _ActionCenter extends StatelessWidget {
  const _ActionCenter({
    required this.scale,
    this.onEditRitual,
    this.onArchive,
    this.onDelete,
  });

  final double scale;
  final VoidCallback? onEditRitual;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      children: [
        GestureDetector(
          onTap: onEditRitual,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 358 * s,
            height: 48 * s,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [p.emberLight, p.ember],
              ),
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_outlined, size: 15 * s, color: Colors.white),
                SizedBox(width: 8 * s),
                figmaText(
                  'Edit Habit Ritual',
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
        SizedBox(height: 8 * s),
        GestureDetector(
          onTap: onArchive,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 358 * s,
            height: 44 * s,
            decoration: BoxDecoration(
              color: p.panel,
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 15 * s,
                  color: p.body,
                ),
                SizedBox(width: 8 * s),
                figmaText(
                  'Archive Habit to Vault',
                  size: 14 * s,
                  weight: FontWeight.w600,
                  letterSpacing: 0.14 * s,
                  lineHeight: 18 * s,
                  color: p.ink,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8 * s),
        GestureDetector(
          onTap: onDelete,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 358 * s,
            height: 36 * s,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 14 * s,
                  color: p.error,
                ),
                SizedBox(width: 6 * s),
                figmaText(
                  'Delete Ritual Permanently',
                  size: 12 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.24 * s,
                  lineHeight: 16 * s,
                  color: p.error,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
