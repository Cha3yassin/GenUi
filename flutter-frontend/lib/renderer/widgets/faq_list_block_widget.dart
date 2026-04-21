import 'package:flutter/material.dart';

import '../../shared/models/faq_model.dart';

class FAQListBlockWidget extends StatelessWidget {
  const FAQListBlockWidget({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final faqs = (data['faqs'] as List<dynamic>? ?? [])
        .map((item) => FaqModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (final faq in faqs)
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 18),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  faq.question,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq.answer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
