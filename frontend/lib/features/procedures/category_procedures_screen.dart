import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_providers.dart';
import '../../core/constants/route_paths.dart';
import '../../core/utils/async_value_widget.dart';
import '../../shared/models/procedure_summary_model.dart';
import '../../shared/widgets/procedure_card.dart';

class CategoryProceduresScreen extends ConsumerWidget {
  const CategoryProceduresScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proceduresValue = ref.watch(categoryProceduresProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: Text(_titleForCategory(categoryId))),
      body: SafeArea(
        child: AsyncValueWidget<List<ProcedureSummaryModel>>(
          value: proceduresValue,
          data: (procedures) {
            if (procedures.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No procedures are available in this category yet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: procedures.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final procedure = procedures[index];
                return ProcedureCard(
                  procedure: procedure,
                  onTap: () =>
                      context.push(RoutePaths.procedure(procedure.slug)),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _titleForCategory(String id) {
    return switch (id) {
      'vehicles' => 'Vehicles',
      'real-estate' => 'Real Estate',
      'business' => 'Business',
      'civil-status' => 'Civil Status',
      _ => 'Procedures',
    };
  }
}
