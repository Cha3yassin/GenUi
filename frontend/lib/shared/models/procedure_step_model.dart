class ProcedureStepModel {
  const ProcedureStepModel({
    required this.id,
    required this.title,
    required this.description,
    required this.officeType,
    this.isCurrent = false,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final String officeType;
  final bool isCurrent;
  final bool isCompleted;

  factory ProcedureStepModel.fromJson(Map<String, dynamic> json) {
    return ProcedureStepModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      officeType: json['officeType'] as String? ?? '',
      isCurrent: json['isCurrent'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
