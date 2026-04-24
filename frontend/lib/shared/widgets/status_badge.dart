import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    this.color,
    this.icon,
    this.backgroundAlpha = 0.12,
    this.borderAlpha = 0.18,
    super.key,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final double backgroundAlpha;
  final double borderAlpha;

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? Theme.of(context).colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: badgeColor.withValues(alpha: borderAlpha)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: badgeColor),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: badgeColor),
            ),
          ],
        ),
      ),
    );
  }
}
