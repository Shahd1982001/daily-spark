import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:daily_spark/l10n/strings.dart';
import 'package:daily_spark/l10n/habit_translation.dart';

/// Every screen is drawn on a fixed 390 × 884 canvas (the exact Figma frame)
/// and then uniformly scaled to the device viewport. This guarantees the
/// layout ratios stay identical to the design on every phone.
class DesignCanvas extends StatelessWidget {
  const DesignCanvas({
    super.key,
    required this.child,
    this.background = const Color(0xFFF8FAF6),
  });

  static const double width = 390;
  static const double height = 884;

  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            constraints.maxWidth / width,
            constraints.maxHeight / height,
          );
          return Center(
            child: SizedBox(
              width: width * scale,
              height: height * scale,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Convenience text builder that mirrors a Figma text style 1:1.
Widget figmaText(
  String rawText, {
  required double size,
  required FontWeight weight,
  required Color color,
  double? letterSpacing,
  double? lineHeight,
  TextAlign align = TextAlign.start,
  double? width,
  int? maxLines,
  TextOverflow overflow = TextOverflow.clip,
  bool translate = true,
  bool translateHabit = false,
}) {
  if (translateHabit) {
    return Builder(builder: (context) {
      final language = Localizations.maybeLocaleOf(context)?.languageCode ?? Strings.locale.languageCode;
      return FutureBuilder<String>(
        key: ValueKey((rawText, language)),
        future: HabitTranslation.translate(rawText, language),
        builder: (context, snapshot) => figmaText(
          snapshot.data ?? rawText, size: size, weight: weight, color: color,
          letterSpacing: letterSpacing, lineHeight: lineHeight, align: align,
          width: width, maxLines: maxLines, overflow: overflow, translate: false,
        ),
      );
    });
  }
  final text = translate ? tr(rawText) : rawText;
  final style = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: lineHeight == null ? null : lineHeight / size,
    color: color,
    decoration: TextDecoration.none,
  );
  // Paragraph direction follows the content script: pure-Latin strings (user
  // data, untranslated fallbacks) lay out LTR so runs never scramble inside an
  // RTL page; Arabic strings lay out RTL and anchor right. Keeps every screen
  // readable in both locales regardless of ambient direction.
  final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  final child = Text(
    text,
    style: style,
    textAlign: align,
    textDirection: hasArabic ? TextDirection.rtl : TextDirection.ltr,
    maxLines: maxLines,
    overflow: overflow,
  );
  return width == null ? child : SizedBox(width: width, child: child);
}
