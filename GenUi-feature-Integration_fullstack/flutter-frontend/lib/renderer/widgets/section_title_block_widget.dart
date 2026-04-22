import 'package:flutter/material.dart';

import '../../shared/widgets/section_header.dart';

class SectionTitleBlockWidget extends StatelessWidget {
  const SectionTitleBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SectionHeader(
        title: data['title'] as String? ?? '',
        subtitle: data['subtitle'] as String?,
      ),
    );
  }
}
