class FeeModel {
  const FeeModel({required this.label, required this.amount, this.note});

  final String label;
  final String amount;
  final String? note;

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      label: json['label'] as String,
      amount: json['amount'] as String,
      note: json['note'] as String?,
    );
  }
}
