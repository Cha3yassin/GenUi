class DocumentModel {
  const DocumentModel({required this.title, this.note, this.required = true});

  final String title;
  final String? note;
  final bool required;

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      title: json['title'] as String,
      note: json['note'] as String?,
      required: json['required'] as bool? ?? true,
    );
  }
}
