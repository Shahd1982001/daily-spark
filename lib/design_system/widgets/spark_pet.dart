import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_spark/data/models/day.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/l10n/strings.dart';
import 'package:daily_spark/state/calendar_day_provider.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/mascot_providers.dart';
import 'package:daily_spark/state/spark_pet_provider.dart';
import 'package:daily_spark/state/spark_treats_provider.dart';
import 'spark_mascot.dart';

enum _PetAction { idle, walking, held, falling, waving, heart }

/// A small pet that walks above the bottom navigation. The pet's own hitbox is
/// draggable; empty overlay space does not intercept the app's other controls.
class SparkPet extends ConsumerStatefulWidget {
  const SparkPet({super.key, this.progressBar = false});
  final bool progressBar;
  @override ConsumerState<SparkPet> createState() => _SparkPetState();
}

class _SparkPetState extends ConsumerState<SparkPet> with TickerProviderStateMixin {
  late final AnimationController _walk = AnimationController(vsync: this, duration: const Duration(seconds: 5));
  late final AnimationController _fall = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final AnimationController _life = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  static const _stops = [.15, .82, .35, .72, .08, .62];
  double _fromX = .72, _toX = .72, _y = 1, _fallFrom = 1;
  int _stop = 0, _idleCount = 0;
  bool _reducedMotion = false, _delighted = false, _hurt = false;
  _PetAction _action = _PetAction.idle;
  SparkTreat? _eating;
  String? _message;
  Timer? _messageTimer, _idleTimer;

  double get _x => _action == _PetAction.walking
      ? _fromX + (_toX - _fromX) * Curves.easeInOut.transform(_walk.value) : _fromX;
  double get _currentY => _action == _PetAction.falling
      ? _fallFrom + (1 - _fallFrom) * Curves.easeIn.transform(_fall.value) : _y;

  @override
  void initState() {
    super.initState();
    _walk.addStatusListener((status) {
      if (status != AnimationStatus.completed || _action != _PetAction.walking || !mounted) return;
      _fromX = _toX;
      _scheduleIdle();
    });
    _fall.addStatusListener((status) {
      if (status != AnimationStatus.completed || _action != _PetAction.falling || !mounted) return;
      _landAfterFall();
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduced != _reducedMotion || (!_walk.isAnimating && _idleTimer == null && _action == _PetAction.idle)) {
      _reducedMotion = reduced;
      if (reduced) {
        _fromX = _x;
        _y = _currentY;
        _walk.stop(); _fall.stop(); _life.stop();
        _idleTimer?.cancel(); _idleTimer = null;
        if (_action == _PetAction.falling) { _y = 1; _hurt = true; }
        _action = _PetAction.idle;
      } else {
        _life.repeat();
        _scheduleIdle();
      }
    }
  }
  @override
  void dispose() { _messageTimer?.cancel(); _idleTimer?.cancel(); _walk.dispose(); _fall.dispose(); _life.dispose(); super.dispose(); }

  void _scheduleIdle() {
    _idleTimer?.cancel();
    if (!mounted) return;
    if (_reducedMotion) { setState(() => _action = _PetAction.idle); return; }
    _idleCount++;
    setState(() => _action = switch (_idleCount % 3) {
      0 => _PetAction.heart, 1 => _PetAction.waving, _ => _PetAction.idle,
    });
    _idleTimer = Timer(const Duration(seconds: 3), _beginWalking);
  }

  void _beginWalking() {
    _idleTimer = null;
    if (!mounted || _reducedMotion || _eating != null || _action == _PetAction.held || _action == _PetAction.falling) {
      if (mounted && !_reducedMotion && _eating != null) _scheduleIdle();
      return;
    }
    _toX = _stops[_stop++ % _stops.length];
    setState(() => _action = _PetAction.walking);
    _walk.forward(from: 0);
  }

  void _speak(String text, {bool delight = false, SparkTreat? eating}) {
    _messageTimer?.cancel();
    setState(() { _message = text; _delighted = delight; _eating = eating; });
    _messageTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() { _message = null; _delighted = false; _eating = null; });
    });
  }

  void _landAfterFall() {
    _y = 1;
    _hurt = true;
    _speak(tr('Oh! A gentle pat, please 🥺'));
    _scheduleIdle();
  }

  Future<void> _interact(DateTime? missed, bool sad) async {
    final inventory = ref.read(sparkTreatsProvider);
    if (inventory.items.isNotEmpty) {
      try {
        final treat = await ref.read(sparkTreatsProvider.notifier).feed();
        if (!mounted) return;
        if (treat != null) {
          if (sad && missed != null) ref.read(sparkPetMoodProvider.notifier).comfort(missed);
          _hurt = false;
          _speak(tr('Yummy! Thank you 💛'), delight: true, eating: treat);
          return;
        }
      } catch (_) {
        if (mounted) _speak(tr('Could not use the treat. Please try again.'));
        return;
      }
    }
    if (!mounted) return;
    if (sad && missed != null) ref.read(sparkPetMoodProvider.notifier).comfort(missed);
    if (_hurt || sad) {
      _hurt = false;
      _speak(tr('Thank you! Let us try again together 💛'), delight: true);
    } else {
      _speak(tr('Hehe! I am happy you are here ✨'), delight: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(completionCelebrationProvider, (previous, next) {
      if (next == null || identical(previous, next)) return;
      final reward = next.rewardName;
      final msg = reward == 'cookie' ? tr('A cookie for Spark! Tap to feed 🍪')
          : reward == 'cake' ? tr('Cake for Spark! Tap to feed 🍰') : tr('Yay! You did it! ✨');
      _speak(msg, delight: true);
    });
    final snapshot = ref.watch(habitsProvider).valueOrNull;
    final today = ref.watch(calendarDayProvider);
    final mood = ref.watch(sparkPetMoodProvider);
    final treats = ref.watch(sparkTreatsProvider);
    final missed = snapshot == null ? null : latestMissedDay(snapshot, today);
    final sad = (_hurt || (mood.loaded && missed != null && mood.calmedDay != dayKey(missed))) && !_delighted;
    final media = MediaQuery.of(context);
    const size = 76.0;
    return LayoutBuilder(builder: (context, constraints) {
      final scale = (constraints.maxWidth / 390).clamp(.86, 1.25);
      final maxX = (constraints.maxWidth - size).clamp(0.0, double.infinity);
      // The Progress bar is taller and sits slightly higher than the other bars.
      final ground = (constraints.maxHeight - (widget.progressBar ? 86 : 76) * scale - size).clamp(0.0, constraints.maxHeight);
      final ceiling = math.min(media.padding.top + 64, ground);
      final travelY = (ground - ceiling).clamp(0.0, double.infinity);
      return AnimatedBuilder(animation: Listenable.merge([_walk, _fall, _life]), builder: (context, _) {
        final x = _x;
        final y = _currentY;
        Widget art;
        if (_eating != null) {
          final asset = _eating == SparkTreat.cookie ? 'spark_eat.png' : 'spark_cake.png';
          art = Transform.scale(scale: _reducedMotion ? 1 : 1 + .025 * math.sin(_life.value * 2 * math.pi),
            child: Image.asset('assets/mascot/$asset', width: size, height: size, fit: BoxFit.contain));
        } else if (_delighted) {
          art = const SparkMascot(size: size, animate: true, celebrating: true);
        } else if (sad || _action == _PetAction.held || _action == _PetAction.falling) {
          art = SparkMascot(size: size, animate: true, concerned: sad);
        } else if (_action == _PetAction.walking) {
          art = _SideWalk(size: size, phase: _life.value, reverse: _toX > _fromX);
        } else if (_action == _PetAction.waving) {
          art = Transform.rotate(angle: _reducedMotion ? 0 : .05 * math.sin(_life.value * 2 * math.pi),
            child: Image.asset('assets/mascot/spark_wave.png', width: size, height: size, fit: BoxFit.contain));
        } else {
          art = const SparkMascot(size: size, animate: true);
        }
        return Stack(clipBehavior: Clip.none, children: [
          Positioned(left: x * maxX, top: ceiling + y * travelY, width: size, height: size,
            child: Stack(clipBehavior: Clip.none, children: [
              Semantics(button: true, label: tr('Spark, your little companion'),
                hint: tr('Tap to comfort or feed. Drag to move.'),
                child: GestureDetector(behavior: HitTestBehavior.opaque,
                  onTap: () => _interact(missed, sad),
                  onPanStart: (_) {
                    _fromX = _x; _y = _currentY;
                    _walk.stop(); _fall.stop(); _idleTimer?.cancel(); _idleTimer = null;
                    setState(() => _action = _PetAction.held);
                  },
                  onPanUpdate: (details) => setState(() {
                    _fromX = (_fromX + (maxX == 0 ? 0 : details.delta.dx / maxX)).clamp(0.0, 1.0);
                    _y = (_y + (travelY == 0 ? 0 : details.delta.dy / travelY)).clamp(0.0, 1.0);
                  }),
                  onPanEnd: (_) => _release(), onPanCancel: _release,
                  child: art,
                ),
              ),
              if (treats.items.isNotEmpty)
                Positioned(right: 0, top: 1, child: IgnorePointer(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.ember.withValues(alpha: .5))),
                  child: Text('🍪 ${treats.items.length}', style: TextStyle(fontSize: 10, color: p.ink,
                    decoration: TextDecoration.none)),
                ))),
              if (_action == _PetAction.heart && _message == null && !sad)
                const Positioned(right: 0, top: -8, child: IgnorePointer(child: Text('💛', style: TextStyle(fontSize: 17, decoration: TextDecoration.none)))),
              if (_message != null)
                Positioned(bottom: size - 4, left: x > .5 ? -118 : 30,
                  child: IgnorePointer(child: Container(width: 160,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(color: p.surface,
                      border: Border.all(color: p.ember.withValues(alpha: .3)),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 6)]),
                    child: Text(_message!, textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 11, height: 1.35,
                        fontWeight: FontWeight.w600, decoration: TextDecoration.none, color: p.ink)),
                  ))),
            ])),
        ]);
      });
    });
  }

  void _release() {
    if (_y < .98) {
      if (_reducedMotion) { _landAfterFall(); return; }
      _fallFrom = _y;
      setState(() => _action = _PetAction.falling);
      _fall.forward(from: 0);
    } else {
      _y = 1;
      _scheduleIdle();
    }
  }
}

/// Side-facing walking sprite with independently pivoting feet.
class _SideWalk extends StatelessWidget {
  const _SideWalk({required this.size, required this.phase, required this.reverse});
  final double size, phase;
  final bool reverse;
  @override
  Widget build(BuildContext context) {
    Widget layer(String part) => Image.asset('assets/mascot/side_$part.png',
      width: size, height: size, fit: BoxFit.contain, excludeFromSemantics: true);
    final step = math.sin(phase * 2 * math.pi);
    return ExcludeSemantics(child: Transform.flip(flipX: reverse,
      child: Transform.translate(offset: Offset(0, -1.3 * step.abs()),
        child: Stack(clipBehavior: Clip.none, children: [
          Transform.rotate(angle: .18 * step, alignment: const Alignment(-.34, .66), child: layer('left_foot')),
          Transform.rotate(angle: -.18 * step, alignment: const Alignment(.34, .66), child: layer('right_foot')),
          layer('body'),
        ]))));
  }
}
