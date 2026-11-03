import 'package:flutter/material.dart';

import '../../../models/quiz_question.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badges/app_badge.dart';
import '../../widgets/cards/selectable_card.dart';

class ReadingQuestionCard extends StatefulWidget {
  final QuizQuestion question;
  final VoidCallback onAnswered;

  const ReadingQuestionCard({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<ReadingQuestionCard> createState() => _ReadingQuestionCardState();
}

class _ReadingQuestionCardState extends State<ReadingQuestionCard> {
  static const letters = ['A', 'B', 'C', 'D'];

  int? _selectedChoice;

  bool get _hasAnswered => _selectedChoice != null;

  void _answer(int choice) {
    if (_hasAnswered) return;
    setState(() => _selectedChoice = choice);
    widget.onAnswered();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final question = widget.question;
    final isCorrect = _selectedChoice == question.answerIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('LECTURE GUIDÉE', style: textTheme.labelMedium),
        const SizedBox(height: 8),
        Text(question.question, style: textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final (index, choice) in question.choices.indexed) ...[
          SelectableCard(
            leading: AppBadge.text(letters[index]),
            title: choice,
            borderColor: _borderColorFor(index),
            onTap: () => _answer(index),
          ),
          const SizedBox(height: 12),
        ],
        if (_hasAnswered) ...[
          Text(
            isCorrect ? 'Bien vu !' : 'Pas tout à fait',
            style: textTheme.titleMedium?.copyWith(
              color: isCorrect ? AppColors.mintText : AppColors.redText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(question.explanation, style: textTheme.bodyMedium),
        ],
      ],
    );
  }

  Color? _borderColorFor(int index) {
    if (!_hasAnswered) return null;
    if (index == widget.question.answerIndex) return AppColors.mint;
    if (index == _selectedChoice) return AppColors.redText;
    return null;
  }
}
