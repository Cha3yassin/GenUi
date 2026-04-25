import 'package:flutter/material.dart';

/// Auto-animates children with staggered fade + slide + scale entry.
/// Each child fades in, slides up, and scales from 0.95→1.0.
class StaggeredColumn extends StatefulWidget {
  const StaggeredColumn({
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.staggerMs = 80,
    this.slideDist = 0.06,
    super.key,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final int staggerMs;
  final double slideDist;

  @override
  State<StaggeredColumn> createState() => _StaggeredColumnState();
}

class _StaggeredColumnState extends State<StaggeredColumn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final totalMs = 400 + (widget.children.length * widget.staggerMs);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = 400 + (widget.children.length * widget.staggerMs);

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        for (int i = 0; i < widget.children.length; i++)
          _StaggerItem(
            controller: _controller,
            index: i,
            totalMs: totalMs,
            staggerMs: widget.staggerMs,
            slideDist: widget.slideDist,
            child: widget.children[i],
          ),
      ],
    );
  }
}

class _StaggerItem extends StatelessWidget {
  const _StaggerItem({
    required this.controller,
    required this.index,
    required this.totalMs,
    required this.staggerMs,
    required this.slideDist,
    required this.child,
  });

  final AnimationController controller;
  final int index;
  final int totalMs;
  final int staggerMs;
  final double slideDist;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index * staggerMs) / totalMs;
    final begin = delay.clamp(0.0, 0.85);
    final end = (begin + 0.4).clamp(0.0, 1.0);

    final curve = CurvedAnimation(
      parent: controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    final fadeAnim = curve;
    final slideAnim = Tween<Offset>(
      begin: Offset(0, slideDist),
      end: Offset.zero,
    ).animate(curve);
    final scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(curve);

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: ScaleTransition(
          scale: scaleAnim,
          child: child,
        ),
      ),
    );
  }
}
