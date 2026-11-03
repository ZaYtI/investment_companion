import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/chapters_data.dart';
import '../../../models/chapter_summary.dart';
import '../../../models/level_type.dart';
import '../../../models/progress.dart';
import '../../../models/progress_status.dart';
import '../../../providers/progress_provider.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badges/app_badge.dart';
import '../../widgets/buttons/dashed_button.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/selectable_card.dart';
import '../../widgets/mascot/pip_island.dart';
import '../../widgets/states/error_view.dart';

class ChapterScreen extends StatefulWidget {
  final int chapterNumber;

  const ChapterScreen({super.key, required this.chapterNumber});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late final Future<ChapterSummary> _chapter = loadChapterSummary(
    widget.chapterNumber,
  );

  void _openLevel(int levelIndex) {
    context.push(AppRoutes.level(widget.chapterNumber, levelIndex));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => context.pop()),
        title: Text('Chapitre ${widget.chapterNumber}'),
      ),
      body: FutureBuilder(
        future: _chapter,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: ErrorView(message: 'Impossible de charger ce chapitre.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _ChapterContent(
            chapter: snapshot.data!,
            onOpenLevel: _openLevel,
          );
        },
      ),
    );
  }
}

class _ChapterContent extends ConsumerWidget {
  final ChapterSummary chapter;
  final ValueChanged<int> onOpenLevel;

  const _ChapterContent({required this.chapter, required this.onOpenLevel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(currentProgressProvider);
    final completedLevels = progress.completedLevelsIn(chapter.number);
    final isChapterCompleted = completedLevels == Progress.levelsPerChapter;
    final buttonText = isChapterCompleted
        ? 'Rejouer le chapitre'
        : completedLevels == 0
        ? 'Commencer'
        : 'Continuer';
    final nextLevelIndex = isChapterCompleted ? 0 : completedLevels;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                const Center(child: PipIsland(width: 170)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'CHAPITRE ${chapter.number} · ${chapter.period}',
                        style: textTheme.labelMedium,
                      ),
                    ),
                    Text(
                      '$completedLevels niveau${completedLevels > 1 ? 'x' : ''} '
                      'sur ${Progress.levelsPerChapter}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(chapter.title, style: textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  chapter.intro,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (chapter.context != null) ...[
                  const SizedBox(height: 16),
                  DashedActionButton(
                    label: "Contexte de l'époque",
                    icon: Icons.history_edu,
                    alignment: Alignment.centerLeft,
                    onPressed: () =>
                        context.push(AppRoutes.chapterContext(chapter.number)),
                  ),
                ],
                const SizedBox(height: 20),
                for (final (index, level) in LevelType.values.indexed) ...[
                  _LevelCard(
                    number: index + 1,
                    level: level,
                    subtitle: _subtitleOf(level),
                    status: progress.levelStatusOf(chapter.number, index),
                    onTap: () => onOpenLevel(index),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
            child: PrimaryButton(
              text: buttonText,
              onPressed: () => onOpenLevel(nextLevelIndex),
            ),
          ),
        ],
      ),
    );
  }

  String _subtitleOf(LevelType level) {
    switch (level) {
      case LevelType.understand:
        return 'Leçon · 4 min · +${level.xp} XP';
      case LevelType.simulate:
        return 'Avec les vrais cours · +${level.xp} XP';
      case LevelType.challenge:
        return '${chapter.challenge} · +${level.xp} XP';
    }
  }
}

class _LevelCard extends StatelessWidget {
  final int number;
  final LevelType level;
  final String subtitle;
  final ProgressStatus status;
  final VoidCallback onTap;

  const _LevelCard({
    required this.number,
    required this.level,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ProgressStatus.completed:
        return SelectableCard(
          leading: const AppBadge.icon(
            Icons.check,
            background: AppColors.mintPale,
            foreground: AppColors.mintText,
          ),
          title: level.title,
          subtitle: subtitle,
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        );
      case ProgressStatus.current:
        return SelectableCard(
          leading: AppBadge.text('$number', background: AppColors.gold),
          title: level.title,
          subtitle: subtitle,
          trailing: const Icon(Icons.chevron_right),
          borderColor: AppColors.gold,
          onTap: onTap,
        );
      case ProgressStatus.locked:
        return SelectableCard(
          leading: const AppBadge.icon(
            Icons.lock,
            foreground: AppColors.dashedBorder,
          ),
          title: level.title,
          subtitle: subtitle,
        );
    }
  }
}
