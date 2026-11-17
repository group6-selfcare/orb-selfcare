# app

App-wide setup:

- `orb_app.dart`: the root widget (`MaterialApp.router`).
- `router.dart`: the go_router config. The four tabs are branches of a `StatefulShellRoute`, so each keeps its own stack. `/onboarding` and `/check-in` sit outside the shell, so the tab bar is hidden there.
- `shell/`: the tab bar scaffold (`tab_shell.dart`), the tab list (`orb_tab.dart`) and the "coming soon" placeholder.
- `theme/`: the tokens and `ThemeData`. `/theme-preview` shows every component (debug builds link to it from Home).

To add a page inside a tab, add a child `GoRoute` under that tab's branch. To add a full-screen flow without the tab bar, add a top-level `GoRoute`.

Tickets: PMG6-46 (theme), PMG6-47 (tab shell), PMG6-57 (first-launch routing).
