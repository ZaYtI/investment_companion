import 'package:flutter/material.dart';

import '../../../models/lesson_page.dart';
import '../../../models/quiz_question.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badges/app_badge.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/cards/selectable_card.dart';

class QuizView extends StatefulWidget {
  final LessonPage page;
  final ValueChanged<int> onFinished;

  const QuizView({super.key, required this.page, required this.onFinished});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  static const letters = ['A', 'B', 'C', 'D'];

  var _questionIndex = 0;
  var _correctAnswers = 0;
  int? _selectedChoice;

  QuizQuestion get _question => widget.page.questions[_questionIndex];
  bool get _hasAnswered => _selectedChoice != null;
  bool get _isLastQuestion =>
      _questionIndex == widget.page.questions.length - 1;

  void _answer(int choice) {
    if (_hasAnswered) return;
    setState(() {
      _selectedChoice = choice;
      if (choice == _question.answerIndex) _correctAnswers++;
    });
  }

  void _next() {
    if (_isLastQuestion) {
      widget.onFinished(_correctAnswers);
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedChoice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'QUESTION ${_questionIndex + 1} SUR ${widget.page.questions.length}',
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Text(_question.question, style: textTheme.headlineSmall),
        const SizedBox(height: 20),
        for (final (index, choice) in _question.choices.indexed) ...[
          SelectableCard(
            leading: AppBadge.text(letters[index]),
            title: choice,
            trailing: _trailingFor(index),
            borderColor: _borderColorFor(index),
            onTap: () => _answer(index),
          ),
          const SizedBox(height: 12),
        ],
        if (_hasAnswered) ...[
          _Explanation(
            isCorrect: _selectedChoice == _question.answerIndex,
            text: _question.explanation,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: _isLastQuestion ? 'Voir le résultat' : 'Question suivante',
            onPressed: _next,
          ),
        ],
      ],
    );
  }

  Color? _borderColorFor(int index) {
    if (!_hasAnswered) return null;
    if (index == _question.answerIndex) return AppColors.mint;
    if (index == _selectedChoice) return AppColors.redText;
    return null;
  }

  Widget? _trailingFor(int index) {
    if (!_hasAnswered) return null;
    if (index == _question.answerIndex) {
      return const Icon(Icons.check_circle, color: AppColors.mintText);
    }
    if (index == _selectedChoice) {
      return const Icon(Icons.cancel, color: AppColors.redText);
    }
    return null;
  }
}

class _Explanation extends StatelessWidget {
  final bool isCorrect;
  final String text;

  const _Explanation({required this.isCorrect, required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? 'Bien vu !' : 'Pas tout à fait',
            style: textTheme.titleMedium?.copyWith(
              color: isCorrect ? AppColors.mintText : AppColors.redText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(text, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
