import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A transient completion event. The snack inventory is stored separately.
class CompletionCelebration {
  const CompletionCelebration({required this.habitId, this.rewardName});
  final String habitId;
  /// The newly awarded treat type, or null if already earned / unavailable.
  final String? rewardName;
}
final completionCelebrationProvider = StateProvider<CompletionCelebration?>((ref) => null);
