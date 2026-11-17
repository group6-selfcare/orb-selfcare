# features

One folder per feature. Each feature keeps its own screens, widgets and state (Riverpod providers) inside its folder.

- `onboarding/`: N1 to N4 and N15 (PMG6-53 to 57, 62)
- `check_in/`: the daily check-in (PMG6-58 to 62)
- `home/`: Home before and after check-in (PMG6-63, 64)

Screens never talk to the database directly. They go through a repository in `lib/data/`.
