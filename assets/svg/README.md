# assets/svg

Art from the Figma file, exported as SVG (PMG6-51). Use lowercase snake_case names.

- `pig/pig_<pose>.svg`: Pig D poses
- `pig/trait_<gentle|cheerful|playful>.svg`: the pig's face for each companion trait (N3). Drawn in code from the Companion head; the Figma copy is on the "Trait Faces" page.
- `mood/level_<rough|low|okay|good|great>.svg` and `mood/emotion_<name>.svg`
- `tabs/tab_<home|space|quest|profile>_<active|inactive>.svg`

Every file must render in flutter_svg: no filters or masks, and text converted to outlines.
