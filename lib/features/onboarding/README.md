# onboarding

N1 Meet your companion, N2 Name your companion, N3 Companion trait, N4 Your name, and N15 Day one done. Shared `OnboardingScaffold` lives here too.

Routes live under `/onboarding/` in `lib/app/router.dart` (N1 is `/onboarding/meet`). `onboarding_placeholder_screen.dart` stands in for N1 until PMG6-53. In debug builds it has a "Skip onboarding" button.

Saving the profile (PMG6-57):
- N4: call `ref.read(profileProvider.notifier).saveAnswers(...)`.
- N15: call `completeOnboarding()`, then `context.go('/home')`. Never mark onboarding done earlier, so a user who quits halfway starts again from N1.
