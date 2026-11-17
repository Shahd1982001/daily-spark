import 'package:flutter/material.dart';

/// Chosen Spark character. Decorative: surrounding text carries the message.
class SparkMascot extends StatelessWidget {
  const SparkMascot({super.key, this.size = 72});
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset('assets/mascot/spark.png', width: size, height: size,
        fit: BoxFit.contain, filterQuality: FilterQuality.high),
  );
}
