import 'dart:async';
import 'package:flutter/material.dart';

/// Frame sequences are drawn on the original registered canvas. Only eyes
/// change; no body or limb transforms. The opt-in screen remains still.
class SparkMascot extends StatefulWidget {
  const SparkMascot({super.key, this.size = 72, this.blink = false});
  final double size;
  final bool blink;

  @override
  State<SparkMascot> createState() => _SparkMascotState();
}

class _Pose {
  const _Pose(this.asset, this.duration);
  final String asset;
  final Duration duration;
}

class _SparkMascotState extends State<SparkMascot> {
  static const _open = 'assets/mascot/spark.png';
  static const _step = Duration(milliseconds: 85);
  static const _lookStep = Duration(milliseconds: 110);
  static const _hold = Duration(milliseconds: 650);
  static const _blink = [
    _Pose('assets/mascot/blink/blink_1.png', _step),
    _Pose('assets/mascot/blink/blink_2.png', _step),
    _Pose('assets/mascot/blink/blink_3.png', _step),
    _Pose('assets/mascot/blink/blink_2.png', _step),
    _Pose('assets/mascot/blink/blink_1.png', _step),
    _Pose(_open, _step),
  ];
  static const _look = [
    _Pose('assets/mascot/look/left_1.png', _lookStep),
    _Pose('assets/mascot/look/left_2.png', _lookStep),
    _Pose('assets/mascot/look/left_3.png', _hold),
    _Pose('assets/mascot/look/left_2.png', _lookStep),
    _Pose('assets/mascot/look/left_1.png', _lookStep),
    _Pose(_open, Duration(milliseconds: 220)),
    _Pose('assets/mascot/look/right_1.png', _lookStep),
    _Pose('assets/mascot/look/right_2.png', _lookStep),
    _Pose('assets/mascot/look/right_3.png', _hold),
    _Pose('assets/mascot/look/right_2.png', _lookStep),
    _Pose('assets/mascot/look/right_1.png', _lookStep),
    _Pose(_open, _lookStep),
  ];
  Timer? _timer;
  String _frame = _open;
  int _index = 0;
  bool _allowed = false, _cached = false, _nextLook = false;
  List<_Pose> _sequence = _blink;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cached && widget.blink) {
      _cached = true;
      for (final pose in [..._blink, ..._look]) {
        if (pose.asset != _open) precacheImage(AssetImage(pose.asset), context);
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
    _frame = _open;
    if (allowed) _wait();
  }

  void _wait() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted || !_allowed) return;
      _sequence = _nextLook ? _look : _blink;
      _nextLook = !_nextLook;
      _index = 0;
      _next();
    });
  }

  void _next() {
    if (!mounted || !_allowed) return;
    if (_index == _sequence.length) {
      _wait();
      return;
    }
    final pose = _sequence[_index++];
    setState(() => _frame = pose.asset);
    _timer = Timer(pose.duration, _next);
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: Image.asset(
    _frame, width: widget.size, height: widget.size,
    fit: BoxFit.contain, filterQuality: FilterQuality.high,
  ));
}
