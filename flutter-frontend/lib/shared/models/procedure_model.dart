import '../../renderer/models/ui_block_model.dart';
import 'procedure_summary_model.dart';

class ProcedureModel {
  const ProcedureModel({
    required this.summary,
    required this.currentStep,
    required this.totalSteps,
    required this.blocks,
  });

  final ProcedureSummaryModel summary;
  final int currentStep;
  final int totalSteps;
  final List<UiBlockModel> blocks;

  double get progress => totalSteps == 0 ? 0 : currentStep / totalSteps;

  factory ProcedureModel.fromJson(Map<String, dynamic> json) {
    return ProcedureModel(
      summary: ProcedureSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      currentStep: json['currentStep'] as int? ?? 1,
      totalSteps: json['totalSteps'] as int? ?? 1,
      blocks: (json['blocks'] as List<dynamic>? ?? [])
          .map((item) => UiBlockModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
