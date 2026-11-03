import 'package:flutter/material.dart';

import '../../../services/progression.dart';
import '../../theme/app_colors.dart';

class XpBar extends StatelessWidget {
  final int xp;
  final Color textColor;

  const XpBar({super.key, required this.xp, this.textColor = AppColors.border});

  static const fillDuration = Duration(milliseconds: 900);
  static const barHeight = 8.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final level = levelForXp(xp);
    final nextLevel = nextLevelAfter(level);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Niveau ${level.number} · ${level.title}',
                style: textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              nextLevel == null ? '$xp XP' : '$xp / ${nextLevel.minXp} XP',
              style: textTheme.labelLarge?.copyWith(color: textColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(end: progressInLevel(xp)),
          duration: fillDuration,
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: barHeight,
            color: AppColors.mint,
            backgroundColor: AppColors.mapNightLight,
            borderRadius: BorderRadius.circular(barHeight),
          ),
        ),
      ],
    );
  }
}
