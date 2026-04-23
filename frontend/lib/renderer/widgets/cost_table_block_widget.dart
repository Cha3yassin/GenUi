import 'package:flutter/material.dart';

import '../../shared/models/fee_model.dart';

class CostTableBlockWidget extends StatelessWidget {
  const CostTableBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final fees = (data['fees'] as List<dynamic>? ?? [])
        .map((item) => FeeModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: [for (final fee in fees) _FeeRow(fee: fee)]),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({required this.fee});

  final FeeModel fee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fee.label, style: Theme.of(context).textTheme.titleSmall),
                if (fee.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    fee.note!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            fee.amount,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
