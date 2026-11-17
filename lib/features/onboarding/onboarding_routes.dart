import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../data/profile/profile_repository.dart';
import '../../shared/copy.dart';
import 'meet_screen.dart';
import 'onboarding_scaffold.dart';

/// The onboarding paths. Each step is pushed on top of the last, so back
/// (the arrow or Android's button) returns one step.
abstract final class OnboardingRoutes {
  static const root = '/onboarding';
  static const meet = '$root/meet';
  static const name = '$root/name';
  static const trait = '$root/trait';
  static const you = '$root/you';

  /// The `/onboarding` route and its steps, for `lib/app/router.dart`.
  static GoRoute route() => GoRoute(
    path: root,
    redirect: (_, state) => state.uri.path == root ? meet : null,
    routes: [
      GoRoute(path: 'meet', builder: (_, _) => const MeetScreen()),
      // Placeholders until PMG6-54 (N2), PMG6-55 (N3) and PMG6-56 (N4).
      GoRoute(
        path: 'name',
        builder: (_, _) => const _StepPlaceholder(
          step: 2,
          title: 'Name your companion',
          next: trait,
        ),
      ),
      GoRoute(
        path: 'trait',
        builder: (_, _) => const _StepPlaceholder(
          step: 3,
          title: 'Companion trait',
          next: you,
        ),
      ),
      GoRoute(
        path: 'you',
        builder: (_, _) =>
            const _StepPlaceholder(step: 4, title: 'Your name', next: null),
      ),
    ],
  );
}

/// A stand-in step so the flow can be walked end to end. The last one
/// finishes onboarding in debug builds only, until N4 and N15 exist.
class _StepPlaceholder extends ConsumerWidget {
  const _StepPlaceholder({
    required this.step,
    required this.title,
    required this.next,
  });

  final int step;
  final String title;
  final String? next;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final next = this.next;

    VoidCallback? onPressed;
    if (next != null) {
      onPressed = () => context.push(next);
    } else if (kDebugMode) {
      onPressed = () async {
        await ref.read(profileProvider.notifier).completeOnboarding();
        if (context.mounted) context.go('/home');
      };
    }

    return OnboardingScaffold(
      step: step,
      buttonLabel: next != null ? OnboardingCopy.next : 'Finish (debug)',
      onPressed: onPressed,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: text.headlineSmall),
            const SizedBox(height: OrbSpacing.sm),
            Text(
              'Coming soon',
              style: text.bodyLarge?.copyWith(color: OrbColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
