import 'package:flutter/material.dart';

import 'habit_translation.dart';
import 'strings.dart';

/// A translated app sentence containing a user-authored habit title.
class HabitSentence extends StatelessWidget {
  const HabitSentence({super.key, required this.template, required this.title, this.style});

  final String template;
  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.maybeLocaleOf(context)?.languageCode ?? Strings.locale.languageCode;
    return FutureBuilder<String>(
      key: ValueKey((title, language)),
      future: HabitTranslation.translate(title, language),
      builder: (context, snapshot) => Text(
        tr(template, {'title': snapshot.data ?? title}),
        style: style,
      ),
    );
  }
}
