import '../../shared/models/category_model.dart';
import '../../shared/models/history_summary_model.dart';
import '../../shared/models/office_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';

abstract class ApiService {
  Future<List<CategoryModel>> getCategories({String? role});

  Future<List<ProcedureSummaryModel>> searchProcedures(String query);

  Future<List<ProcedureSummaryModel>> getProceduresByCategory(
    String categoryId,
  );

  Future<ProcedureModel> getProcedureDetail(String slug, {String? role});

  Future<List<OfficeModel>> getNearbyOffices({
    String? stepId,
    double? lat,
    double? lng,
  });

  /// Fetch lightweight history summaries (title + date) for the drawer.
  Future<List<HistorySummary>> getHistorySummaries(String token);

  /// Fetch full history detail for re-rendering a past procedure.
  Future<Map<String, dynamic>> getHistoryDetail(String token, String historyId);
}
