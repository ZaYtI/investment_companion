import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/level_type.dart';
import '../../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/mascot/floating_pip.dart';
import '../../widgets/progress/labeled_progress_bar.dart';

class ChallengeGauge {
  final String label;
  final int value;

  const ChallengeGauge(this.label, this.value);
}

class ChallengeResult {
  final int stars;
  final String title;
  final int? score;
  final List<ChallengeGauge> gauges;
  final String? explanation;
  final String? afterwards;

  const ChallengeResult({
    required this.stars,
    required this.title,
    this.score,
    this.gauges = const [],
    this.explanation,
    this.afterwards,
  });
}

class ChallengeScaffold extends ConsumerWidget {
  final int chapterNumber;
  final String situation;
  final String keyMessage;
  final List<Widget> children;
  final ChallengeResult? result;

  const ChallengeScaffold({
    super.key,
    required this.chapterNumber,
    required this.situation,
    required this.keyMessage,
    required this.children,
    this.result,
  });

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    await ref
        .read(progressProvider.notifier)
        .completeLevel(
          chapterNumber,
          LevelType.challenge.index,
          xpEarned: LevelType.challenge.xp,
          stars: result!.stars,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Défi terminé · +${LevelType.challenge.xp} XP')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final result = this.result;
    return Scaffold(
      appBar: AppBar(title: Text('Chapitre $chapterNumber · Défi')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Text(situation, style: textTheme.titleLarge),
                  const SizedBox(height: 20),
                  if (result == null)
                    ...children
                  else
                    _ResultView(result: result, keyMessage: keyMessage),
                ],
              ),
            ),
            if (result != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
                child: PrimaryButton(
                  text: 'Terminer le défi · +${LevelType.challenge.xp} XP',
                  onPressed: () => _finish(context, ref),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ChallengeResult result;
  final String keyMessage;

  const _ResultView({required this.result, required this.keyMessage});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: FloatingPip(width: 80)),
        const SizedBox(height: 12),
        Text(
          '${'★' * result.stars}${'☆' * (3 - result.stars)}',
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(color: AppColors.gold),
        ),
        if (result.score != null)
          Text(
            'Score : ${result.score} / 100',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
        const SizedBox(height: 8),
        Text(
          result.title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        if (result.gauges.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('POURQUOI CE SCORE', style: textTheme.labelMedium),
          const SizedBox(height: 8),
          for (final gauge in result.gauges) ...[
            LabeledProgressBar(label: gauge.label, value: gauge.value / 100),
            const SizedBox(height: 12),
          ],
        ],
        if (result.explanation != null) ...[
          const SizedBox(height: 12),
          Text(result.explanation!, style: textTheme.bodyLarge),
        ],
        if (result.afterwards != null) ...[
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ET ENSUITE ?', style: textTheme.labelMedium),
                const SizedBox(height: 6),
                Text(result.afterwards!, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.mintPale,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            keyMessage,
            style: textTheme.titleMedium?.copyWith(color: AppColors.mintText),
          ),
        ),
      ],
    );
  }
}
