import 'package:flutter/material.dart';

import '../../shared/models/office_model.dart';
import '../../shared/widgets/office_card.dart';

class OfficeListBlockWidget extends StatelessWidget {
  const OfficeListBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final offices = (data['offices'] as List<dynamic>? ?? [])
        .map((item) => OfficeModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return Column(
      children: [
        for (final office in offices) ...[
          OfficeCard(office: office),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
