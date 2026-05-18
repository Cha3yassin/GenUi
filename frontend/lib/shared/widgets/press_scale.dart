import 'package:flutter/material.dart';

/// Wraps any widget with a satisfying press-scale micro-interaction.
/// On press: scales to 0.97 with spring physics.
/// On release: springs back to 1.0.
class PressScale extends StatefulWidget {
  const PressScale({required this.child, this.onTap, this.scaleTo = 0.97, super.key});

  final Widget child;
  final VoidCallback? onTap;
  final double scaleTo;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 280),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleTo).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: const _SpringCurve(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// Custom spring curve for the release animation.
class _SpringCurve extends Curve {
  const _SpringCurve();

  @override
  double transformInternal(double t) {
    // Attempt to use a spring simulation approximation
    // damping ratio ~0.6, slightly bouncy but not cartoonish
    final val = 1.0 - (1.0 - t) * (1.0 - t);
    // Add a subtle overshoot
    if (t < 0.7) {
      return val;
    }
    return 1.0 + (1.0 - t) * 0.02 * (t - 0.7) / 0.3; // micro-bounce
  }
}
