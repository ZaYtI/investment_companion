import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/progress_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/badges.dart';
import '../../../services/day_keys.dart';
import '../../../services/progression.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/decor/cube_icon.dart';
import '../../widgets/progress/progress_ring.dart';

class TrophiesScreen extends ConsumerWidget {
  const TrophiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final progress = ref.watch(currentProgressProvider);
    final badges = ref.watch(badgesProvider);
    final settings = ref.watch(appSettingsProvider).value;
    final earnedCount = badges.where((badge) => badge.isEarned).length;
    final streak = progress.currentStreak(
      today: todayKey(),
      yesterday: yesterdayKey(),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trophées'),
        actions: [
          if (streak > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text("$streak jour${streak > 1 ? 's' : ''} d'affilée"),
                backgroundColor: AppColors.gold.withValues(alpha: 0.25),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          22,
          22,
          22,
          22 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _LevelSummary(xp: progress.xp),
          const SizedBox(height: 24),
          Text(
            'Badges · $earnedCount sur ${badges.length}',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.72,
            children: [for (final badge in badges) _BadgeCard(badge: badge)],
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.mint,
            title: const Text('Animation des nouveaux badges'),
            value: settings?.isBadgeAnimationEnabled ?? true,
            onChanged: (isEnabled) => ref
                .read(appSettingsProvider.notifier)
                .setBadgeAnimationEnabled(isEnabled),
          ),
        ],
      ),
    );
  }
}

class _LevelSummary extends StatelessWidget {
  final int xp;

  const _LevelSummary({required this.xp});

  static const fillDuration = Duration(milliseconds: 900);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final level = levelForXp(xp);
    final nextLevel = nextLevelAfter(level);
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(end: progressInLevel(xp)),
          duration: fillDuration,
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => ProgressRing(
            value: value,
            color: AppColors.goldChart,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${level.number}', style: textTheme.headlineMedium),
                Text('niveau', style: textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level.title, style: textTheme.headlineSmall),
              Text(
                nextLevel == null ? '$xp XP' : '$xp / ${nextLevel.minXp} XP',
                style: textTheme.titleMedium,
              ),
              Text(
                nextLevel == null
                    ? 'Niveau maximum atteint'
                    : 'Encore ${xpToNextLevel(xp)} XP pour le niveau '
                          '${nextLevel.number}',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeStatus badge;

  const _BadgeCard({required this.badge});

  Color get _cubeColor {
    if (badge.isEarned) return AppColors.gold;
    if (badge.isStarted) return AppColors.assetEtf;
    return AppColors.dashedBorder;
  }

  IconData get _overlayIcon {
    if (badge.isEarned) return Icons.check_rounded;
    if (badge.isStarted) return Icons.circle;
    return Icons.lock_rounded;
  }

  String get _status {
    if (badge.isEarned) return 'Obtenu';
    if (badge.target > 1 && badge.isStarted) {
      return '${badge.current} / ${badge.target}';
    }
    return 'Verrouillé';
  }

  void _showCondition(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(badge.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                badge.condition,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Progression : ${badge.current} / ${badge.target}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(8),
      onTap: () => _showCondition(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CubeIcon(color: _cubeColor, size: 56),
              Icon(_overlayIcon, color: AppColors.textPrimary, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            _status,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
