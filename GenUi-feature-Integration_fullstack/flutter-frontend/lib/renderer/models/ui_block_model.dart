class UiBlockModel {
  const UiBlockModel({required this.type, required this.data});

  final String type;
  final Map<String, dynamic> data;

  factory UiBlockModel.fromJson(Map<String, dynamic> json) {
    return UiBlockModel(
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
    );
  }
}
