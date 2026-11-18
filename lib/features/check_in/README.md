# check_in

The `/check-in` screen: mood level, optional emotion, note and tags, and edit-today. It also runs in onboarding mode (N12 and N13).

- `mood_level.dart`: `MoodLevel` (Rough 1 to Great 5) and the face each level shows. `moodFaceAsset(mood)` gives the SVG path. `emotionsForLevel` is the level to emotion mapping for "Want to name it?" (PMG6-59, draft until the PO approves it).
- `check_in_screen.dart`: `CheckInScreen`. One tap on a face saves the check-in through `CheckInRepository.saveToday`. Done, the back arrow and Android back save again on the way out; leaving before a face is picked saves nothing.
- `EmotionPicker`: the optional emotion. One at a time; tapping it again clears it. Picking a level that doesn't offer the current emotion clears it.

Level faces (until the designer exports dedicated `level_*.svg` files): Rough uses Stressed, Low uses Sad, Okay uses Okay, Good uses Happy, Great uses Excited.
