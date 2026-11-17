/// All user-facing text, in one place so it can be reviewed and later
/// translated (Khmer).
///
/// PMG6-52 adds the trait greetings and the rest of the onboarding and
/// check-in text here.
library;

/// Text for the onboarding screens (N1 to N4).
abstract final class OnboardingCopy {
  // N1 Meet your companion
  static const meetTitle = "Hi! I'm your new companion";
  static const meetPromises = [
    'One small check-in a day is enough',
    "We'll travel across Cambodia together",
    'Everything stays on your phone',
  ];
  static const meetButton = "Let's begin";
  static const meetFootnote = 'Takes about a minute';

  // Shared
  static const back = 'Back';
  static const next = 'Continue';
  static String progress(int step, int total) => 'Step $step of $total';
}
