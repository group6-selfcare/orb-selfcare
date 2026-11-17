import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import 'orb_tab.dart';

/// The scaffold around the four tabs: the current tab's page and the
/// bottom bar.
///
/// Android back on Space, Quest or Profile goes to Home instead of closing
/// the app. On Home, back closes the app as usual.
class TabShell extends StatelessWidget {
  const TabShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goTo(int index) {
    // Tapping the tab you are on takes you back to that tab's first page.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onHome = navigationShell.currentIndex == OrbTab.home.index;
    return PopScope(
      canPop: onHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(OrbTab.home.index);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: OrbColors.border)),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goTo,
            destinations: [
              for (final tab in OrbTab.values)
                NavigationDestination(
                  icon: _TabIcon(tab.inactiveIcon),
                  selectedIcon: _TabIcon(tab.activeIcon),
                  label: tab.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset(asset, width: 32, height: 32);
}
