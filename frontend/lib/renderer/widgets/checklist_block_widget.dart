import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/models/document_model.dart';

/// Interactive checklist — checkboxes are unchecked by default and toggleable.
class ChecklistBlockWidget extends StatefulWidget {
  const ChecklistBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  State<ChecklistBlockWidget> createState() => _ChecklistBlockWidgetState();
}

class _ChecklistBlockWidgetState extends State<ChecklistBlockWidget> {
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    final items = widget.data['items'] as List<dynamic>? ?? [];
    _checked = List.filled(items.length, false);
  }

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
            for (int i = 0; i < items.length; i++)
              _ChecklistItem(
                document: items[i],
                isChecked: _checked[i],
                onChanged: (value) {
                  setState(() => _checked[i] = value ?? false);
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
    required this.isChecked,
    required this.onChanged,
  });

  final DocumentModel document;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: AppTheme.olive,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(
                color: AppTheme.borderLight,
                width: 1.5,
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isChecked
                        ? AppTheme.mutedInk.withOpacity(0.5)
                        : AppTheme.ink,
                    decoration:
                        isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (document.note != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    document.note!,
                    style: Theme.of(context).textTheme.bodySmall,
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
