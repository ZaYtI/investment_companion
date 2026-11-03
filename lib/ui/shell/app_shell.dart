import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

import '../../providers/progress_provider.dart';
import '../../providers/saved_simulations_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/badges.dart';
import '../widgets/dialogs/badge_celebration_dialog.dart';
import '../widgets/navigation/app_navigation_bar.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  Set<String>? _earnedBadgeIds;

  void _onTabSelected(int index) {
    widget.navigationShell.goBranch(index);
  }

  void _onBadgesChanged(List<BadgeStatus> badges) {
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
    final newBadges = badges.where(
      (badge) => badge.isEarned && !previousIds.contains(badge.id),
    );
    if (newBadges.isEmpty) return;
    showBadgeCelebration(
      context,
      newBadges.first,
      isAnimationEnabled:
          ref.read(appSettingsProvider).value?.isBadgeAnimationEnabled ?? true,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(badgesProvider, (_, badges) => _onBadgesChanged(badges));
    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
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
