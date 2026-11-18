/// Pig D's poses, exported from Figma ("Companion · Pig D", node 826:805).
///
/// Every file renders in flutter_svg: flat shapes only, no masks or
/// filters.
enum PigPose {
  /// Before today's check-in: curious, waiting for the user.
  curious('pig_curious'),

  /// Waving hello, on the check-in screen.
  hello('pig_wave'),

  /// Rough: arms open, a small heart. Never disappointed.
  comforting('pig_comforting'),

  /// Low: head tilted, listening closely.
  listening('pig_listening'),

  /// Okay: eyes closed, settled.
  calm('pig_calm'),

  /// Good, and N3: arms up with a sparkle ("Joyful" in Figma).
  joyful('pig_cheer'),

  /// Great, and N15: cheering with confetti.
  cheering('pig_cheering');

  const PigPose(this.file);

  final String file;

  String get asset => 'assets/svg/pig/$file.svg';

  /// The pose Home shows for today's mood [level] (1 Rough to 5 Great), or
  /// [curious] before a check-in.
  static PigPose forLevel(int? level) => switch (level) {
    1 => comforting,
    2 => listening,
    3 => calm,
    4 => joyful,
    5 => cheering,
    _ => curious,
  };
}
