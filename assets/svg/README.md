# assets/svg

Art from the Figma file, exported as SVG (PMG6-51). Use lowercase snake_case names.

- `pig/pig_<pose>.svg`: Pig D poses
- `pig/trait_<gentle|cheerful|playful>.svg`: the pig's face for each companion trait (N3). Drawn in code from the Companion head; the Figma copy is on the "Trait Faces" page.
- `mood/level_<rough|low|okay|good|great>.svg` and `mood/emotion_<name>.svg`
- `tabs/tab_<home|space|quest|profile>_<active|inactive>.svg`
- `icons/<name>.svg`: custom UI icons, drawn in the pig's style (flat pastel shapes, ink #2B2326 details). The Figma copies are on the "Custom icons" page.

Every file must render in flutter_svg: no filters or masks, and text converted to outlines.

## Level to pose (PMG6-51)

`PigPose.forLevel` in `lib/shared/pig_pose.dart`. The pig never looks disappointed or judging on Rough or Low.

| Today | Pose | File |
|---|---|---|
| No check-in yet | Curious | `pig_curious.svg` |
| Rough (1) | Comforting: arms open, small heart | `pig_comforting.svg` |
| Low (2) | Listening: head tilted, close | `pig_listening.svg` |
| Okay (3) | Calm: eyes closed, settled | `pig_calm.svg` |
| Good (4) | Joyful: arms up, sparkle | `pig_cheer.svg` |
| Great (5) | Cheering: confetti | `pig_cheering.svg` |

Level faces on the check-in reuse the emotion faces until dedicated `level_*.svg` files exist: Rough uses Stressed, Low Sad, Okay Okay, Good Happy, Great Excited.

