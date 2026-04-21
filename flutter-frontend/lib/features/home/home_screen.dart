import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_paths.dart';
import '../../core/utils/async_value_widget.dart';
import '../../shared/models/category_model.dart';
import '../../shared/widgets/category_card.dart';
import '../../shared/widgets/sahil_chip_button.dart';
import '../../shared/widgets/sahil_search_bar.dart';
import '../../shared/widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesValue = ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(),
              const SizedBox(height: 24),
              SahilSearchBar(
                hintText: 'Search: carte grise, passeport, entreprise',
                readOnly: true,
                onTap: () => context.push(RoutePaths.search),
              ),
              const SizedBox(height: 28),
              const SectionHeader(
                title: 'Browse by category',
                subtitle: 'Pick the administration area you need.',
              ),
              const SizedBox(height: 14),
              AsyncValueWidget<List<CategoryModel>>(
                value: categoriesValue,
                data: (categories) => _CategoryGrid(categories: categories),
              ),
              const SizedBox(height: 30),
              const SectionHeader(
                title: 'Popular this week',
                subtitle: 'Common procedures people are checking now.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SahilChipButton(
                    label: 'Buy a car',
                    icon: Icons.directions_car_rounded,
                    onPressed: () =>
                        context.push(RoutePaths.procedure('buy-used-car')),
                  ),
                  SahilChipButton(
                    label: 'Passport renewal',
                    icon: Icons.badge_rounded,
                    onPressed: () =>
                        context.push(RoutePaths.procedure('passport-renewal')),
                  ),
                  SahilChipButton(
                    label: 'Register a company',
                    icon: Icons.business_center_rounded,
                    onPressed: () =>
                        context.push(RoutePaths.procedure('register-company')),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _TrustCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                AppConstants.appTagline,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Center(
            child: Text(
              AppConstants.appArabicName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          onTap: () => context.push(RoutePaths.categoryProcedures(category.id)),
        );
      },
    );
  }
}

class _TrustCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.fact_check_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guidance before the counter',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sahil organizes documents, fees and offices so you can plan visits with less uncertainty.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
