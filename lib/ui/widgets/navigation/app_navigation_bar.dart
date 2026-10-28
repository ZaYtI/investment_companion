import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum AppTab {
  map('Carte', Icons.map_outlined),
  explore('Explorer', Icons.search),
  simulations('Simulations', Icons.show_chart),
  trophies('Trophées', Icons.emoji_events_outlined);

  const AppTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

class AppNavigationBar extends StatelessWidget {
  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;

  const AppNavigationBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: selectedTab.index,
        onDestinationSelected: (index) => onTabSelected(AppTab.values[index]),
        destinations: [
          for (final tab in AppTab.values)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}
