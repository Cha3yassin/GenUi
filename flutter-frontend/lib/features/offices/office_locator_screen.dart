import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/utils/async_value_widget.dart';
import '../../renderer/widgets/office_map_placeholder_block_widget.dart';
import '../../shared/models/office_model.dart';
import '../../shared/widgets/office_card.dart';
import '../../shared/widgets/section_header.dart';

class OfficeLocatorScreen extends ConsumerWidget {
  const OfficeLocatorScreen({this.stepId, super.key});

  final String? stepId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officesValue = ref.watch(nearbyOfficesProvider(stepId));

    return Scaffold(
      appBar: AppBar(title: const Text('Find nearest office')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OfficeMapPlaceholderBlockWidget(
                data: {
                  'title': 'Nearby offices',
                  'subtitle':
                      'Map placeholder for future location integration.',
                },
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Recommended offices',
                subtitle:
                    'Mock results near Tunis. Replace with backend geosearch later.',
              ),
              const SizedBox(height: 14),
              AsyncValueWidget<List<OfficeModel>>(
                value: officesValue,
                data: (offices) => Column(
                  children: [
                    for (final office in offices) ...[
                      OfficeCard(office: office),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
