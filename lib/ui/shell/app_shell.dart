import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/navigation/app_navigation_bar.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppNavigationBar(
        selectedTab: AppTab.values[navigationShell.currentIndex],
        onTabSelected: (tab) => navigationShell.goBranch(tab.index),
      ),
    );
  }
}
