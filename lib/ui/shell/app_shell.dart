import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

import '../widgets/navigation/app_navigation_bar.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onTabSelected(int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: NativeGlassNavBar(
        currentIndex: navigationShell.currentIndex,
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
          selectedTab: AppTab.values[navigationShell.currentIndex],
          onTabSelected: (tab) => _onTabSelected(tab.index),
        ),
      ),
    );
  }
}
