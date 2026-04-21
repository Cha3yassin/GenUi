import 'package:flutter/material.dart';

import '../../shared/models/document_model.dart';

class ChecklistBlockWidget extends StatelessWidget {
  const ChecklistBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((item) => DocumentModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [for (final item in items) _ChecklistItem(document: item)],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.document});

  final DocumentModel document;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.24),
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 17,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (document.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    document.note!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
