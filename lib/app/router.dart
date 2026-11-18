import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/profile/profile.dart';
import '../data/profile/profile_repository.dart';
import '../features/check_in/check_in_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_routes.dart';
import 'first_launch.dart';
import 'shell/coming_soon_screen.dart';
import 'shell/orb_tab.dart';
import 'shell/splash_screen.dart';
import 'shell/tab_shell.dart';
import 'theme/theme_preview_screen.dart';

/// The app's router, shared through Riverpod so tests can override it.
///
/// It opens on the splash and re-runs [firstLaunchRedirect] whenever the
/// profile changes, e.g. when it finishes loading or onboarding is done.
final routerProvider = Provider<GoRouter>((ref) {
  final profile = ValueNotifier<AsyncValue<Profile>>(const AsyncLoading());
  ref.listen(
    profileProvider,
    (_, next) => profile.value = next,
    fireImmediately: true,
  );
  final router = createRouter(
    initialLocation: splashPath,
    refreshListenable: profile,
    redirect: (_, state) => firstLaunchRedirect(profile.value, state.uri.path),
  );
  ref.onDispose(() {
    router.dispose();
    profile.dispose();
  });
  return router;
});

/// Builds the route tree.
///
/// - The four tabs live inside a [StatefulShellRoute]. Each tab is a branch
///   with its own navigator, so it keeps its own stack when you switch tabs.
/// - Onboarding and check-in sit outside the shell, on the root navigator,
///   so the bottom bar is hidden there.
///
/// [redirect] is the first-launch check; tests that only need the route
/// tree leave it out.
GoRouter createRouter({
  String initialLocation = '/home',
  GoRouterRedirect? redirect,
  Listenable? refreshListenable,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: redirect,
    refreshListenable: refreshListenable,
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
      // Outside the shell: no bottom bar.
      GoRoute(path: splashPath, builder: (_, _) => const SplashScreen()),
      OnboardingRoutes.route(),
      GoRoute(path: '/check-in', builder: (_, _) => const CheckInScreen()),
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
