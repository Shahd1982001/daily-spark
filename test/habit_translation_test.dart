import 'dart:async';
import 'dart:convert';

import 'package:daily_spark/design_system/widgets/design_canvas.dart';
import 'package:daily_spark/l10n/habit_translation.dart';
import 'package:daily_spark/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

void main() {
  setUp(HabitTranslation.clearCache);
  tearDown(() {
    HabitTranslation.request = http.get;
    HabitTranslation.clearCache();
    Strings.locale = const Locale('en');
  });

  test('sends only the task title and deduplicates in-flight translations', () async {
    var calls = 0;
    final waiting = Completer<http.Response>();
    HabitTranslation.request = (uri) {
      calls++;
      expect(uri.queryParameters['q'], 'قراءة كتاب');
      expect(uri.queryParameters['sl'], 'auto');
      expect(uri.queryParameters['tl'], 'en');
      return waiting.future;
    };
    final a = HabitTranslation.translate('قراءة كتاب', 'en');
    final b = HabitTranslation.translate('قراءة كتاب', 'en');
    waiting.complete(http.Response(jsonEncode([['Read a book', 'ar']]), 200));
    expect(await a, 'Read a book');
    expect(await b, 'Read a book');
    expect(await HabitTranslation.translate('قراءة كتاب', 'en'), 'Read a book');
    expect(calls, 1);
  });

  test('offline fallback preserves original and throttles retries', () async {
    var calls = 0;
    HabitTranslation.request = (_) async { calls++; throw Exception('offline'); };
    expect(await HabitTranslation.translate('My task', 'ar'), 'My task');
    expect(await HabitTranslation.translate('My task', 'ar'), 'My task');
    expect(calls, 1);
  });

  testWidgets('task is translated for display; original input is unchanged', (tester) async {
    HabitTranslation.request = (_) async => http.Response(
      jsonEncode([['قراءة كتاب', 'en']]), 200, headers: {'content-type': 'application/json; charset=utf-8'},
    );
    const original = 'Read a book';
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: figmaText(original, translateHabit: true, size: 12,
          weight: FontWeight.w400, color: Colors.black),
    ));
    await tester.pumpAndSettle();
    expect(find.text('قراءة كتاب'), findsOneWidget);
    expect(original, 'Read a book');
  });
}
