import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/progress_provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../../services/progression.dart';
import '../../../services/quiz_generator.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/cards/selectable_card.dart';
import '../../widgets/mascot/floating_pip.dart';
import '../../widgets/states/error_view.dart';

class QuizGameScreen extends ConsumerStatefulWidget {
  const QuizGameScreen({super.key});

  @override
  ConsumerState<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends ConsumerState<QuizGameScreen> {
  static const questionsPerRound = 5;
  static const startingLives = 3;

  List<ComparisonQuestion>? _round;
  var _questionIndex = 0;
  var _lives = startingLives;
  var _correctAnswers = 0;
  int? _selectedChoice;
  var _isFinished = false;

  List<ComparisonQuestion> _pickRound(List<ComparisonQuestion> questions) {
    final shuffled = [...questions]..shuffle(Random());
    return shuffled.take(questionsPerRound).toList();
  }

  void _startRound(List<ComparisonQuestion> questions) {
    setState(() {
      _round = _pickRound(questions);
      _questionIndex = 0;
      _lives = startingLives;
      _correctAnswers = 0;
      _selectedChoice = null;
      _isFinished = false;
    });
  }

  void _answer(ComparisonQuestion question, int choice) {
    if (_selectedChoice != null) return;
    final isCorrect = choice == question.answerIndex;
    if (isCorrect) {
      ref.read(progressProvider.notifier).addXp(quizAnswerXp);
    }
    setState(() {
      _selectedChoice = choice;
      if (isCorrect) {
        _correctAnswers++;
      } else {
        _lives--;
      }
    });
  }

  void _next() {
    final isLastQuestion = _questionIndex == _round!.length - 1;
    setState(() {
      if (_lives == 0 || isLastQuestion) {
        _isFinished = true;
      } else {
        _questionIndex++;
        _selectedChoice = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(quizQuestionsProvider);
    final round = _round ??= questions.value == null
        ? null
        : _pickRound(questions.value!);
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => context.pop()),
        title: round == null || _isFinished
            ? const Text('Plus ou moins ?')
            : LinearProgressIndicator(
                value: (_questionIndex + 1) / round.length,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
        actions: [
          for (var life = 0; life < startingLives; life++)
            Icon(
              Icons.favorite,
              color: life < _lives ? AppColors.red : AppColors.border,
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        top: false,
        child: questions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: ErrorView(message: 'Impossible de préparer le quiz.'),
          ),
          data: (questions) {
            if (round == null) return const SizedBox.shrink();
            if (_isFinished) return _buildSummary(questions, round.length);
            return _buildQuestion(round[_questionIndex], round.length);
          },
        ),
      ),
    );
  }

  Widget _buildQuestion(ComparisonQuestion question, int questionCount) {
    final textTheme = Theme.of(context).textTheme;
    final hasAnswered = _selectedChoice != null;
    final isCorrect = _selectedChoice == question.answerIndex;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                'PLUS OU MOINS · QUESTION ${_questionIndex + 1} SUR '
                '$questionCount',
                style: textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Text(question.question, style: textTheme.headlineSmall),
              const SizedBox(height: 20),
              for (final (index, asset) in question.choices.indexed) ...[
                SelectableCard(
                  title: asset.name,
                  subtitle: asset.category,
                  borderColor: !hasAnswered
                      ? null
                      : index == question.answerIndex
                      ? AppColors.mint
                      : index == _selectedChoice
                      ? AppColors.redText
                      : null,
                  trailing: hasAnswered && index == question.answerIndex
                      ? const Icon(Icons.check, color: AppColors.mintText)
                      : null,
                  onTap: () => _answer(question, index),
                ),
                const SizedBox(height: 12),
              ],
              if (hasAnswered)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: isCorrect ? 'Bien vu ! ' : 'Pas tout à fait',
                          style: textTheme.titleLarge?.copyWith(
                            color: isCorrect
                                ? AppColors.mintText
                                : AppColors.redText,
                          ),
                          children: [
                            if (isCorrect)
                              TextSpan(
                                text: '+$quizAnswerXp XP',
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.goldText,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(question.explanation, style: textTheme.bodyLarge),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (hasAnswered)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
            child: PrimaryButton(text: 'Continuer', onPressed: _next),
          ),
      ],
    );
  }

  Widget _buildSummary(List<ComparisonQuestion> questions, int questionCount) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const SizedBox(height: 24),
        const Center(child: FloatingPip(width: 90)),
        const SizedBox(height: 16),
        Text(
          _lives == 0 ? 'Plus de vies !' : 'Manche terminée',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '$_correctAnswers bonne${_correctAnswers > 1 ? 's' : ''} '
          'réponse${_correctAnswers > 1 ? 's' : ''} sur $questionCount',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Text(
          '+${_correctAnswers * quizAnswerXp} XP',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(color: AppColors.goldText),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Rejouer une manche',
          onPressed: () => _startRound(questions),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Retour à la carte'),
        ),
      ],
    );
  }
}
