import 'package:flutter/material.dart';

import '../../../services/calc/scoring.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/progress/labeled_progress_bar.dart';
import '../../widgets/progress/progress_ring.dart';

class DailyResult {
  final ChallengeMeasures measures;
  final String title;
  final String choiceLabel;
  final String afterwards;
  final int xpEarned;

  const DailyResult({
    required this.measures,
    required this.title,
    required this.choiceLabel,
    required this.afterwards,
    required this.xpEarned,
  });
}

class DailyResultView extends StatelessWidget {
  final DailyResult result;
  final VoidCallback onContinue;

  const DailyResultView({
    super.key,
    required this.result,
    required this.onContinue,
  });

  static const fillDuration = Duration(milliseconds: 1200);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final measures = result.measures;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: measures.score / 100),
                    duration: fillDuration,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => ProgressRing(
                      value: value,
                      color: AppColors.mintChart,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(value * 100).round()}',
                            style: textTheme.headlineMedium,
                          ),
                          Text('sur 100', style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'★' * measures.stars}'
                          '${'☆' * (3 - measures.stars)}',
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                        Text(result.title, style: textTheme.titleLarge),
                        Text(
                          result.choiceLabel,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Pourquoi ce score', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    LabeledProgressBar(
                      label: 'Cohérence avec votre plan',
                      value: measures.coherence / 100,
                    ),
                    const SizedBox(height: 12),
                    LabeledProgressBar(
                      label: 'Prudence',
                      value: measures.prudence / 100,
                      color: AppColors.goldChart,
                    ),
                    const SizedBox(height: 12),
                    LabeledProgressBar(
                      label: 'Sang-froid',
                      value: measures.composure / 100,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Et ensuite ?', style: textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(result.afterwards, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    Text(
                      'Gagné',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '+${result.xpEarned} XP',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.goldText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
          child: PrimaryButton(text: 'Continuer', onPressed: onContinue),
        ),
      ],
    );
  }
}
