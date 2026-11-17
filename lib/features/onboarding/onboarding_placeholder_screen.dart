import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell/coming_soon_screen.dart';
import '../../data/profile/profile_repository.dart';

/// Stands in for N1 Meet your companion until PMG6-53 lands.
///
/// Debug builds get a "Skip onboarding" button, so the team can reach Home
/// before the onboarding screens exist.
class OnboardingPlaceholderScreen extends ConsumerWidget {
  const OnboardingPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ComingSoonScreen(
      title: 'Welcome',
      message: 'Onboarding is being built.',
      action: kDebugMode
          ? TextButton(
              onPressed: () async {
                await ref.read(profileProvider.notifier).completeOnboarding();
                if (context.mounted) context.go('/home');
              },
              child: const Text('Skip onboarding (debug)'),
            )
          : null,
    );
  }
}
