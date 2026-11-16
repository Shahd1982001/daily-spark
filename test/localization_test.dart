import 'package:daily_spark/design_system/widgets/design_canvas.dart';
import 'package:daily_spark/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => Strings.locale = const Locale('en'));

  test('all registered catalogs have the same keys and intact placeholders', () {
    final base = Strings.translationsFor('ar');
    expect(base.length, greaterThan(400));
    final placeholders = RegExp(r'\{[A-Za-z_][A-Za-z_0-9]*\}');
    List<String> args(String value) =>
        placeholders.allMatches(value).map((m) => m.group(0)!).toList()..sort();
    for (final code in Strings.available.where((code) => code != 'en')) {
      final catalog = Strings.translationsFor(code);
      expect(catalog.keys.toSet(), base.keys.toSet(), reason: '$code catalog parity');
      for (final entry in catalog.entries) {
        expect(args(entry.value), args(entry.key), reason: '$code: ${entry.key}');
        expect(entry.value.trim(), isNotEmpty, reason: '$code: ${entry.key}');
      }
    }
  });

  test('dynamic strings interpolate and language switches immediately', () {
    Strings.locale = const Locale('ar');
    final level = tr('Level {level} {title}', {'level': '2', 'title': tr('Builder')});
    expect(level, contains('2'));
    expect(level, contains('بان'));
    expect(tr('Next: {count} more check-ins', {'count': '9'}), contains('9'));
    expect(tr('{title} updated ✦', {'title': 'Home'}), contains('Home'));
    Strings.locale = const Locale('en');
    expect(tr('Next: {count} more check-ins', {'count': '9'}), 'Next: 9 more check-ins');
  });

  testWidgets('user supplied text is not translated even when it matches a key', (tester) async {
    Strings.locale = const Locale('ar');
    await tester.pumpWidget(MaterialApp(home: Column(children: [
      figmaText('Home', size: 12, weight: FontWeight.w400, color: Colors.black),
      figmaText('Home', size: 12, weight: FontWeight.w400, color: Colors.black, translate: false),
    ])));
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
