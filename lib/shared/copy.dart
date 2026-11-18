/// All user-facing text, in one place so it can be reviewed and later
/// translated (Khmer).
///
/// PMG6-52 adds the trait greetings and the rest of the onboarding and
/// check-in text here.
library;

import '../app/theme/tokens.dart';
import '../data/profile/profile.dart';
import '../features/check_in/mood_level.dart';

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

  // N15 Day one done
  static const dayOneTitle = 'Day one, done!';
  static const dayOneButton = 'Go to Home';

  /// The pig's line on N15, in its trait's voice.
  ///
  /// On a Rough or Low first check-in every trait speaks gently: the pig
  /// stays close and never sounds disappointed.
  static String dayOneLine({
    required Trait trait,
    required int level,
    required String userName,
  }) {
    if (level <= 2) {
      return "Thank you for telling me, $userName. Hard days count too, "
          "and I'm right here with you. Let's go home and take it slow.";
    }
    return switch (trait) {
      Trait.gentle =>
        'Thank you for telling me how you feel, $userName. '
            "That's day one, and it counts. Let's go home together.",
      Trait.cheerful =>
        'You did it, $userName! Your first check-in is in. '
            "I'm so happy we started. Let's go see our home!",
      Trait.playful =>
        'Ding ding! Day one unlocked, $userName. '
            "I'm putting this in my scrapbook. Race you home?",
    };
  }

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

/// Text for the daily check-in.
abstract final class CheckInCopy {
  static const title = 'Today';
  static const editTitle = 'Edit today';

  // First check-in inside onboarding (N12, N13)
  static const firstTitle = 'Your first check-in';
  static const firstQuestion = 'How are you feeling right now?';
  static const continueLabel = 'Continue';
  static const skip = 'Skip';
  static const question = 'How are you feeling today?';
  static const reassurance = "Pick what fits. There's no wrong answer.";
  static const done = 'Done';
  static const saved = "Saved. That's enough for today, or add a little more.";
  static const saveFailed = "I couldn't save that. Please try again.";

  static const levelName = {
    MoodLevel.rough: 'Rough',
    MoodLevel.low: 'Low',
    MoodLevel.okay: 'Okay',
    MoodLevel.good: 'Good',
    MoodLevel.great: 'Great',
  };

  // Optional emotion (PMG6-59)
  static const emotionTitle = 'Want to name it?';
  static const emotionHint = 'Optional. Tap again to clear.';

  static const emotionName = {
    Mood.happy: 'Happy',
    Mood.excited: 'Excited',
    Mood.loved: 'Loved',
    Mood.surprised: 'Surprised',
    Mood.peaceful: 'Peaceful',
    Mood.okay: 'Okay',
    Mood.tired: 'Tired',
    Mood.sleepy: 'Sleepy',
    Mood.angry: 'Angry',
    Mood.anxious: 'Anxious',
    Mood.stressed: 'Stressed',
    Mood.sad: 'Sad',
    Mood.disappointed: 'Disappointed',
    Mood.numb: 'Numb',
  };

  // Note and tags (PMG6-60)
  static const noteHint = 'Add a note (optional)';
  static const noteMaxLength = 500;
  static const tagsTitle = "What's it about?";
  static const moreTags = 'More tags';
  static const fewerTags = 'Fewer tags';

  /// What TalkBack reads for a level face, e.g. "Feeling Low".
  static String levelSemantics(MoodLevel level) =>
      'Feeling ${levelName[level]}';
}
