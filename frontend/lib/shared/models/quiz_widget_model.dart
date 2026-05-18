import 'dart:math';

import '../../renderer/models/ui_block_model.dart';

class QuizWidgetModel {
  const QuizWidgetModel({
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.language,
    required this.questions,
    required this.resultBands,
    required this.source,
  });

  final String title;
  final String subtitle;
  final String topic;
  final String language;
  final List<QuizQuestionModel> questions;
  final List<QuizResultBandModel> resultBands;
  final String source;

  factory QuizWidgetModel.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List<dynamic>? ?? [])
        .map((item) => QuizQuestionModel.fromJson(item as Map<String, dynamic>))
        .toList();

    if (questions.isEmpty) {
      throw const FormatException('AI quiz has no questions.');
    }

    final resultBands = (json['result_bands'] as List<dynamic>? ?? [])
        .map((item) =>
            QuizResultBandModel.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.minScore.compareTo(b.minScore));

    return QuizWidgetModel(
      title: json['title']?.toString() ?? 'AI quiz',
      subtitle: json['subtitle']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      language: json['language']?.toString() ?? 'fr',
      questions: questions,
      resultBands: resultBands,
      source: json['source']?.toString() ?? 'AI generated',
    );
  }

  QuizResultBandModel resultBandForScore(int score) {
    QuizResultBandModel? selected;
    for (final band in resultBands) {
      if (score >= band.minScore) {
        selected = band;
      }
    }
    return selected ??
        QuizResultBandModel(
          minScore: 0,
          title: title,
          message: subtitle,
          blocks: const [],
        );
  }
}

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>? ?? [])
        .map((item) {
          if (item is Map<String, dynamic>) return item['text']?.toString();
          return item.toString();
        })
        .whereType<String>()
        .where((item) => item.trim().isNotEmpty)
        .toList();

    final correctIndex = (json['correct_index'] as num?)?.toInt() ?? 0;
    if (correctIndex < 0 || correctIndex >= options.length) {
      throw const FormatException('AI quiz answer index is invalid.');
    }
    final shuffled = _shuffleOptions(
      options: options,
      correctIndex: correctIndex,
      seedText: '${json['prompt']}-${json['explanation']}',
    );

    return QuizQuestionModel(
      prompt: json['prompt']?.toString() ?? '',
      options: shuffled.options,
      correctIndex: shuffled.correctIndex,
      explanation: json['explanation']?.toString() ?? '',
    );
  }

  static ({List<String> options, int correctIndex}) _shuffleOptions({
    required List<String> options,
    required int correctIndex,
    required String seedText,
  }) {
    final pairs = [
      for (int i = 0; i < options.length; i++)
        (text: options[i], wasCorrect: i == correctIndex),
    ];
    final seed = seedText.codeUnits.fold<int>(
      DateTime.now().microsecondsSinceEpoch,
      (value, unit) => (value * 31 + unit) & 0x7fffffff,
    );
    pairs.shuffle(Random(seed));
    final newCorrectIndex = pairs.indexWhere((item) => item.wasCorrect);
    return (
      options: pairs.map((item) => item.text).toList(),
      correctIndex: newCorrectIndex,
    );
  }
}

class QuizResultBandModel {
  const QuizResultBandModel({
    required this.minScore,
    required this.title,
    required this.message,
    required this.blocks,
  });

  final int minScore;
  final String title;
  final String message;
  final List<UiBlockModel> blocks;

  factory QuizResultBandModel.fromJson(Map<String, dynamic> json) {
    return QuizResultBandModel(
      minScore: (json['min_score'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      blocks: (json['blocks'] as List<dynamic>? ?? [])
          .map((item) => UiBlockModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
