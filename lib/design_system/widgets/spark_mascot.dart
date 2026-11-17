import 'package:flutter/material.dart';

/// The selected Spark character. Set [animate] for a subtle idle motion;
/// reduced-motion settings always win. Surrounding text carries the message.
class SparkMascot extends StatefulWidget {
  const SparkMascot({super.key, this.size = 72, this.animate = false, this.concerned = false});
  final double size;
  final bool animate;
  final bool concerned;
  @override
  State<SparkMascot> createState() => _SparkMascotState();
}

class _SparkMascotState extends State<SparkMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 1800));

  void _updateAnimation() {
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.animate && !reduced && TickerMode.of(context)) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
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

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(animation: _controller,
      child: Image.asset(widget.concerned ? 'assets/mascot/spark_concerned.png' : 'assets/mascot/spark.png',
          width: widget.size, height: widget.size,
          fit: BoxFit.contain, filterQuality: FilterQuality.high),
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -3 * Curves.easeInOut.transform(_controller.value)), child: child),
    ),
  );
}
