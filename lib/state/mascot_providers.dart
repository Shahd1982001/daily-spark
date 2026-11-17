import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Event counter only; no persisted personal information and no event on load.
final completionCelebrationProvider = StateProvider<int>((ref) => 0);
