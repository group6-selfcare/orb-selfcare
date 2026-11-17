import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import 'shell/coming_soon_screen.dart';
import 'shell/orb_tab.dart';
import 'shell/tab_shell.dart';
import 'theme/theme_preview_screen.dart';

/// The app's router, shared through Riverpod so tests can override it.
final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter();
  ref.onDispose(router.dispose);
  return router;
});

/// Builds the route tree.
///
/// - The four tabs live inside a [StatefulShellRoute]. Each tab is a branch
///   with its own navigator, so it keeps its own stack when you switch tabs.
/// - Onboarding and check-in sit outside the shell, on the root navigator,
///   so the bottom bar is hidden there.
///
/// First-launch routing to onboarding comes with PMG6-57.
GoRouter createRouter({String initialLocation = '/home'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            TabShell(navigationShell: navigationShell),
        branches: [
          _branch(OrbTab.home, (_, _) => const HomeScreen()),
          _branch(
            OrbTab.space,
            (_, _) => const ComingSoonScreen(
              title: 'Space',
              message: 'A calm corner to breathe and reflect is on its way.',
            ),
          ),
          _branch(
            OrbTab.quest,
            (_, _) => const ComingSoonScreen(
              title: 'Quest',
              message: 'Small daily quests with Orb are on their way.',
            ),
          ),
          _branch(
            OrbTab.profile,
            (_, _) => const ComingSoonScreen(
              title: 'Profile',
              message: 'Your companion and settings will live here soon.',
            ),
          ),
        ],
      ),
      // Outside the shell: no bottom bar. Feature tickets replace the
      // placeholders and add the onboarding steps as child routes.
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const ComingSoonScreen(
          title: 'Welcome',
          message: 'Onboarding is being built.',
        ),
      ),
      GoRoute(
        path: '/check-in',
        builder: (_, _) => const ComingSoonScreen(
          title: 'Check in',
          message: 'The daily check-in is being built.',
        ),
      ),
      GoRoute(
        path: '/theme-preview',
        builder: (_, _) => const ThemePreviewScreen(),
      ),
    ],
  );
}

StatefulShellBranch _branch(OrbTab tab, GoRouterWidgetBuilder builder) {
  return StatefulShellBranch(
    routes: [GoRoute(path: tab.path, builder: builder)],
  );
}
