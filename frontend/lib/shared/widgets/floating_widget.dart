import 'dart:math';
import 'package:flutter/material.dart';

/// Infinite subtle y-axis floating animation.
/// Used for empty state icons and hero card decorative icons.
class FloatingWidget extends StatefulWidget {
  const FloatingWidget({
    required this.child,
    this.amplitude = 4.0,
    this.period = const Duration(seconds: 3),
    super.key,
  });

  final Widget child;
  final double amplitude;
  final Duration period;

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final y = sin(_controller.value * pi) * widget.amplitude;
        return Transform.translate(offset: Offset(0, -y), child: child);
      },
      child: widget.child,
    );
  }
}
