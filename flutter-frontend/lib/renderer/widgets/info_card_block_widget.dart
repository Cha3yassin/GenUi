import 'package:flutter/material.dart';

class InfoCardBlockWidget extends StatelessWidget {
  const InfoCardBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'Information';
    final body = data['body'] as String? ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _iconFromName(data['icon'] as String?),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(body, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFromName(String? iconName) {
    return switch (iconName) {
      'shield' => Icons.verified_user_rounded,
      'passport' => Icons.badge_rounded,
      'business' => Icons.business_center_rounded,
      _ => Icons.info_rounded,
    };
  }
}
