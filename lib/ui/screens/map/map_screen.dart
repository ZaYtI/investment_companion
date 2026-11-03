import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../data/chapters_data.dart';
import '../../../data/fake_progress.dart';
import '../../../models/chapter_status.dart';
import '../../../models/chapter_summary.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/states/error_view.dart';
import 'chapter_tile.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<ChapterSummary>> _chapters = loadChapterSummaries();

  void _openChapter(ChapterSummary chapter) {
    if (FakeProgress.statusOf(chapter.number) == ChapterStatus.locked) {
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
          child: SafeArea(
            bottom: false,
            child: FutureBuilder(
              future: _chapters,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: ErrorView(
                      message: 'Impossible de charger les chapitres.',
                      onRetry: () =>
                          setState(() => _chapters = loadChapterSummaries()),
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
                    for (final chapter in chapters) ...[
                      ChapterTile(
                        chapter: chapter,
                        status: FakeProgress.statusOf(chapter.number),
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
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
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
            const _Pill(
              text: '${FakeProgress.streakDays} j',
              color: AppColors.gold,
            ),
            const SizedBox(width: 8),
            const _Pill(text: '${FakeProgress.xp} XP', color: AppColors.mint),
            IconButton(
              onPressed: () => context.push(AppRoutes.gallery),
              icon: const Icon(Icons.palette_outlined),
              color: AppColors.border,
              tooltip: 'Galerie',
            ),
          ],
        ),
        Text(
          'Un thème, une date réelle · vous êtes au chapitre '
          '${FakeProgress.currentChapter} sur 7',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.border),
        ),
      ],
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
