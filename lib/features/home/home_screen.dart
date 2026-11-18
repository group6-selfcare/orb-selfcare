import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../data/profile/profile_repository.dart';
import '../onboarding/onboarding_draft.dart';
import '../onboarding/onboarding_routes.dart';

/// The Home tab.
///
/// A placeholder until Home before and after check-in (PMG6-63, 64) lands.
/// It already links to the check-in route so the shell can be tried out.
/// Debug builds also get tools for testing: the theme preview, and a reset
/// that starts onboarding again as if the app was just installed.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _resetOnboarding(BuildContext context, WidgetRef ref) async {
    await ref.read(profileProvider.notifier).reset();
    ref.invalidate(onboardingDraftProvider);
    if (context.mounted) context.go(OnboardingRoutes.meet);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Orb')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OrbSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Hi there', style: text.headlineMedium),
              const SizedBox(height: OrbSpacing.sm),
              Text(
                'How are you feeling today?',
                style: text.bodyLarge?.copyWith(color: OrbColors.textSecondary),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/check-in'),
                child: const Text('Check in'),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: OrbSpacing.sm),
                TextButton(
                  onPressed: () => context.push('/theme-preview'),
                  child: const Text('Theme preview'),
                ),
                TextButton(
                  onPressed: () => _resetOnboarding(context, ref),
                  child: const Text('Reset onboarding (debug)'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
