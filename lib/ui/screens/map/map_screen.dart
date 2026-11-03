import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/chapters_data.dart';
import '../../../models/chapter_summary.dart';
import '../../../models/progress.dart';
import '../../../models/progress_status.dart';
import '../../../providers/progress_provider.dart';
import '../../../services/day_keys.dart';
import '../../../services/progression.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/decor/night_sky.dart';
import '../../widgets/dialogs/confirm_dialog.dart';
import '../../widgets/progress/xp_bar.dart';
import '../../widgets/states/error_view.dart';
import 'chapter_tile.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late Future<List<ChapterSummary>> _chapters = loadChapterSummaries();

  void _openChapter(ChapterSummary chapter) {
    final progress = ref.read(currentProgressProvider);
    if (progress.statusOf(chapter.number) == ProgressStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terminez le chapitre précédent pour débloquer celui-ci.',
          ),
        ),
      );
      return;
    }
    context.push(AppRoutes.chapter(chapter.number));
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(currentProgressProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.mapNight, AppColors.mapNightLight],
            ),
          ),
          child: Stack(
            children: [
              const NightSky(showClouds: false),
              SafeArea(
                bottom: false,
                child: FutureBuilder(
                  future: _chapters,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: ErrorView(
                          message: 'Impossible de charger les chapitres.',
                          onRetry: () => setState(
                            () => _chapters = loadChapterSummaries(),
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final chapters = snapshot.data!.reversed.toList();
                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        22,
                        22,
                        22,
                        22 + MediaQuery.paddingOf(context).bottom,
                      ),
                      children: [
                        const _MapHeader(),
                        const SizedBox(height: 16),
                        const _GamesSection(),
                        const SizedBox(height: 24),
                        for (final chapter in chapters) ...[
                          ChapterTile(
                            chapter: chapter,
                            status: progress.statusOf(chapter.number),
                            islandOnLeft: chapter.number.isOdd,
                            hasNextChapter: chapter.number > 1,
                            onTap: () => _openChapter(chapter),
                          ),
                          if (chapter.number > 1)
                            const SizedBox(height: ChapterTile.spacing),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MapMenuAction { gallery, resetProgress }

class _MapHeader extends ConsumerWidget {
  const _MapHeader();

  Future<void> _onMenuSelected(
    BuildContext context,
    WidgetRef ref,
    _MapMenuAction action,
  ) async {
    switch (action) {
      case _MapMenuAction.gallery:
        await context.push(AppRoutes.gallery);
      case _MapMenuAction.resetProgress:
        final isConfirmed = await showConfirmDialog(
          context,
          title: 'Réinitialiser la progression ?',
          message:
              'Tous les niveaux, les étoiles et l\'XP seront effacés. '
              'Vous repartirez du chapitre 1.',
          confirmLabel: 'Réinitialiser',
        );
        if (isConfirmed) {
          await ref.read(progressProvider.notifier).reset();
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(currentProgressProvider);
    final streak = progress.currentStreak(
      today: todayKey(),
      yesterday: yesterdayKey(),
    );
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Carte du temps',
                style: textTheme.titleLarge?.copyWith(color: AppColors.surface),
              ),
            ),
            if (streak > 0)
              _Pill(text: '$streak j de suite', color: AppColors.gold),
            PopupMenuButton<_MapMenuAction>(
              icon: const Icon(Icons.more_vert, color: AppColors.border),
              tooltip: 'Menu',
              onSelected: (action) => _onMenuSelected(context, ref, action),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _MapMenuAction.gallery,
                  child: Text('Galerie de composants'),
                ),
                PopupMenuItem(
                  value: _MapMenuAction.resetProgress,
                  child: Text('Réinitialiser la progression'),
                ),
              ],
            ),
          ],
        ),
        Text(
          'Un thème, une date réelle · vous êtes au chapitre '
          '${progress.currentChapter} sur ${Progress.chapterCount}',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.border),
        ),
        const SizedBox(height: 12),
        XpBar(xp: progress.xp),
      ],
    );
  }
}

class _GamesSection extends ConsumerWidget {
  const _GamesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(currentProgressProvider);
    final hasPlayedToday = progress.hasPlayedDailyOn(todayKey());
    final isQuizUnlocked = progress.isLevelCompleted(2, 0);
    return Row(
      children: [
        Expanded(
          child: _GameCard(
            icon: hasPlayedToday ? Icons.check_rounded : Icons.bolt_rounded,
            iconColor: hasPlayedToday ? AppColors.mint : AppColors.gold,
            title: 'Défi du jour',
            subtitle: hasPlayedToday
                ? 'Fait aujourd\'hui'
                : '+$dailyChallengeXp XP',
            onTap: () => context.push(AppRoutes.dailyChallenge),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GameCard(
            icon: isQuizUnlocked
                ? Icons.compare_arrows_rounded
                : Icons.lock_rounded,
            iconColor: isQuizUnlocked ? AppColors.mint : AppColors.border,
            title: 'Plus ou moins ?',
            subtitle: isQuizUnlocked
                ? '+$quizAnswerXp XP / réponse'
                : 'Chapitre 2',
            onTap: isQuizUnlocked
                ? () => context.push(AppRoutes.quiz)
                : () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Terminez la leçon du chapitre 2 pour débloquer '
                        'ce quiz.',
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GameCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const radius = BorderRadius.all(Radius.circular(16));
  static const iconBoxSize = 36.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.mapNightLight,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.surface.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: AppColors.mapNight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.border,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mapNightLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
