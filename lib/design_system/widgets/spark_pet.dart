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
import 'package:daily_spark/state/spark_treats_provider.dart';
import 'spark_mascot.dart';

/// The pet stays on the navigation bar while the new character
/// animation is developed. Rewards and missed-day state remain intact.
class SparkPet extends ConsumerStatefulWidget {
  const SparkPet({super.key, this.progressBar = false});
  final bool progressBar;
  @override
  ConsumerState<SparkPet> createState() => _SparkPetState();
}

class _SparkPetState extends ConsumerState<SparkPet> {
  String? _message;
  Timer? _messageTimer;
  @override
  void dispose() { _messageTimer?.cancel(); super.dispose(); }

  void _speak(String text) {
    _messageTimer?.cancel();
    setState(() => _message = text);
    _messageTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _message = null);
    });
  }

  Future<void> _interact(DateTime? missed, bool sad) async {
    if (ref.read(sparkTreatsProvider).items.isNotEmpty) {
      try {
        final treat = await ref.read(sparkTreatsProvider.notifier).feed();
        if (!mounted) return;
        if (treat != null) {
          if (sad && missed != null) ref.read(sparkPetMoodProvider.notifier).comfort(missed);
          _speak(tr('Yummy! Thank you 💛'));
          return;
        }
      } catch (_) {
        if (mounted) _speak(tr('Could not use the treat. Please try again.'));
        return;
      }
    }
    if (!mounted) return;
    if (sad && missed != null) {
      ref.read(sparkPetMoodProvider.notifier).comfort(missed);
      _speak(tr('Thank you! Let us try again together 💛'));
    } else {
      _speak(tr('Hehe! I am happy you are here ✨'));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(completionCelebrationProvider, (previous, next) {
      if (next == null || identical(previous, next)) return;
      final reward = next.rewardName;
      _speak(reward == 'cookie' ? tr('A cookie for Spark! Tap to feed 🍪')
          : reward == 'cake' ? tr('Cake for Spark! Tap to feed 🍰') : tr('Yay! You did it! ✨'));
    });
    final snapshot = ref.watch(habitsProvider).valueOrNull;
    final today = ref.watch(calendarDayProvider);
    final mood = ref.watch(sparkPetMoodProvider);
    final treats = ref.watch(sparkTreatsProvider);
    final missed = snapshot == null ? null : latestMissedDay(snapshot, today);
    final sad = mood.loaded && missed != null && mood.calmedDay != dayKey(missed);
    const size = 76.0;
    return LayoutBuilder(builder: (context, constraints) {
      final scale = (constraints.maxWidth / 390).clamp(.86, 1.25);
      final x = (constraints.maxWidth - size).clamp(0.0, double.infinity) * .72;
      final bottom = (widget.progressBar ? 86 : 76) * scale;
      return Stack(clipBehavior: Clip.none, children: [
        Positioned(left: x, bottom: bottom, width: size, height: size,
          child: Stack(clipBehavior: Clip.none, children: [
            Semantics(button: true, label: tr('Spark, your little companion'),
              hint: tr('Tap to comfort or feed.'),
              child: GestureDetector(behavior: HitTestBehavior.opaque,
                onTap: () => _interact(missed, sad),
                child: const SparkMascot(size: size, blink: true),
              )),
            if (treats.items.isNotEmpty)
              Positioned(right: 0, top: 1, child: IgnorePointer(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.ember.withValues(alpha: .5))),
                child: Text('🍪 ${treats.items.length}', style: TextStyle(fontSize: 10, color: p.ink,
                  decoration: TextDecoration.none)),
              ))),
            if (_message != null)
              Positioned(bottom: size - 4, left: -118, child: IgnorePointer(child: Container(
                width: 160, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
  }
}
