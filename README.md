# Orb – SelfCare App

Orb is a self-care companion for university students. You check in how you feel each day, and Pig D, your companion, reflects it back.

This is Group 6's project. Sprint planning and tickets live in Jira (project **PMG6**). Sprint decisions are on the Confluence page "SelfCare App – Sprint 2 plan and decisions".

## Requirements

- **Flutter 3.47.7 (stable)**. Everyone uses this exact version. Check with `flutter --version`.
- Android Studio, or VS Code with the Flutter extension
- An Android emulator or an Android phone. The app is **Android only** for now.

## Run the app

```bash
flutter pub get
flutter run
```

## Checks (CI runs these on every pull request)

```bash
flutter analyze
flutter test
```

## How we work

1. Pick a ticket from the PMG6 board.
2. Create a branch named after the ticket key, for example:
   ```bash
   git checkout -b PMG6-58-mood-step
   ```
   The Jira key in the branch name links the work to the ticket and moves it to **In Progress**.
3. Start every commit message with the key, for example `PMG6-58 Add mood faces`.
4. Open a pull request into `main` (this moves the ticket to **In Review**). Another dev reviews it, and CI must be green.
5. After merging, the designer checks the design and QA checks the build on a real phone. Only then does the ticket move to **Done**.

Never push directly to `main`.

## Project structure

Planned layout; the folders are created in PMG6-45.

```
lib/
  app/        router, theme, tab shell
  features/
    onboarding/
    check_in/
    home/
  data/       drift database, repositories
  shared/     shared widgets, copy.dart
assets/svg/   Pig D poses, mood faces, tab icons
```

## Tech

Riverpod · go_router · drift (SQLite) · shared_preferences · flutter_svg. All data stays on the device.
