import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/chapter_summary.dart';
import '../../../models/progress.dart';
import '../../../models/progress_status.dart';
import '../../../providers/progress_provider.dart';
import '../../theme/app_colors.dart';
import 'chapter_path.dart';
import 'island_painter.dart';

class ChapterTile extends StatelessWidget {
  final ChapterSummary chapter;
  final ProgressStatus status;
  final bool islandOnLeft;
  final bool hasNextChapter;
  final VoidCallback onTap;

  const ChapterTile({
    super.key,
    required this.chapter,
    required this.status,
    required this.islandOnLeft,
    required this.hasNextChapter,
    required this.onTap,
  });

  static const height = 120.0;
  static const spacing = 28.0;
  static const islandCenterX = 65.0;
  static const islandCenterY = 82.0;

  Color get _pathColor => switch (status) {
    ProgressStatus.completed => AppColors.mint,
    ProgressStatus.current => AppColors.gold,
    ProgressStatus.locked => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final island = _Island(chapterNumber: chapter.number, status: status);
    final texts = Expanded(
      child: _ChapterTexts(
        chapter: chapter,
        status: status,
        alignRight: !islandOnLeft,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        const leftX = islandCenterX;
        final rightX = constraints.maxWidth - islandCenterX;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (hasNextChapter)
              CustomPaint(
                painter: ChapterPathPainter(
                  color: _pathColor,
                  start: Offset(islandOnLeft ? leftX : rightX, islandCenterY),
                  end: Offset(
                    islandOnLeft ? rightX : leftX,
                    islandCenterY + height + spacing,
                  ),
                ),
              ),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: islandOnLeft
                    ? [island, const SizedBox(width: 12), texts]
                    : [texts, const SizedBox(width: 12), island],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Island extends StatelessWidget {
  final int chapterNumber;
  final ProgressStatus status;

  const _Island({required this.chapterNumber, required this.status});

  static const width = 130.0;
  static const height = ChapterTile.height;
  static const lockedShade = 0.7;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              status == ProgressStatus.locked
                  ? AppColors.mapNightLight.withValues(alpha: lockedShade)
                  : Colors.transparent,
              BlendMode.srcATop,
            ),
            child: CustomPaint(
              size: const Size(width, height),
              painter: IslandPainter(chapterNumber: chapterNumber),
            ),
          ),
          if (status == ProgressStatus.locked)
            const Positioned(
              bottom: 32,
              child: Icon(Icons.lock, color: AppColors.surface),
            ),
          if (status == ProgressStatus.completed)
            const Positioned(
              top: 20,
              right: 8,
              child: Icon(Icons.check_circle, color: AppColors.mint),
            ),
        ],
      ),
    );
  }
}

class _ChapterTexts extends StatelessWidget {
  final ChapterSummary chapter;
  final ProgressStatus status;
  final bool alignRight;

  const _ChapterTexts({
    required this.chapter,
    required this.status,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLocked = status == ProgressStatus.locked;
    final labelColor = switch (status) {
      ProgressStatus.current => AppColors.gold,
      ProgressStatus.completed => AppColors.mint,
      ProgressStatus.locked => AppColors.dashedBorder,
    };
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          'CHAPITRE ${chapter.number} · ${chapter.period}',
          style: textTheme.labelMedium?.copyWith(color: labelColor),
        ),
        Text(
          chapter.title,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: textTheme.titleMedium?.copyWith(
            color: isLocked ? AppColors.dashedBorder : AppColors.surface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        _StatusLine(chapterNumber: chapter.number, status: status),
      ],
    );
  }
}

class _StatusLine extends ConsumerWidget {
  final int chapterNumber;
  final ProgressStatus status;

  const _StatusLine({required this.chapterNumber, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(currentProgressProvider);
    final textTheme = Theme.of(context).textTheme;
    switch (status) {
      case ProgressStatus.locked:
        return Text(
          'Verrouillé',
          style: textTheme.bodySmall?.copyWith(color: AppColors.dashedBorder),
        );
      case ProgressStatus.current:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Continuer · ${progress.completedLevelsIn(chapterNumber)}'
            '/${Progress.levelsPerChapter}',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
        );
      case ProgressStatus.completed:
        final stars = progress.starsByChapter[chapterNumber] ?? 0;
        return Text(
          '${'★' * stars}${'☆' * (3 - stars)}  3/3',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.gold),
        );
    }
  }
}
