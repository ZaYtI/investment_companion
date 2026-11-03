import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/mascot/floating_pip.dart';

class LessonResultView extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int passingScore;
  final int xp;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const LessonResultView({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.passingScore,
    required this.xp,
    required this.onRetry,
    required this.onBack,
  });

  bool get isPassed => correctAnswers >= passingScore;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Center(child: FloatingPip(width: 90)),
        const SizedBox(height: 24),
        Text(
          isPassed ? 'Niveau validé !' : 'Presque !',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '$correctAnswers bonne${correctAnswers > 1 ? 's' : ''} réponse'
          '${correctAnswers > 1 ? 's' : ''} sur $totalQuestions',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Text(
          isPassed
              ? '+$xp XP'
              : 'Il faut $passingScore bonnes réponses pour valider.',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: isPassed ? AppColors.goldText : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        if (isPassed)
          PrimaryButton(text: 'Retour au chapitre', onPressed: onBack)
        else ...[
          PrimaryButton(text: 'Recommencer le quiz', onPressed: onRetry),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onBack,
            child: const Text('Retour au chapitre'),
          ),
        ],
      ],
    );
  }
}
