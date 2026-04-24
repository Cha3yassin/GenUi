import 'package:flutter/material.dart';

import '../../core/genui/profile_config.dart';

class ContextualHeader extends StatelessWidget {
  const ContextualHeader({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.theme,
    this.trailing,
    super.key,
  });

  final String badge;
  final String title;
  final String subtitle;
  final ProfileThemeData theme;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.heroGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderTint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: theme.badgeColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: theme.badgeColor,
                      ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                Expanded(
                    child:
                        Align(alignment: Alignment.topRight, child: trailing)),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 30,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
