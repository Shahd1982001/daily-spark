import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Spark's face and limbs are separate illustrated layers. Idle and celebration
/// animate the arms, feet and blinks, not just the overall picture. When the OS
/// requests reduced motion, the original still artwork is used instead.
class SparkMascot extends StatefulWidget {
  const SparkMascot({super.key, this.size = 72, this.animate = false,
    this.concerned = false, this.celebrating = false, this.walking = false});
  final double size;
  final bool animate;
  final bool concerned;
  final bool celebrating;
  final bool walking;
  @override
  State<SparkMascot> createState() => _SparkMascotState();
}

class _SparkMascotState extends State<SparkMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 3200));
  bool _reduceMotion = false;

  void _updateAnimation() {
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.animate && !_reduceMotion && TickerMode.of(context)) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void didChangeDependencies() { super.didChangeDependencies(); _updateAnimation(); }
  @override
  void didUpdateWidget(covariant SparkMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) _updateAnimation();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  Widget _layer(String part) {
    final mood = widget.celebrating ? 'laugh' : widget.concerned ? 'concerned' : 'happy';
    return Image.asset('assets/mascot/${mood}_$part.png',
      width: widget.size, height: widget.size, fit: BoxFit.contain,
      filterQuality: FilterQuality.high, excludeFromSemantics: true);
  }

  double _blink(double t) {
    // A quick blink roughly every 3.2 seconds.
    if (t < .71 || t > .79) return 0;
    return (1 - ((t - .75).abs() / .04)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate || _reduceMotion) {
      return ExcludeSemantics(child: Image.asset(
        widget.celebrating ? 'assets/mascot/spark_laugh.png' : widget.concerned ? 'assets/mascot/spark_concerned.png' : 'assets/mascot/spark.png',
        width: widget.size, height: widget.size, fit: BoxFit.contain,
        filterQuality: FilterQuality.high));
    }
    return ExcludeSemantics(child: SizedBox(width: widget.size, height: widget.size,
      child: AnimatedBuilder(animation: _controller, builder: (context, _) {
        final t = _controller.value;
        final wave = math.sin(t * 2 * math.pi);
        final energy = widget.celebrating ? 1.7 : 1.0;
        final blink = widget.celebrating ? 0.0 : _blink(t);
        final walk = widget.walking ? 2.0 : 1.0;
        return Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
          Transform.rotate(angle: -.18 * wave * energy, alignment: const Alignment(-.77, .05), child: _layer('left_arm')),
          Transform.rotate(angle: .18 * wave * energy, alignment: const Alignment(.77, .05), child: _layer('right_arm')),
          Transform.rotate(angle: .08 * wave * energy * walk, alignment: const Alignment(-.27, .65), child: _layer('left_foot')),
          Transform.rotate(angle: -.08 * wave * energy * walk, alignment: const Alignment(.27, .65), child: _layer('right_foot')),
          _layer('body'),
          if (blink > 0) Opacity(opacity: blink, child: _layer('body_closed')),
        ]);
      }),
    ));
  }
}
