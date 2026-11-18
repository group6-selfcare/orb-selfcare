/// All user-facing text, in one place so it can be reviewed and later
/// translated (Khmer).
///
/// PMG6-52 adds the trait greetings and the rest of the onboarding and
/// check-in text here.
library;

import '../data/profile/profile.dart';

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

  // N2 Name your companion
  static const nameTitle = 'What would you like to call me?';
  static const nameHint = 'Give me a name';
  static const nameHelper =
      'I picked one for you. Keep it, change it, or try another.';
  static const nameSuggest = 'Suggest another name';
  static const nameMaxLength = 20;

  /// Suggested pig names. The first is the default.
  static const pigNames = [
    'Bao',
    'Mochi',
    'Sokha',
    'Bopha',
    'Kiri',
    'Mango',
    'Nom',
    'Lotus',
    'Pepper',
    'Dumpling',
    'Tuk Tuk',
    'Kampot',
  ];

  // N3 Companion trait
  static const traitTitle = 'What am I like?';
  static const traitSubtitle =
      "Pick my personality for good days. On hard days, I'm always gentle.";
  static const traitName = {
    Trait.gentle: 'Gentle',
    Trait.cheerful: 'Cheerful',
    Trait.playful: 'Playful',
  };
  static const traitDescription = {
    Trait.gentle: 'Calm and soft, never in a hurry',
    Trait.cheerful: 'Bright, celebrates small wins',
    Trait.playful: 'A bit silly, here to make you smile',
  };

  /// A line in each trait's voice, shown on its card.
  static const traitSample = {
    Trait.gentle: "“Whenever you're ready, I'm here.”",
    Trait.cheerful: '“Yay! You showed up today!”',
    Trait.playful: '“Psst… I saved you a spot.”',
  };

  // N4 Your name
  static String youIntro(String pigName) => "Nice to meet you. I'm $pigName!";
  static const youTitle = "And what's your name?";
  static const youHint = 'Your first name or nickname';
  static const youHelper =
      "I'll use it when I talk to you. Only you will see it.";
  static const saveFailed = "I couldn't save that. Please try again.";

  // Shared
  static const back = 'Back';
  static const next = 'Next';
  static String progress(int step, int total) => 'Step $step of $total';
}

/// Text for the Home tab.
abstract final class HomeCopy {
  static const title = 'Orb';
  static const checkIn = 'Check in';

  /// What the pig says before today's check-in, in its trait's voice.
  static String greetingBefore({
    required Trait trait,
    required String userName,
    required String pigName,
  }) {
    return switch (trait) {
      Trait.gentle =>
        "Hi $userName, it's $pigName. Whenever you're ready, "
            "tell me how today feels.",
      Trait.cheerful =>
        "Hey $userName! $pigName here. I can't wait to hear "
            'how your day is going!',
      Trait.playful =>
        'Psst, $userName… $pigName saved you a spot. '
            'How are we feeling today?',
    };
  }

  // Today card
  static const todayLabel = 'Today';
  static const todayEmptyTitle = 'No check-in yet today';
  static const todayEmptyBody = 'One tap is enough. It takes a few seconds.';
}
