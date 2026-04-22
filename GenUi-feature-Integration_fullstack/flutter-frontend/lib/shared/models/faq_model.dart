class FaqModel {
  const FaqModel({required this.question, required this.answer});

  final String question;
  final String answer;

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}
