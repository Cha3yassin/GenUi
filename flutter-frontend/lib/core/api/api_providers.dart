import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/office_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => MockApiService());

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(apiServiceProvider).getCategories();
});

final procedureDetailProvider = FutureProvider.family<ProcedureModel, String>((
  ref,
  slug,
) {
  return ref.watch(apiServiceProvider).getProcedureDetail(slug);
});

final categoryProceduresProvider =
    FutureProvider.family<List<ProcedureSummaryModel>, String>((
      ref,
      categoryId,
    ) {
      return ref.watch(apiServiceProvider).getProceduresByCategory(categoryId);
    });

final nearbyOfficesProvider = FutureProvider.family<List<OfficeModel>, String?>(
  (ref, stepId) {
    return ref.watch(apiServiceProvider).getNearbyOffices(stepId: stepId);
  },
);

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }
}

final searchResultsProvider = FutureProvider<List<ProcedureSummaryModel>>((
  ref,
) {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(apiServiceProvider).searchProcedures(query);
});
