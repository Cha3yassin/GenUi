import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedReveal extends StatefulWidget {
  const AnimatedReveal({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.04),
    this.duration = const Duration(milliseconds: 420),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  State<AnimatedReveal> createState() => _AnimatedRevealState();
}

class _AnimatedRevealState extends State<AnimatedReveal> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : widget.offset,
        child: widget.child,
      ),
    );
  }
}
