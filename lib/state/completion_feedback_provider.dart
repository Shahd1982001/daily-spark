import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Short, local feedback for crossing a daily goal; no network or analytics.
/// Device sound settings and hardware support still determine what is heard.
abstract class CompletionFeedback {
  Future<void> play();
}

class DeviceCompletionFeedback implements CompletionFeedback {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> play() async {
    // A missing vibration motor or audio implementation should never break
    // habit saving. Start them independently so one failure doesn't block the other.
    final haptic = HapticFeedback.mediumImpact().catchError((Object _) {});
    final audio = _player.play(AssetSource('audio/spark_completion.wav'))
        .catchError((Object _) {});
    await Future.wait([haptic, audio]);
  }

  Future<void> dispose() async {
    try { await _player.dispose(); } catch (_) {}
  }
}

final completionFeedbackProvider = Provider<CompletionFeedback>((ref) {
  final feedback = DeviceCompletionFeedback();
  ref.onDispose(() { feedback.dispose(); });
  return feedback;
});
