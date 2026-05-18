import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Shimmer skeleton loader for loading states.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.isCircle = false,
    super.key,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.isCircle ? widget.height : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFF5F0EB),  // warm cream
              const Color(0xFFEDE4D8),  // light gold
              _animation.value,
            ),
            borderRadius: widget.isCircle
                ? BorderRadius.circular(widget.height / 2)
                : BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// A card-shaped skeleton for loading states.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({this.height = 120, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SkeletonLoader(width: 90, height: 10),
          const SkeletonLoader(height: 16),
          SkeletonLoader(width: MediaQuery.of(context).size.width * 0.5, height: 12),
        ],
      ),
    );
  }
}

/// Skeleton for procedure list items.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: const [
          SkeletonLoader(height: 48, isCircle: false, width: 48, borderRadius: 14),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 14),
                SizedBox(height: 8),
                SkeletonLoader(width: 120, height: 10),
              ],
            ),
          ),
          SkeletonLoader(width: 14, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}
