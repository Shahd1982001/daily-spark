import 'package:flutter/material.dart';

/// The selected original artwork, kept still while new pose sequences are
/// prepared. Every pet pose will share a registered canvas and stable scale.
class SparkMascot extends StatelessWidget {
  const SparkMascot({super.key, this.size = 72});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: Image.asset(
    'assets/mascot/spark.png', width: size, height: size,
    fit: BoxFit.contain, filterQuality: FilterQuality.high,
  ));
}
