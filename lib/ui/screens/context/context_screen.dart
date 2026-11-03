import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/chapters_data.dart';
import '../../../data/fake_progress.dart';
import '../../../models/chapter_summary.dart';
import '../../../models/progress_status.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badges/app_badge.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/states/error_view.dart';

class ContextScreen extends StatefulWidget {
  final int chapterNumber;

  const ContextScreen({super.key, required this.chapterNumber});

  @override
  State<ContextScreen> createState() => _ContextScreenState();
}

class _ContextScreenState extends State<ContextScreen> {
  late final Future<ChapterSummary> _chapter = loadChapterSummary(
    widget.chapterNumber,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contexte de l'époque")),
      body: FutureBuilder(
        future: _chapter,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: ErrorView(message: 'Impossible de charger ce contexte.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _ContextContent(chapter: snapshot.data!);
        },
      ),
    );
  }
}

class _ContextContent extends StatelessWidget {
  final ChapterSummary chapter;

  const _ContextContent({required this.chapter});

  static const factColors = [
    (AppColors.coralPale, AppColors.red),
    (AppColors.mintPale, AppColors.mintText),
    (AppColors.background, AppColors.assetCurrenciesAndChallenges),
  ];

  bool get _isChallengeDone =>
      FakeProgress.levelStatusOf(chapter.number, 2) == ProgressStatus.completed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final epoch = chapter.context!;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                Text(
                  'CHAPITRE ${chapter.number} · ${chapter.period}',
                  style: textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(epoch.question, style: textTheme.headlineSmall),
                const SizedBox(height: 16),
                for (final (index, fact) in epoch.facts.indexed) ...[
                  AppCard(
                    child: Row(
                      children: [
                        AppBadge.icon(
                          _iconFor(fact.icon),
                          background: factColors[index % 3].$1,
                          foreground: factColors[index % 3].$2,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(fact.text, style: textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ce que montrent les chiffres',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(epoch.figures, style: textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Calculé sur les cours réels, sans les dividendes.',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final keyword in epoch.keywords)
                      Chip(label: Text(keyword)),
                  ],
                ),
                const SizedBox(height: 12),
                _isChallengeDone
                    ? _Afterwards(text: epoch.afterwards)
                    : const _LockedAfterwards(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
            child: PrimaryButton(
              text: 'Retour au chapitre',
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String name) {
    return switch (name) {
      'trending_up' => Icons.trending_up,
      'trending_down' => Icons.trending_down,
      'arrow_upward' => Icons.arrow_upward,
      'account_balance' => Icons.account_balance,
      'coronavirus' => Icons.coronavirus_outlined,
      'memory' => Icons.memory,
      'savings' => Icons.savings_outlined,
      'calculate' => Icons.calculate_outlined,
      'show_chart' => Icons.show_chart,
      _ => Icons.info_outline,
    };
  }
}

class _Afterwards extends StatelessWidget {
  final String text;

  const _Afterwards({required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      borderColor: AppColors.mint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Et ensuite ?',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(text, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _LockedAfterwards extends StatelessWidget {
  const _LockedAfterwards();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.lock, color: AppColors.dashedBorder),
          const SizedBox(width: 14),
          Expanded(
            child: Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Et ensuite ? ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'Disponible après le défi, pour ne pas connaître '
                        "l'issue avant de choisir.",
                  ),
                ],
              ),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
