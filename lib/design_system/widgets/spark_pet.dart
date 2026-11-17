import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_spark/data/models/day.dart';
import 'package:daily_spark/design_system/theme/spark_palette.dart';
import 'package:daily_spark/l10n/strings.dart';
import 'package:daily_spark/state/calendar_day_provider.dart';
import 'package:daily_spark/state/habit_providers.dart';
import 'package:daily_spark/state/mascot_providers.dart';
import 'package:daily_spark/state/spark_pet_provider.dart';
import 'spark_mascot.dart';

/// A small draggable, roaming companion. Only the pet itself receives pointer
/// events; the rest of the screen remains interactive.
class SparkPet extends ConsumerStatefulWidget {
  const SparkPet({super.key});
  @override ConsumerState<SparkPet> createState() => _SparkPetState();
}

class _SparkPetState extends ConsumerState<SparkPet> with SingleTickerProviderStateMixin {
  late final AnimationController _walk = AnimationController(vsync: this,
      duration: const Duration(seconds: 8));
  static const _stops = [Offset(.78,.20), Offset(.15,.38), Offset(.80,.66),
    Offset(.25,.75), Offset(.56,.46), Offset(.08,.15)];
  Offset _from = const Offset(.80, .52), _to = _stops.first;
  int _stop = 0;
  bool _dragging = false, _reducedMotion = false, _delighted = false;
  String? _message;
  Timer? _messageTimer;

  Offset get _position => Offset.lerp(_from, _to, Curves.easeInOut.transform(_walk.value))!;

  @override
  void initState() {
    super.initState();
    _walk.addStatusListener((status) {
      if (status != AnimationStatus.completed || _dragging || _reducedMotion || !mounted) return;
      _from = _to;
      _stop = (_stop + 1) % _stops.length;
      _to = _stops[_stop];
      _walk.forward(from: 0);
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_reducedMotion != reduced || (!_walk.isAnimating && !_dragging)) {
      _reducedMotion = reduced;
      if (reduced) {
        _from = _position;
        _walk.stop();
        _walk.value = 0;
        _to = _from;
      } else if (!_dragging) {
        _to = _stops[_stop];
        _walk.forward(from: 0);
      }
    }
  }
  @override
  void dispose() { _messageTimer?.cancel(); _walk.dispose(); super.dispose(); }

  void _speak(String text) {
    _messageTimer?.cancel();
    setState(() { _message = text; _delighted = true; });
    _messageTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() { _message = null; _delighted = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(completionCelebrationProvider, (previous, next) {
      if (previous != null && next > previous) _speak(tr('Yay! You did it! ✨'));
    });
    final snapshot = ref.watch(habitsProvider).valueOrNull;
    final today = ref.watch(calendarDayProvider);
    final mood = ref.watch(sparkPetMoodProvider);
    final missed = snapshot == null ? null : latestMissedDay(snapshot, today);
    final sad = mood.loaded && missed != null && mood.calmedDay != dayKey(missed) && !_delighted;
    final media = MediaQuery.of(context);
    const size = 76.0;

    return LayoutBuilder(builder: (context, constraints) {
      final maxX = (constraints.maxWidth - size).clamp(0.0, double.infinity);
      final top = media.padding.top + 76.0;
      final bottom = media.padding.bottom + 88.0;
      final usableY = (constraints.maxHeight - top - bottom - size).clamp(0.0, double.infinity);
      return AnimatedBuilder(animation: _walk, builder: (context, _) {
        final position = _position;
        return Stack(clipBehavior: Clip.none, children: [
          Positioned(left: position.dx * maxX, top: top + position.dy * usableY,
            width: size, height: size,
            child: Stack(clipBehavior: Clip.none, children: [
              Semantics(button: true, label: tr('Spark, your little companion'),
                hint: tr('Tap to comfort or play. Drag to move.'),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (sad) {
                      ref.read(sparkPetMoodProvider.notifier).comfort(missed);
                      _speak(tr('Thank you! Let us try again together 💛'));
                    } else {
                      _speak(tr('Hehe! I am happy you are here ✨'));
                    }
                  },
                  onPanStart: (_) {
                    _from = _position; _to = _from;
                    _walk.stop(); _walk.value = 0;
                    setState(() { _dragging = true; });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _from = Offset(
                        (_from.dx + (maxX == 0 ? 0 : details.delta.dx / maxX)).clamp(0.0, 1.0),
                        (_from.dy + (usableY == 0 ? 0 : details.delta.dy / usableY)).clamp(0.0, 1.0));
                      _to = _from;
                    });
                  },
                  onPanEnd: (_) {
                    setState(() { _dragging = false; });
                    if (!_reducedMotion) { _to = _stops[_stop]; _walk.forward(from: 0); }
                  },
                  onPanCancel: () {
                    setState(() { _dragging = false; });
                    if (!_reducedMotion) { _to = _stops[_stop]; _walk.forward(from: 0); }
                  },
                  child: SparkMascot(size: size, animate: true,
                      concerned: sad, celebrating: _delighted, walking: !_dragging),
                ),
              ),
              if (_message != null)
                Positioned(bottom: size - 4, left: position.dx > .5 ? -118 : 30,
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
}
