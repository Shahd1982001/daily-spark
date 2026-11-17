import 'dart:typed_data';
import 'package:flutter/material.dart';

/// The same local photo in Profile and navigation; spark mark is the fallback.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.bytes, required this.size});
  final Uint8List? bytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Center(child: Image.asset('assets/brand/spark_logo.png',
        width: size * .62, height: size * .62, filterQuality: FilterQuality.high));
    final photo = bytes;
    if (photo == null) return SizedBox(width: size, height: size, child: fallback());
    return ClipOval(child: Image.memory(photo, width: size, height: size,
      fit: BoxFit.cover, filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size, child: fallback()),
    ));
  }
}
