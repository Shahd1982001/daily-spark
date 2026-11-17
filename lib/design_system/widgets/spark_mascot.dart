import 'dart:async';
import 'package:flutter/material.dart';

/// The same registered artwork in every frame; only its eyes change. No body
/// or limb transforms are applied. The opt-in screen uses the still default.
class SparkMascot extends StatefulWidget {
  const SparkMascot({super.key, this.size = 72, this.blink = false});
  final double size;
  final bool blink;

  @override
  State<SparkMascot> createState() => _SparkMascotState();
}

class _SparkMascotState extends State<SparkMascot> {
  static const _sequence = [1, 2, 3, 2, 1, 0];
  Timer? _timer;
  int _frame = 0, _index = 0;
  bool _allowed = false, _cached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cached && widget.blink) {
      _cached = true;
      for (var n = 1; n <= 3; n++) {
        precacheImage(AssetImage('assets/mascot/blink/blink_$n.png'), context);
      }
    }
    _sync();
  }

  @override
  void didUpdateWidget(covariant SparkMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blink != widget.blink) _sync();
  }

  void _sync() {
    final allowed = widget.blink && !(MediaQuery.maybeOf(context)?.disableAnimations ?? false) && TickerMode.of(context);
    if (allowed == _allowed) return;
    _allowed = allowed;
    _timer?.cancel();
    _frame = 0;
    if (allowed) _wait();
  }

  void _wait() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted || !_allowed) return;
      _index = 0;
      _next();
    });
  }

  void _next() {
    if (!mounted || !_allowed) return;
    setState(() => _frame = _sequence[_index++]);
    if (_index == _sequence.length) {
      _wait();
    } else {
      _timer = Timer(const Duration(milliseconds: 85), _next);
    }
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: Image.asset(
    _frame == 0 ? 'assets/mascot/spark.png' : 'assets/mascot/blink/blink_$_frame.png',
    width: widget.size, height: widget.size,
    fit: BoxFit.contain, filterQuality: FilterQuality.high,
  ));
}
