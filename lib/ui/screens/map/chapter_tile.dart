import 'package:flutter/material.dart';

import '../../../data/fake_progress.dart';
import '../../../models/chapter_status.dart';
import '../../../models/chapter_summary.dart';
import '../../theme/app_colors.dart';
import '../../widgets/mascot/floating_pip.dart';
import 'chapter_path.dart';

class ChapterTile extends StatelessWidget {
  final ChapterSummary chapter;
  final ChapterStatus status;
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
    ChapterStatus.completed => AppColors.mint,
    ChapterStatus.current => AppColors.gold,
    ChapterStatus.locked => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final island = _Island(status: status);
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
  final ChapterStatus status;

  const _Island({required this.status});

  static const width = 130.0;
  static const height = ChapterTile.height;
  static const islandHeight = 75.0;
  static const lockedShade = 0.7;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              status == ChapterStatus.locked
                  ? AppColors.mapNightLight.withValues(alpha: lockedShade)
                  : Colors.transparent,
              BlendMode.srcATop,
            ),
            child: Image.asset(
              'assets/images/welcome_island.png',
              width: width,
              height: islandHeight,
            ),
          ),
          if (status == ChapterStatus.locked)
            const Positioned(
              bottom: 30,
              child: Icon(Icons.lock, color: AppColors.surface),
            ),
          if (status == ChapterStatus.completed)
            const Positioned(
              top: 20,
              right: 8,
              child: Icon(Icons.check_circle, color: AppColors.mint),
            ),
          if (status == ChapterStatus.current)
            const Positioned(top: 0, child: FloatingPip(width: 36)),
        ],
      ),
    );
  }
}

class _ChapterTexts extends StatelessWidget {
  final ChapterSummary chapter;
  final ChapterStatus status;
  final bool alignRight;

  const _ChapterTexts({
    required this.chapter,
    required this.status,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLocked = status == ChapterStatus.locked;
    final labelColor = switch (status) {
      ChapterStatus.current => AppColors.gold,
      ChapterStatus.completed => AppColors.mint,
      ChapterStatus.locked => AppColors.dashedBorder,
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

class _StatusLine extends StatelessWidget {
  final int chapterNumber;
  final ChapterStatus status;

  const _StatusLine({required this.chapterNumber, required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (status) {
      case ChapterStatus.locked:
        return Text(
          'Verrouillé',
          style: textTheme.bodySmall?.copyWith(color: AppColors.dashedBorder),
        );
      case ChapterStatus.current:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Continuer · ${FakeProgress.completedLevelsInCurrentChapter}'
            '/${FakeProgress.levelsPerChapter}',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
        );
      case ChapterStatus.completed:
        final stars = FakeProgress.starsByChapter[chapterNumber] ?? 0;
        return Text(
          '${'★' * stars}${'☆' * (3 - stars)}  3/3',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.gold),
        );
    }
  }
}
