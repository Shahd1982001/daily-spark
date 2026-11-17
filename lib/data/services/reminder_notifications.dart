import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';
import 'reminder_plan.dart';

enum ReminderResult { ok, unsupported, permissionDenied, limitExceeded, failed }

/// Native local notifications only. Synchronization is serialized so an older
/// edit cannot overwrite a newer one while platform calls are still running.
class ReminderNotifications {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  Future<void> _queue = Future.value();
  Future<void>? _initializing;
  static bool get supported => !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _initialize() => _initializing ??= _initializeOnce();

  Future<void> _initializeOnce() async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(requestAlertPermission: false,
          requestBadgePermission: false, requestSoundPermission: false),
    ));
  }

  Future<bool> requestPermission() async {
    if (!supported) return false;
    try {
      await _initialize();
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<ReminderResult> sync(List<Habit> habits, {required bool enabled, required String language}) {
    if (!supported) return Future.value(ReminderResult.unsupported);
    final frozen = List<Habit>.of(habits);
    final result = _queue.then((_) => _sync(frozen, enabled: enabled, language: language));
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<ReminderResult> _sync(List<Habit> habits, {required bool enabled, required String language}) async {
    try {
      await _initialize();
      final rules = buildReminderPlan(habits, enabled: enabled);
      // Combine seven identical weekly rules into one daily trigger. iOS has
      // a hard limit of 64 pending requests; never silently drop rules.
      final entries = compactReminderRules(rules);
      if (defaultTargetPlatform == TargetPlatform.iOS && entries.length > 64) {
        // Clear stale notifications rather than misrepresent an older schedule.
        await _plugin.cancelAllPendingNotifications();
        return ReminderResult.limitExceeded;
      }
      await _plugin.cancelAllPendingNotifications();
      if (entries.isEmpty) return ReminderResult.ok;
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
      final titles = {for (final habit in habits) habit.id: habit.title};
      final arabic = language == 'ar';
      final now = tz.TZDateTime.now(tz.local);
      var id = 1;
      for (final entry in entries) {
        final rule = entry.rule;
        final daily = entry.daily;
        var date = tz.TZDateTime(tz.local, now.year, now.month, now.day, rule.hour, rule.minute);
        if (daily) {
          if (!date.isAfter(now)) date = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, rule.hour, rule.minute);
        } else {
          var offset = (rule.weekday - now.weekday + 7) % 7;
          if (offset == 0 && !date.isAfter(now)) offset = 7;
          date = tz.TZDateTime(tz.local, now.year, now.month, now.day + offset, rule.hour, rule.minute);
        }
        await _plugin.zonedSchedule(id: id++, scheduledDate: date,
          title: arabic ? 'وقت عادتك ✨' : 'Time for your habit ✨',
          body: titles[rule.habitId] ?? '',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails('habit_reminders_v1', 'Habit reminders',
                channelDescription: 'Reminders for your scheduled habits', importance: Importance.defaultImportance),
            iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true)),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: daily ? DateTimeComponents.time : DateTimeComponents.dayOfWeekAndTime);
      }
      return ReminderResult.ok;
    } catch (_) {
      // Do not leave a silently incomplete set if a platform call fails.
      try { await _plugin.cancelAllPendingNotifications(); } catch (_) {}
      return ReminderResult.failed;
    }
  }
}
