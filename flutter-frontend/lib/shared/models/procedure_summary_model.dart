class ProcedureSummaryModel {
  const ProcedureSummaryModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.categoryId,
    required this.categoryLabel,
    required this.estimatedDuration,
    required this.estimatedCost,
    required this.officesToVisit,
  });

  final String id;
  final String slug;
  final String title;
  final String summary;
  final String categoryId;
  final String categoryLabel;
  final String estimatedDuration;
  final String estimatedCost;
  final int officesToVisit;

  factory ProcedureSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProcedureSummaryModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      categoryId: json['categoryId'] as String,
      categoryLabel: json['categoryLabel'] as String,
      estimatedDuration: json['estimatedDuration'] as String,
      estimatedCost: json['estimatedCost'] as String,
      officesToVisit: json['officesToVisit'] as int? ?? 0,
    );
  }
}
