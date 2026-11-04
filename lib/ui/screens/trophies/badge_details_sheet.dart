import 'package:flutter/material.dart';

import '../../../services/badges.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/decor/cube_icon.dart';
import 'badge_style.dart';

class BadgeDetailsSheet extends StatelessWidget {
  final BadgeStatus badge;

  const BadgeDetailsSheet({super.key, required this.badge});

  static const barHeight = 8.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CubeIcon(color: badgeColorOf(badge), size: 56),
                    Icon(
                      badgeIconOf(badge),
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(badge.title, style: textTheme.titleLarge),
                      const SizedBox(height: 4),
                      _StateChip(badge: badge),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(badge.meaning, style: textTheme.bodyLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Progression', style: textTheme.titleMedium),
                ),
                Text(
                  '${badge.current} sur ${badge.target}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ProgressBar(value: badge.progress, isDone: badge.isEarned),
            if (badge.steps.length > 1 || badge.steps.first.target > 1) ...[
              const SizedBox(height: 20),
              Text('Étapes', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final step in badge.steps) _StepRow(step: step),
            ],
            if (!badge.isEarned) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.goldText,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Comment l'obtenir",
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(badge.hint, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final BadgeStatus badge;

  const _StateChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    final background = badge.isEarned
        ? AppColors.gold.withValues(alpha: 0.3)
        : badge.isStarted
        ? AppColors.mintPale
        : AppColors.border;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badgeStateOf(badge),
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.textPrimary, letterSpacing: 0),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final BadgeStep step;

  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                step.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: step.isDone
                    ? AppColors.mintText
                    : AppColors.dashedBorder,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(step.label, style: textTheme.bodyMedium)),
              Text(
                '${step.current} / ${step.target}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _ProgressBar(value: step.current / step.target, isDone: step.isDone),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final bool isDone;

  const _ProgressBar({required this.value, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value.clamp(0, 1),
      minHeight: BadgeDetailsSheet.barHeight,
      color: isDone ? AppColors.goldChart : AppColors.mint,
      backgroundColor: AppColors.border,
      borderRadius: BorderRadius.circular(BadgeDetailsSheet.barHeight),
    );
  }
}
