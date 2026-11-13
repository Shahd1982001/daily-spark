import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:daily_spark/design_system/widgets/design_canvas.dart' show figmaText;
import 'package:daily_spark/screens/home/widgets/habit_card.dart';
import 'package:daily_spark/screens/home/widgets/pulse_card.dart';

/// PURE UI — Home.
/// No state container, no network: taps are reported to the parent.
/// Figma: node 126:15685 — 390 × 844 viewport, 1252 of scrollable content.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onProfile,
    this.onToggleHabit,
    this.onHabitTap,
    this.onNewRitual,
    this.onFilterChanged,
    this.onNavTap,
  });

  final VoidCallback? onProfile;
  final ValueChanged<int>? onToggleHabit;
  final ValueChanged<int>? onHabitTap;
  final VoidCallback? onNewRitual;
  final ValueChanged<int>? onFilterChanged;
  final ValueChanged<int>? onNavTap;

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
          // ── Scrollable content ─────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(top: 64 * s, bottom: 140 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _Greeting(scale: s),
                  ),
                  SizedBox(height: 16 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: PulseCard(scale: s),
                  ),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _RoutineHeader(
                      scale: s,
                      onNewRitual: onNewRitual,
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _FilterPills(
                      scale: s,
                      onChanged: onFilterChanged,
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  ..._habitCards(s),
                  SizedBox(height: 24 * s),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s),
                    child: _ClarityNote(scale: s),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating top bar ───────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _HomeHeader(scale: s, onProfile: onProfile),
          ),

          // ── Floating bottom navigation ─────────────────────────────
          Positioned(
            left: 16 * s,
            right: 16 * s,
            bottom: 20 * s,
            child: _BottomNav(scale: s, onNavTap: onNavTap),
          ),
        ],
      ),
    );
  }

  List<Widget> _habitCards(double s) {
    final data = <Map<String, Object>>[
      {
        'title': 'Morning Meditation',
        'meta': ['10 mins', '8:00 AM'],
        'streak': '12d',
        'icon': Icons.self_improvement,
        'iconColor': const Color(0xFF059669),
        'bg': const Color(0xFFD1FAE5),
        'done': true,
      },
      {
        'title': 'Hydrate (1.5L)',
        'meta': ['Goal: 2.5L', 'Anytime'],
        'streak': '8d',
        'icon': Icons.water_drop_outlined,
        'iconColor': const Color(0xFF059669),
        'bg': const Color(0xFFD1FAE5),
        'done': true,
      },
      {
        'title': 'Read 20 Pages',
        'meta': ['Atomic Habits', 'Evening'],
        'streak': '5d',
        'icon': Icons.menu_book_outlined,
        'iconColor': const Color(0xFF059669),
        'bg': const Color(0xFFD1FAE5),
        'done': true,
      },
      {
        'title': '30-Min Workout / Walk',
        'meta': ['5:30 PM', '350 kcal'],
        'streak': '19d',
        'icon': Icons.directions_walk_rounded,
        'iconColor': const Color(0xFFE05316),
        'bg': const Color(0xFFFFF2EB),
        'done': false,
        'next': true,
      },
      {
        'title': 'Evening Journal',
        'meta': ['9:30 PM', 'Reflection'],
        'streak': '7d',
        'icon': Icons.edit_note_rounded,
        'iconColor': const Color(0xFF57423B),
        'bg': const Color(0xFFE7E9E5),
        'done': false,
      },
    ];

    final widgets = <Widget>[];
    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(16 * s, 0, 16 * s, i == data.length - 1 ? 0 : 12 * s),
          child: HabitCard(
            scale: s,
            title: d['title'] as String,
            meta: (d['meta'] as List).cast<String>(),
            streak: d['streak'] as String,
            icon: d['icon'] as IconData,
            iconColor: d['iconColor'] as Color,
            iconBackground: d['bg'] as Color,
            completed: d['done'] as bool,
            showNextBadge: d['next'] == true,
            onToggle: () => onToggleHabit?.call(i),
            onTap: () => onHabitTap?.call(i),
          ),
        ),
      );
    }
    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting block
// ─────────────────────────────────────────────────────────────────────────────
class _Greeting extends StatelessWidget {
  const _Greeting({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            figmaText(
              'WEDNESDAY, OCT 25',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: const Color(0xFF57423B),
            ),
            Container(
              width: 4 * s,
              height: 4 * s,
              margin: EdgeInsets.symmetric(horizontal: 6 * s),
              decoration: const BoxDecoration(
                color: Color(0xFFDEC0B7),
                shape: BoxShape.circle,
              ),
            ),
            figmaText(
              'Autumn Rhythm',
              size: 10 * s,
              weight: FontWeight.w500,
              letterSpacing: 0.4 * s,
              lineHeight: 12 * s,
              color: const Color(0xFF3A6750),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        figmaText(
          'Good morning, Shahd',
          size: 22 * s,
          weight: FontWeight.w600,
          letterSpacing: -0.55 * s,
          lineHeight: 28 * s,
          color: const Color(0xFF191C1A),
        ),
        SizedBox(height: 2 * s),
        figmaText(
          '3 of 5 habits completed for today. Keep the spark alive.',
          size: 14 * s,
          weight: FontWeight.w400,
          lineHeight: 20 * s,
          color: const Color(0xFF57423B),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Today's Routine" header
// ─────────────────────────────────────────────────────────────────────────────
class _RoutineHeader extends StatelessWidget {
  const _RoutineHeader({required this.scale, this.onNewRitual});

  final double scale;
  final VoidCallback? onNewRitual;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 28 * s,
      child: Row(
        children: [
          figmaText(
            "Today's Routine",
            size: 18 * s,
            weight: FontWeight.w600,
            letterSpacing: -0.45 * s,
            lineHeight: 24 * s,
            color: const Color(0xFF191C1A),
          ),
          SizedBox(width: 4 * s),
          Container(
            height: 16 * s,
            padding: EdgeInsets.symmetric(horizontal: 8 * s),
            decoration: const BoxDecoration(
              color: Color(0xFFE7E9E5),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Center(
              child: figmaText(
                '5 total',
                size: 10 * s,
                weight: FontWeight.w600,
                letterSpacing: 0.4 * s,
                lineHeight: 12 * s,
                color: const Color(0xFF57423B),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNewRitual,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 28 * s,
              padding: EdgeInsets.symmetric(horizontal: 12 * s),
              decoration: BoxDecoration(
                color: const Color(0xFFE7E9E5),
                borderRadius: BorderRadius.circular(12 * s),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_rounded, size: 12 * s, color: const Color(0xFF191C1A)),
                  SizedBox(width: 5 * s),
                  figmaText(
                    'New Ritual',
                    size: 12 * s,
                    weight: FontWeight.w500,
                    letterSpacing: 0.24 * s,
                    lineHeight: 16 * s,
                    color: const Color(0xFF191C1A),
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
// Segmented filter pills
// ─────────────────────────────────────────────────────────────────────────────
class _FilterPills extends StatelessWidget {
  const _FilterPills({required this.scale, this.onChanged});

  final double scale;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const labels = ['All (5)', 'Morning (2)', 'Anytime (2)', 'Evening (1)'];
    const widths = [61.0, 95.0, 95.0, 91.0];
    return SizedBox(
      height: 36 * s,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) SizedBox(width: 4 * s),
            GestureDetector(
              onTap: () => onChanged?.call(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: widths[i] * s,
                height: 28 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == 0 ? const Color(0xFF2E312F) : const Color(0xFFF3F4F0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: figmaText(
                  labels[i],
                  size: 12 * s,
                  weight: FontWeight.w500,
                  letterSpacing: 0.24 * s,
                  lineHeight: 16 * s,
                  color: i == 0 ? const Color(0xFFF0F1EE) : const Color(0xFF57423B),
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
// Daily clarity note
// ─────────────────────────────────────────────────────────────────────────────
class _ClarityNote extends StatelessWidget {
  const _ClarityNote({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 358 * s,
      height: 174 * s,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F0),
        borderRadius: BorderRadius.circular(16 * s),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16 * s,
            top: 18 * s,
            child: Container(
              width: 32 * s,
              height: 32 * s,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                size: 17 * s,
                color: const Color(0xFFD97706),
              ),
            ),
          ),
          Positioned(
            left: 56 * s,
            top: 16 * s,
            child: figmaText(
              'DAILY CLARITY',
              size: 10 * s,
              weight: FontWeight.w600,
              letterSpacing: 0.5 * s,
              lineHeight: 12 * s,
              color: const Color(0xFFD97706),
            ),
          ),
          Positioned(
            left: 56 * s,
            top: 30 * s,
            child: figmaText(
              '\u201cYou do not rise to the level of your goals. You fall to the '
              'level of your systems.\u201d',
              size: 12 * s,
              weight: FontWeight.w400,
              letterSpacing: 0.12 * s,
              lineHeight: 16 * s,
              color: const Color(0xFF57423B),
              width: 270 * s,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating top bar
// ─────────────────────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.scale, this.onProfile});

  final double scale;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12 * s, sigmaY: 12 * s),
        child: Container(
          height: 64 * s,
          color: const Color(0xFFF8FAF6).withValues(alpha: 0.85),
          child: Stack(
            children: [
              Positioned(
                left: 16 * s,
                top: 16 * s,
                child: Image.asset(
                  'assets/brand/home_logo.png',
                  width: 32 * s,
                  height: 32 * s,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                left: 56 * s,
                top: 15 * s,
                child: figmaText(
                  'DAILY SPARK',
                  size: 10 * s,
                  weight: FontWeight.w600,
                  letterSpacing: 0.5 * s,
                  lineHeight: 12 * s,
                  color: const Color(0xFF57423B),
                ),
              ),
              Positioned(
                left: 56 * s,
                top: 27 * s,
                child: figmaText(
                  'Home',
                  size: 16 * s,
                  weight: FontWeight.w600,
                  letterSpacing: -0.08 * s,
                  lineHeight: 22 * s,
                  color: const Color(0xFF191C1A),
                ),
              ),
              Positioned(
                left: 330 * s,
                top: 10 * s,
                child: GestureDetector(
                  onTap: onProfile,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 44 * s,
                    height: 44 * s,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 6 * s,
                          top: 6 * s,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/brand/avatar_shahd.png',
                              width: 32 * s,
                              height: 32 * s,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 28 * s,
                          top: 6 * s,
                          child: Container(
                            width: 10 * s,
                            height: 10 * s,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9F3C16),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5 * s),
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
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating bottom navigation
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.scale, this.onNavTap});

  final double scale;
  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 56 * s,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Selected item
          Positioned(
            left: 6 * s,
            top: 6 * s,
            child: GestureDetector(
              onTap: () => onNavTap?.call(0),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 81 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF8A54), Color(0xFFFF6B2C)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 15 * s,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5 * s),
                    figmaText(
                      'Home',
                      size: 10 * s,
                      weight: FontWeight.w600,
                      letterSpacing: 0.25 * s,
                      lineHeight: 12 * s,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (final item in const [
            (132.0, Icons.checklist_rounded),
            (220.0, Icons.insights_rounded),
            (308.0, Icons.person_outline_rounded),
          ])
            Positioned(
              left: item.$1 * s,
              top: 6 * s,
              child: GestureDetector(
                onTap: () => onNavTap?.call(
                  item.$1 == 132.0 ? 1 : (item.$1 == 220.0 ? 2 : 3),
                ),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 44 * s,
                  height: 44 * s,
                  child: Icon(
                    item.$2,
                    size: 21 * s,
                    color: const Color(0xFF57423B),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
