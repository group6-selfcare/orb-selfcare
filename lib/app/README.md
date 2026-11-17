# app

App-wide setup:

- `orb_app.dart`: the root widget (`MaterialApp.router`).
- `router.dart`: the go_router config. The four tabs are branches of a `StatefulShellRoute`, so each keeps its own stack. `/onboarding` and `/check-in` sit outside the shell, so the tab bar is hidden there.
- `first_launch.dart`: the redirect that decides where a cold start lands. The app opens on a blank splash until the profile loads, then goes to onboarding N1 (`/onboarding/meet`) until `onboardingDone` is true, and to Home after that. The tabs are blocked until then; onboarding and `/check-in` are not.
- `shell/`: the splash, the tab bar scaffold (`tab_shell.dart`), the tab list (`orb_tab.dart`) and the "coming soon" placeholder.
- `theme/`: the tokens and `ThemeData`. `/theme-preview` shows every component (debug builds link to it from Home).

To add a page inside a tab, add a child `GoRoute` under that tab's branch. To add a full-screen flow without the tab bar, add a top-level `GoRoute`.

Tickets: PMG6-46 (theme), PMG6-47 (tab shell), PMG6-57 (first-launch routing).
