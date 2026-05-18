import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api/api_providers.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../renderer/block_renderer.dart';
import '../../shared/models/quiz_widget_model.dart';
import '../../shared/widgets/press_scale.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  void _regenerate(WidgetRef ref) {
    ref.read(quizGenerationProvider.notifier).state++;
    ref.invalidate(generatedQuizProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final quizValue = ref.watch(generatedQuizProvider);
    final copy = _QuizCopy.forLocale(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(copy.title),
        actions: [
          IconButton(
            tooltip: copy.regenerate,
            onPressed: () => _regenerate(ref),
            icon: const Icon(Icons.auto_awesome_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: quizValue.when(
          loading: () => _LoadingQuiz(copy: copy),
          error: (error, _) => _QuizError(
            copy: copy,
            message: error.toString(),
            onRetry: () => _regenerate(ref),
          ),
          data: (quiz) => _GeneratedQuizView(
            key:
                ValueKey('${ref.watch(quizGenerationProvider)}-${quiz.source}'),
            quiz: quiz,
            copy: copy,
            onRegenerate: () => _regenerate(ref),
          ),
        ),
      ),
    );
  }
}

class _GeneratedQuizView extends StatefulWidget {
  const _GeneratedQuizView({
    required this.quiz,
    required this.copy,
    required this.onRegenerate,
    super.key,
  });

  final QuizWidgetModel quiz;
  final _QuizCopy copy;
  final VoidCallback onRegenerate;

  @override
  State<_GeneratedQuizView> createState() => _GeneratedQuizViewState();
}

class _GeneratedQuizViewState extends State<_GeneratedQuizView> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  int _score = 0;
  bool _isFinished = false;

  QuizQuestionModel get _question => widget.quiz.questions[_currentIndex];

  void _answer(int index) {
    if (_selectedAnswer != null || _isFinished) return;
    setState(() {
      _selectedAnswer = index;
      if (index == _question.correctIndex) {
        _score++;
      }
    });
  }

  void _next() {
    if (_selectedAnswer == null || _isFinished) return;
    final isLast = _currentIndex == widget.quiz.questions.length - 1;
    setState(() {
      if (isLast) {
        _isFinished = true;
      } else {
        _currentIndex++;
        _selectedAnswer = null;
      }
    });
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswer = null;
      _score = 0;
      _isFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _AiQuizHero(
          quiz: widget.quiz,
          copy: widget.copy,
          progress: _isFinished
              ? 1
              : (_currentIndex + 1) / widget.quiz.questions.length,
          score: _score,
          currentIndex: _currentIndex,
          isFinished: _isFinished,
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _isFinished
              ? _ResultView(
                  key: const ValueKey('result'),
                  quiz: widget.quiz,
                  copy: widget.copy,
                  score: _score,
                  onRestart: _restart,
                  onRegenerate: widget.onRegenerate,
                )
              : _QuestionView(
                  key: ValueKey(_currentIndex),
                  copy: widget.copy,
                  question: _question,
                  questionNumber: _currentIndex + 1,
                  totalQuestions: widget.quiz.questions.length,
                  selectedAnswer: _selectedAnswer,
                  onAnswer: _answer,
                  onNext: _next,
                ),
        ),
      ],
    );
  }
}

class _AiQuizHero extends StatelessWidget {
  const _AiQuizHero({
    required this.quiz,
    required this.copy,
    required this.progress,
    required this.score,
    required this.currentIndex,
    required this.isFinished,
  });

  final QuizWidgetModel quiz;
  final _QuizCopy copy;
  final double progress;
  final int score;
  final int currentIndex;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.olive.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.olive,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quiz.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 3),
                    Text(quiz.subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(icon: Icons.memory_rounded, label: copy.aiGenerated),
              _MetaPill(icon: Icons.widgets_rounded, label: copy.widgetPlan),
              _MetaPill(icon: Icons.source_rounded, label: quiz.source),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: AppTheme.surfaceTint,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFinished ? AppTheme.olive : AppTheme.terracotta,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isFinished
                ? '${copy.score}: $score/${quiz.questions.length}'
                : '${copy.question} ${currentIndex + 1}/${quiz.questions.length}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surfaceTint,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.terracotta),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppTheme.terracotta),
          ),
        ],
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.copy,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.onAnswer,
    required this.onNext,
    super.key,
  });

  final _QuizCopy copy;
  final QuizQuestionModel question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedAnswer;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isAnswered = selectedAnswer != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.prompt,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 18),
        for (int i = 0; i < question.options.length; i++) ...[
          _AnswerTile(
            label: question.options[i],
            index: i,
            isSelected: selectedAnswer == i,
            isCorrect: question.correctIndex == i,
            isAnswered: isAnswered,
            onTap: isAnswered ? null : () => onAnswer(i),
          ),
          const SizedBox(height: 10),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: isAnswered
              ? _ExplanationCard(
                  isCorrect: selectedAnswer == question.correctIndex,
                  explanation: question.explanation,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: isAnswered ? onNext : null,
          icon: Icon(
            questionNumber == totalQuestions
                ? Icons.flag_rounded
                : Icons.arrow_forward_rounded,
          ),
          label:
              Text(questionNumber == totalQuestions ? copy.finish : copy.next),
        ),
      ],
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isAnswered && isCorrect
        ? AppTheme.olive
        : isAnswered && isSelected
            ? const Color(0xFFB3261E)
            : isSelected
                ? AppTheme.terracotta
                : AppTheme.borderLight;
    final icon = isAnswered && isCorrect
        ? Icons.check_circle_rounded
        : isAnswered && isSelected
            ? Icons.cancel_rounded
            : Icons.radio_button_unchecked_rounded;

    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isAnswered || isSelected ? 0.09 : 0.0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: isSelected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.paper,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color == AppTheme.borderLight
                        ? AppTheme.mutedInk
                        : color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.isCorrect,
    required this.explanation,
  });

  final bool isCorrect;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppTheme.olive : AppTheme.actionOrange;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.lightbulb_rounded
                : Icons.tips_and_updates_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              explanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.ink,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.quiz,
    required this.copy,
    required this.score,
    required this.onRestart,
    required this.onRegenerate,
    super.key,
  });

  final QuizWidgetModel quiz;
  final _QuizCopy copy;
  final int score;
  final VoidCallback onRestart;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final band = quiz.resultBandForScore(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.olive.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.olive.withValues(alpha: 0.26)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(band.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                '${copy.score}: $score/${quiz.questions.length}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 12),
              Text(
                band.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.ink,
                    ),
              ),
            ],
          ),
        ),
        if (band.blocks.isNotEmpty) ...[
          const SizedBox(height: 18),
          BlockRenderer(blocks: band.blocks, locale: quiz.language),
        ],
        FilledButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.replay_rounded),
          label: Text(copy.retry),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onRegenerate,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text(copy.regenerate),
        ),
      ],
    );
  }
}

class _LoadingQuiz extends StatelessWidget {
  const _LoadingQuiz({required this.copy});

  final _QuizCopy copy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            Text(copy.generating,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              copy.generatingBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizError extends StatelessWidget {
  const _QuizError({
    required this.copy,
    required this.message,
    required this.onRetry,
  });

  final _QuizCopy copy;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.paper,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: AppTheme.actionOrange, size: 34),
              const SizedBox(height: 12),
              Text(copy.errorTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(copy.retryGeneration),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizCopy {
  const _QuizCopy({
    required this.title,
    required this.question,
    required this.score,
    required this.next,
    required this.finish,
    required this.retry,
    required this.regenerate,
    required this.retryGeneration,
    required this.generating,
    required this.generatingBody,
    required this.errorTitle,
    required this.aiGenerated,
    required this.widgetPlan,
  });

  final String title;
  final String question;
  final String score;
  final String next;
  final String finish;
  final String retry;
  final String regenerate;
  final String retryGeneration;
  final String generating;
  final String generatingBody;
  final String errorTitle;
  final String aiGenerated;
  final String widgetPlan;

  factory _QuizCopy.forLocale(String locale) {
    if (locale == 'en') return _en;
    return _fr;
  }

  static const _fr = _QuizCopy(
    title: 'Quiz IA',
    question: 'Question',
    score: 'Score',
    next: 'Suivant',
    finish: 'Voir le resultat',
    retry: 'Rejouer',
    regenerate: 'Regenerer avec IA',
    retryGeneration: 'Relancer IA',
    generating: 'IA genere le quiz...',
    generatingBody:
        'Le backend demande a l IA un widget quiz complet puis Flutter le rend.',
    errorTitle: 'Quiz IA indisponible',
    aiGenerated: 'Genere par IA',
    widgetPlan: 'Widget JSON',
  );

  static const _en = _QuizCopy(
    title: 'AI Quiz',
    question: 'Question',
    score: 'Score',
    next: 'Next',
    finish: 'See result',
    retry: 'Play again',
    regenerate: 'Regenerate with AI',
    retryGeneration: 'Retry AI',
    generating: 'AI is generating the quiz...',
    generatingBody:
        'The backend asks the AI for a full quiz widget, then Flutter renders it.',
    errorTitle: 'AI quiz unavailable',
    aiGenerated: 'AI generated',
    widgetPlan: 'JSON widget',
  );
}
