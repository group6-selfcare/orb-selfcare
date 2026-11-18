import '../../app/theme/tokens.dart';

/// The 5-point scale behind the one-tap check-in. [value] is what's
/// stored in the database (1 to 5).
///
/// Each level has its own face, `assets/svg/mood/level_<name>.svg` (see
/// [levelFaceAsset]). [face] is the mood it is drawn from, used for its
/// colour.
enum MoodLevel {
  rough(1, Mood.stressed),
  low(2, Mood.sad),
  okay(3, Mood.okay),
  good(4, Mood.happy),
  great(5, Mood.excited);

  const MoodLevel(this.value, this.face);

  /// 1 (Rough) to 5 (Great).
  final int value;

  /// The face drawn on this level's button.
  final Mood face;

  static MoodLevel fromValue(int value) =>
      values.firstWhere((l) => l.value == value);
}

/// The SVG for a level's face on the check-in, e.g.
/// `assets/svg/mood/level_rough.svg`.
String levelFaceAsset(MoodLevel level) =>
    'assets/svg/mood/level_${level.name}.svg';

/// The SVG for a mood face.
String moodFaceAsset(Mood mood) => 'assets/svg/mood/emotion_${mood.name}.svg';

/// The emotions offered under "Want to name it?" for each level.
///
/// From PMG6-59, approved by the PO. Every name is a [Mood], so it has a
/// face in `assets/svg/mood/`.
const emotionsForLevel = <MoodLevel, List<Mood>>{
  MoodLevel.great: [Mood.excited, Mood.happy, Mood.loved, Mood.surprised],
  MoodLevel.good: [Mood.happy, Mood.peaceful, Mood.loved, Mood.okay],
  MoodLevel.okay: [Mood.okay, Mood.peaceful, Mood.tired, Mood.sleepy],
  MoodLevel.low: [Mood.sad, Mood.disappointed, Mood.tired, Mood.numb],
  MoodLevel.rough: [Mood.angry, Mood.anxious, Mood.stressed, Mood.sad],
};

/// The stored emotion name back as a [Mood], or null if unknown.
Mood? moodFromName(String? name) {
  for (final mood in Mood.values) {
    if (mood.name == name) return mood;
  }
  return null;
}
