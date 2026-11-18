# onboarding

N1 Meet your companion, N2 Name your companion, N3 Companion trait, N4 Your name, and N15 Day one done.

- `onboarding_routes.dart`: the paths (`OnboardingRoutes.meet`, `.name`, `.trait`, `.you`) and the `/onboarding` route tree. Push each next step with `context.push(...)`, so back (the arrow or Android's button) returns one step. Back on N1 closes the app.
- `onboarding_scaffold.dart`: `OnboardingScaffold`, the shared layout. It has a top bar (back arrow plus a progress bar showing step x of 4), the content area, one primary button and an optional footnote. N1 hides the top bar.
- `onboarding_draft.dart`: `onboardingDraftProvider` holds the answers (pig name, trait, user name) in memory, so they survive going back and forward. Read it to prefill a step, and write to it as the user answers.
- `meet_screen.dart`: N1.
- `name_screen.dart` and `pig_names.dart`: N2, the suggested names (in `copy.dart`) and the 1–20 character rule.
- `trait_screen.dart`: N3, three trait cards that act as radio buttons.
- `you_screen.dart`: N4. Next saves the answers to the device and opens the first check-in.

The first check-in (`OnboardingRoutes.firstCheckIn`, N12) is a placeholder until PMG6-62. In debug builds it has a "Finish (debug)" button that completes onboarding. In debug builds, the last one has a "Finish (debug)" button that completes onboarding.

Saving the profile (PMG6-57):
- N4: done. It calls `ref.read(profileProvider.notifier).saveAnswers(...)` with the draft's answers.
- N15: call `completeOnboarding()`, then `context.go('/home')`. Never mark onboarding done earlier, so a user who quits halfway starts again from N1.
