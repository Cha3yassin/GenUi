import 'package:flutter/material.dart';

import '../../shared/models/document_model.dart';

class ChecklistBlockWidget extends StatefulWidget {
  const ChecklistBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  State<ChecklistBlockWidget> createState() => _ChecklistBlockWidgetState();
}

class _ChecklistBlockWidgetState extends State<ChecklistBlockWidget> {
  final Set<int> _checkedIndexes = <int>{};

  @override
  Widget build(BuildContext context) {
    final items = (widget.data['items'] as List<dynamic>? ?? [])
        .map((item) => DocumentModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++)
              _ChecklistItem(
                document: items[i],
                checked: _checkedIndexes.contains(i),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _checkedIndexes.add(i);
                    } else {
                      _checkedIndexes.remove(i);
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.document,
    required this.checked,
    required this.onChanged,
  });

  final DocumentModel document;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: checked,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        decoration:
                            checked ? TextDecoration.lineThrough : null,
                      ),
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
