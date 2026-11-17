import 'package:daily_spark/data/models/habit.dart';
import 'package:daily_spark/data/services/reminder_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const notifications = MethodChannel('dexterous.com/flutter/local_notifications');
  const timezone = MethodChannel('flutter_timezone');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifications, (call) async {
      calls.add(call);
      if (call.method == 'initialize' || call.method == 'requestNotificationsPermission') return true;
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezone, (call) async => 'Africa/Tripoli');
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(notifications, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(timezone, null);
  });

  test('permission, schedule, edit and disable use native channel', () async {
    final service = ReminderNotifications();
    final h = Habit(id: 'a', title: 'Read', createdAt: DateTime(2026),
        rhythm: HabitRhythm.custom, days: const {1, 3}, reminderTime: '08:30');
    expect(await service.requestPermission(), isTrue);
    expect(await service.sync([h], enabled: true, language: 'ar'), ReminderResult.ok);
    var scheduled = calls.where((c) => c.method == 'zonedSchedule').toList();
    expect(scheduled, hasLength(2));
    expect((scheduled.first.arguments as Map)['body'], 'Read');
    expect((scheduled.first.arguments as Map)['title'], 'وقت عادتك ✨');
    expect(calls.any((c) => c.method == 'cancelAllPendingNotifications'), isTrue);
    calls.clear();
    expect(await service.sync([h.copyWith(reminderTime: '09:00')], enabled: true, language: 'en'), ReminderResult.ok);
    scheduled = calls.where((c) => c.method == 'zonedSchedule').toList();
    expect(scheduled, hasLength(2));
    expect((scheduled.first.arguments as Map)['title'], 'Time for your habit ✨');
    calls.clear();
    expect(await service.sync([h], enabled: false, language: 'en'), ReminderResult.ok);
    expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
    expect(calls.where((c) => c.method == 'cancelAllPendingNotifications'), hasLength(1));
  });
  test('iPhone limit reports failure rather than silently dropping reminders', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
    final service = ReminderNotifications();
    final habits = List.generate(65, (i) => Habit(id: '$i', title: 'Habit',
      createdAt: DateTime(2026), reminderTime: '08:30'));
    expect(await service.sync(habits, enabled: true, language: 'en'), ReminderResult.limitExceeded);
    expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
    expect(calls.where((c) => c.method == 'cancelAllPendingNotifications'), hasLength(1));
  });
  test('concurrent edits finish in order and a denied permission is reported', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifications, (call) async {
      calls.add(call);
      if (call.method == 'initialize') return true;
      if (call.method == 'requestNotificationsPermission') return false;
      return null;
    });
    final service = ReminderNotifications();
    expect(await service.requestPermission(), isFalse);
    final h = Habit(id: 'a', title: 'Read', createdAt: DateTime(2026), reminderTime: '08:30');
    final first = service.sync([h], enabled: true, language: 'en');
    final second = service.sync([h], enabled: false, language: 'en');
    expect(await first, ReminderResult.ok);
    expect(await second, ReminderResult.ok);
    expect(calls.last.method, 'cancelAllPendingNotifications');
  });

}
