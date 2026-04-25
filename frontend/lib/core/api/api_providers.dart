import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/history_summary_model.dart';
import '../../shared/models/office_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';
import '../auth/auth_provider.dart';
import '../locale/locale_provider.dart';
import 'api_service.dart';
import 'http_api_service.dart';
import 'procedure_guide_adapter.dart';

/// Provide the REAL API service
final apiServiceProvider = Provider<ApiService>((ref) => HttpApiService());

/// Categories — filtered by user role if authenticated.
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  final role = ref.watch(userRoleProvider);
  return ref.watch(apiServiceProvider).getCategories(role: role);
});

/// Procedure detail — passes user role for context-aware generation.
/// When authenticated, the auth token is passed so the result is auto-saved to history.
final procedureDetailProvider = FutureProvider.family<ProcedureModel, String>((
  ref,
  slug,
) async {
  final role = ref.watch(userRoleProvider);
  final locale = ref.watch(localeProvider);
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.read(authProvider);

  // Pass auth token so the API service can save to history (fire-and-forget)
  final token =
      authState.isAuthenticated ? authState.user!.firebaseToken : null;

  return apiService.getProcedureDetail(slug,
      role: role, authToken: token, language: locale);
});

final categoryProceduresProvider =
    FutureProvider.family<List<ProcedureSummaryModel>, String>((
  ref,
  categoryId,
) {
  final locale = ref.watch(localeProvider);
  return ref
      .watch(apiServiceProvider)
      .getProceduresByCategory(categoryId, language: locale);
});

typedef NearbyOfficesQuery = ({String? stepId, double? lat, double? lng});

final nearbyOfficesProvider =
    FutureProvider.family<List<OfficeModel>, NearbyOfficesQuery>(
  (ref, query) {
    return ref.watch(apiServiceProvider).getNearbyOffices(
          stepId: query.stepId,
          lat: query.lat,
          lng: query.lng,
        );
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

/// Debounced search results provider
final searchResultsProvider = FutureProvider<List<ProcedureSummaryModel>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  final locale = ref.watch(localeProvider);

  if (query.trim().length < 2) {
    return [];
  }

  var isCancelled = false;
  ref.onDispose(() {
    isCancelled = true;
  });

  await Future<void>.delayed(const Duration(milliseconds: 400));

  if (isCancelled) {
    throw Exception('Search cancelled due to debounce');
  }

  return ref
      .watch(apiServiceProvider)
      .searchProcedures(query, language: locale);
});

/// History summaries for the drawer (requires auth).
final historySummariesProvider =
    FutureProvider<List<HistorySummary>>((ref) async {
  final authState = ref.watch(authProvider);
  final locale = ref.watch(localeProvider);
  if (!authState.isAuthenticated) return [];

  final token = authState.user!.firebaseToken;
  return ref
      .watch(apiServiceProvider)
      .getHistorySummaries(token, language: locale);
});

/// History detail — fetches full JSON for a past procedure, renders instantly.
final historyDetailProvider =
    FutureProvider.family<ProcedureModel, String>((ref, historyId) async {
  final authState = ref.watch(authProvider);
  final locale = ref.watch(localeProvider);
  if (!authState.isAuthenticated) {
    throw Exception('Not authenticated');
  }

  final token = authState.user!.firebaseToken;
  final data =
      await ref.watch(apiServiceProvider).getHistoryDetail(token, historyId);

  // ai_response may come as a Map directly or as a JSON string
  final rawAiResponse = data['ai_response'];
  final Map<String, dynamic> aiResponse;
  if (rawAiResponse is Map<String, dynamic>) {
    aiResponse = rawAiResponse;
  } else if (rawAiResponse is String) {
    aiResponse = (jsonDecode(rawAiResponse) as Map<String, dynamic>);
  } else {
    throw Exception('Invalid ai_response format');
  }

  return ProcedureGuideAdapter.fromJson(
    aiResponse,
    slug: 'history-$historyId',
    language: locale,
  );
});
