import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

import '../../providers/progress_provider.dart';
import '../../providers/saved_simulations_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/badges.dart';
import '../../services/day_keys.dart';
import '../widgets/dialogs/badge_celebration_dialog.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import '../widgets/navigation/app_navigation_bar.dart';
import '../widgets/states/offline_banner.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const bannerSpacing = 8.0;

  Set<String>? _earnedBadgeIds;

  void _onTabSelected(int index) {
    widget.navigationShell.goBranch(index);
  }

  Future<void> _onBadgesChanged(List<BadgeStatus> badges) async {
    final isReady =
        ref.read(progressProvider).hasValue &&
        ref.read(savedSimulationsProvider).hasValue;
    if (!isReady) return;
    final previousIds = _earnedBadgeIds;
    _earnedBadgeIds = {
      for (final badge in badges)
        if (badge.isEarned) badge.id,
    };
    if (previousIds == null) return;
    final newBadges = badges
        .where((badge) => badge.isEarned && !previousIds.contains(badge.id))
        .toList();
    if (newBadges.isEmpty) return;
    await showBadgeCelebration(
      context,
      newBadges.first,
      isAnimationEnabled:
          ref.read(appSettingsProvider).value?.isBadgeAnimationEnabled ?? true,
    );
    final isFirstLevelDone = newBadges.any((badge) => badge.id == 'firstStep');
    if (isFirstLevelDone && mounted) await _askForReminder();
  }

  Future<void> _askForReminder() async {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null || settings.hasAskedReminder) return;
    final wantsReminder = await showConfirmDialog(
      context,
      title: 'Un rappel par jour ?',
      message:
          'Recevez chaque jour à 12 h une notification pour le défi du jour : '
          'une vraie journée de bourse à rejouer en 15 secondes. Vous pourrez '
          'la désactiver dans Trophées.',
      confirmLabel: 'Activer',
    );
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    if (wantsReminder) {
      await settingsNotifier.enableReminder();
    } else {
      await settingsNotifier.disableReminder();
    }
  }

  void _syncReminder() {
    final settings = ref.read(appSettingsProvider).value;
    if (settings == null) return;
    final reminder = ref.read(dailyReminderProvider);
    if (settings.isReminderEnabled) {
      final progress = ref.read(currentProgressProvider);
      reminder.scheduleNextDays(
        hasPlayedToday: progress.hasPlayedDailyOn(todayKey()),
      );
    } else {
      reminder.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(badgesProvider, (_, badges) => _onBadgesChanged(badges));
    ref.listen(appSettingsProvider, (_, _) => _syncReminder());
    ref.listen(currentProgressProvider, (_, _) => _syncReminder());
    return Scaffold(
      extendBody: true,
      body: Builder(
        builder: (bodyContext) => Stack(
          children: [
            widget.navigationShell,
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.paddingOf(bodyContext).bottom + bannerSpacing,
              child: const OfflineBanner(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NativeGlassNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTabSelected,
        tabs: const [
          NativeGlassNavBarItem(label: 'Carte', symbol: 'map'),
          NativeGlassNavBarItem(label: 'Explorer', symbol: 'magnifyingglass'),
          NativeGlassNavBarItem(
            label: 'Simulations',
            symbol: 'chart.line.uptrend.xyaxis',
          ),
          NativeGlassNavBarItem(label: 'Trophées', symbol: 'trophy'),
        ],
        fallback: AppNavigationBar(
          selectedTab: AppTab.values[widget.navigationShell.currentIndex],
          onTabSelected: (tab) => _onTabSelected(tab.index),
        ),
      ),
    );
  }
}
