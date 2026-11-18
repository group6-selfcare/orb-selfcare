# onboarding

N1 Meet your companion, N2 Name your companion, N3 Companion trait, N4 Your name, the first check-in (N12, N13) and N15 Day one done.

- `onboarding_routes.dart`: the paths (`OnboardingRoutes.meet`, `.name`, `.trait`, `.you`) and the `/onboarding` route tree. Push each next step with `context.push(...)`, so back (the arrow or Android's button) returns one step. Back on N1 closes the app.
- `onboarding_scaffold.dart`: `OnboardingScaffold`, the shared layout. It has a top bar (back arrow plus a progress bar showing step x of 4), the content area, one primary button and an optional footnote. N1 hides the top bar.
- `onboarding_draft.dart`: `onboardingDraftProvider` holds the answers (pig name, trait, user name) in memory, so they survive going back and forward. Read it to prefill a step, and write to it as the user answers.
- `meet_screen.dart`: N1.
- `name_screen.dart` and `pig_names.dart`: N2, the suggested names (in `copy.dart`) and the 1–20 character rule.
- `trait_screen.dart`: N3, three trait cards that act as radio buttons.
- `you_screen.dart`: N4. Next saves the answers to the device and opens the first check-in.

- `OnboardingRoutes.firstCheckIn` (N12, N13): the check-in screen in onboarding mode, `CheckInScreen(onboarding: true)`. Its title is "Your first check-in", it asks "How are you feeling right now?", and Continue (or Skip, once a face is picked) opens N15. The check-in it saves is a real one for today.
- `day_one_screen.dart`: N15 Day one done (`OnboardingRoutes.dayOne`). A cheering pig, "Day one, done!" and the trait's line from `OnboardingCopy.dayOneLine` (gentle for every trait after a Rough or Low check-in). "Go to Home" marks onboarding done and replaces the stack with `/home`.

Saving the profile (PMG6-57):
- N4: done. It calls `ref.read(profileProvider.notifier).saveAnswers(...)` with the draft's answers.
- N15: call `completeOnboarding()`, then `context.go('/home')`. Never mark onboarding done earlier, so a user who quits halfway starts again from N1.
