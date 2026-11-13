import 'package:flutter_riverpod/flutter_riverpod.dart';

/// LOGIC layer: onboarding page index. The UI never imports this directly —
/// screens receive plain callbacks instead.
class OnboardingController extends Notifier<int> {
  @override
  int build() => 0;

  void goTo(int index, {required int pageCount}) {
    state = index.clamp(0, pageCount - 1);
  }

  /// Returns `true` when the flow is finished.
  bool next({required int pageCount}) {
    if (state >= pageCount - 1) return true;
    state = state + 1;
    return false;
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, int>(OnboardingController.new);
