/// Lightweight history model for the sidebar drawer.
class HistorySummary {
  const HistorySummary({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime createdAt;

  factory HistorySummary.fromJson(Map<String, dynamic> json) {
    return HistorySummary(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
