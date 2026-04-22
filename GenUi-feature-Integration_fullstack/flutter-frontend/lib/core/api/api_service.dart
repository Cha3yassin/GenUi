import '../../shared/models/category_model.dart';
import '../../shared/models/office_model.dart';
import '../../shared/models/procedure_model.dart';
import '../../shared/models/procedure_summary_model.dart';

abstract class ApiService {
  Future<List<CategoryModel>> getCategories();

  Future<List<ProcedureSummaryModel>> searchProcedures(String query);

  Future<List<ProcedureSummaryModel>> getProceduresByCategory(
    String categoryId,
  );

  Future<ProcedureModel> getProcedureDetail(String slug);

  Future<List<OfficeModel>> getNearbyOffices({
    String? stepId,
    double? lat,
    double? lng,
  });
}
