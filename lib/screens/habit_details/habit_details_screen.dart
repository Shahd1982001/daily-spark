import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/habit_details/widgets/consistency_card.dart';
import 'package:daily_spark/screens/habit_details/widgets/details_hero_card.dart';
import 'package:daily_spark/screens/habit_details/widgets/editorial_card.dart';
import 'package:daily_spark/screens/habit_details/widgets/habit_loop_card.dart';
import 'package:daily_spark/screens/habit_details/widgets/stats_mosaic.dart';
import 'package:daily_spark/screens/habit_details/widgets/today_progress_card.dart';

/// PURE UI — Habit Details.
/// No state container, no network: taps are reported to the parent.
/// Figma: node 126:16640 — 390 × 844 viewport, 2350 of scrollable content.
class HabitDetailsScreen extends StatelessWidget {
  const HabitDetailsScreen({
    super.key,
    this.onBack,
    this.onEdit,
    this.onAvatar,
    this.onDecrement,
    this.onPlusFive,
    this.onPlusTen,
    this.onToggleComplete,
    this.onEditRitual,
    this.onArchive,
    this.onDelete,
  });

  final VoidCallback? onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onAvatar;
  final VoidCallback? onDecrement;
  final VoidCallback? onPlusFive;
  final VoidCallback? onPlusTen;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEditRitual;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  static const _canvas = Color(0xFFF8FAF6);
  static const _ink = Color(0xFF191C1A);
  static const _brown = Color(0xFF57423B);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final s = (width / 390).clamp(0.86, 1.25);

    return Scaffold(
      backgroundColor: _canvas,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 64 * s, bottom: 24 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _ChipRow(scale: s),
                  ),
                  SizedBox(height: 12 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _TitleBlock(scale: s),
                  ),
                  SizedBox(height: 20 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: DetailsHeroCard(scale: s),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: TodayProgressCard(
                      scale: s,
                      onDecrement: onDecrement,
                      onPlusFive: onPlusFive,
                      onPlusTen: onPlusTen,
                      onToggleComplete: onToggleComplete,
                    ),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: ConsistencyCard(scale: s),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: StatsMosaic(scale: s),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: HabitLoopCard(scale: s),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: EditorialCard(scale: s),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _ActionCenter(
                      scale: s,
                      onEditRitual: onEditRitual,
                      onArchive: onArchive,
                      onDelete: onDelete,
                    ),
                  ),
                ],
              ),
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
          color: const Color(0xFFF8FAF6).withValues(alpha: 0.8),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 18 * s,
                      color: const Color(0xFF191C1A),
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
                  color: const Color(0xFF191C1A),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16 * s,
                      color: const Color(0xFF191C1A),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF9F3C16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
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
// Chips
// ─────────────────────────────────────────────────────────────────────────────
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      children: [
        Container(
          height: 20 * s,
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
          decoration: const BoxDecoration(
            color: Color(0xFFFFDBCF),
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 13 * s,
                color: const Color(0xFF390C00),
              ),
              SizedBox(width: 4 * s),
              figmaText(
                'DAILY RITUAL',
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.5 * s,
                lineHeight: 12 * s,
                color: const Color(0xFF390C00),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          height: 20 * s,
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
          decoration: const BoxDecoration(
            color: Color(0xFFE7E9E5),
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          child: Row(
            children: [
              Container(
                width: 6 * s,
                height: 6 * s,
                decoration: const BoxDecoration(
                  color: Color(0xFF3A6750),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6 * s),
              figmaText(
                'Active Focus',
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.4 * s,
                lineHeight: 12 * s,
                color: const Color(0xFF57423B),
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
  const _TitleBlock({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56 * s,
          height: 56 * s,
          decoration: BoxDecoration(
            color: const Color(0x1A9F3C16),
            borderRadius: BorderRadius.circular(16 * s),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            size: 26 * s,
            color: const Color(0xFF9F3C16),
          ),
        ),
        SizedBox(width: 16 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              figmaText(
                'Mindful Reading',
                size: 22 * s,
                weight: FontWeight.w600,
                letterSpacing: -0.55 * s,
                lineHeight: 28 * s,
                color: const Color(0xFF191C1A),
              ),
              SizedBox(height: 2 * s),
              figmaText(
                'Building intellectual stillness & depth',
                size: 14 * s,
                weight: FontWeight.w400,
                lineHeight: 20 * s,
                color: const Color(0xFF57423B),
                width: 168 * s,
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8A54), Color(0xFFFF6B2C)],
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
              color: const Color(0xFFF3F4F0),
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 15 * s,
                  color: const Color(0xFF57423B),
                ),
                SizedBox(width: 8 * s),
                figmaText(
                  'Archive Habit to Vault',
                  size: 14 * s,
                  weight: FontWeight.w600,
                  letterSpacing: 0.14 * s,
                  lineHeight: 18 * s,
                  color: const Color(0xFF191C1A),
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
                  color: const Color(0xFFBA1A1A),
                ),
                SizedBox(width: 6 * s),
                figmaText(
                  'Delete Ritual Permanently',
                  size: 12 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.24 * s,
                  lineHeight: 16 * s,
                  color: const Color(0xFFBA1A1A),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
