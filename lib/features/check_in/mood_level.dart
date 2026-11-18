import '../../app/theme/tokens.dart';

/// The 5-point scale behind the one-tap check-in. [value] is what's
/// stored in the database (1 to 5).
///
/// Each level borrows the mood face that reads clearest at a glance.
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

/// The SVG for a mood face.
String moodFaceAsset(Mood mood) => 'assets/svg/mood/emotion_${mood.name}.svg';
