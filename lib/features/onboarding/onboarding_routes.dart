import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell/coming_soon_screen.dart';
import '../../data/profile/profile_repository.dart';
import 'meet_screen.dart';
import 'name_screen.dart';
import 'trait_screen.dart';
import 'you_screen.dart';

/// The onboarding paths. Each step is pushed on top of the last, so back
/// (the arrow or Android's button) returns one step.
abstract final class OnboardingRoutes {
  static const root = '/onboarding';
  static const meet = '$root/meet';
  static const name = '$root/name';
  static const trait = '$root/trait';
  static const you = '$root/you';

  /// N12, the first check-in inside onboarding (PMG6-62).
  static const firstCheckIn = '$root/first-check-in';

  /// The `/onboarding` route and its steps, for `lib/app/router.dart`.
  static GoRoute route() => GoRoute(
    path: root,
    redirect: (_, state) => state.uri.path == root ? meet : null,
    routes: [
      GoRoute(path: 'meet', builder: (_, _) => const MeetScreen()),
      GoRoute(path: 'name', builder: (_, _) => const NameScreen()),
      GoRoute(path: 'trait', builder: (_, _) => const TraitScreen()),
      GoRoute(path: 'you', builder: (_, _) => const YouScreen()),
      // Placeholder until PMG6-62 builds the first check-in (N12, N13).
      GoRoute(
        path: 'first-check-in',
        builder: (_, _) => const _FirstCheckInPlaceholder(),
      ),
    ],
  );
}

/// Stands in for N12 until PMG6-62. Debug builds can finish onboarding
/// here, so the team can still reach Home.
class _FirstCheckInPlaceholder extends ConsumerWidget {
  const _FirstCheckInPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ComingSoonScreen(
      title: 'First check-in',
      message: 'Your first check-in with your companion is being built.',
      action: kDebugMode
          ? FilledButton(
              onPressed: () async {
                await ref.read(profileProvider.notifier).completeOnboarding();
                if (context.mounted) context.go('/home');
              },
              child: const Text('Finish (debug)'),
            )
          : null,
    );
  }
}
