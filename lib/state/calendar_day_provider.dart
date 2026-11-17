import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/day.dart';

/// A local civil date, refreshed at midnight, after resume and periodically
/// to notice a changed device timezone while the app stays open.
class CalendarDayController extends Notifier<DateTime> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  DateTime build() {
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => refresh());
    ref.onDispose(() {
      _timer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });
    return dayOnly(DateTime.now());
  }

  void refresh() {
    final now = dayOnly(DateTime.now());
    if (state.year != now.year || state.month != now.month || state.day != now.day ||
        state.timeZoneOffset != now.timeZoneOffset) state = now;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }
}

final calendarDayProvider = NotifierProvider<CalendarDayController, DateTime>(
  CalendarDayController.new,
);
