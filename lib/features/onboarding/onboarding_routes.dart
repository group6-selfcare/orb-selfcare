import 'package:go_router/go_router.dart';

import '../check_in/check_in_screen.dart';
import 'day_one_screen.dart';
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

  /// N12 and N13, the first check-in inside onboarding (PMG6-62).
  static const firstCheckIn = '$root/first-check-in';

  /// N15 Day one done.
  static const dayOne = '$root/done';

  /// The `/onboarding` route and its steps, for `lib/app/router.dart`.
  static GoRoute route() => GoRoute(
    path: root,
    redirect: (_, state) => state.uri.path == root ? meet : null,
    routes: [
      GoRoute(path: 'meet', builder: (_, _) => const MeetScreen()),
      GoRoute(path: 'name', builder: (_, _) => const NameScreen()),
      GoRoute(path: 'trait', builder: (_, _) => const TraitScreen()),
      GoRoute(path: 'you', builder: (_, _) => const YouScreen()),
      GoRoute(
        path: 'first-check-in',
        builder: (_, _) => const CheckInScreen(onboarding: true),
      ),
      GoRoute(path: 'done', builder: (_, _) => const DayOneScreen()),
    ],
  );
}
