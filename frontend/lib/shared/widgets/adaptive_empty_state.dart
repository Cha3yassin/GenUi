import 'package:flutter/material.dart';

class AdaptiveEmptyState extends StatelessWidget {
  const AdaptiveEmptyState({
    required this.title,
    required this.body,
    this.icon = Icons.search_off_rounded,
    super.key,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
