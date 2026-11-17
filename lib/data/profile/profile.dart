import 'package:flutter/foundation.dart';

/// The companion's personality, picked on N3. It sets the tone of the
/// greetings.
enum Trait { gentle, cheerful, playful }

/// What onboarding collects about the user and their pig.
///
/// A fresh install has empty names, no trait and [onboardingDone] false.
@immutable
class Profile {
  const Profile({
    this.userName = '',
    this.pigName = '',
    this.trait,
    this.onboardingDone = false,
  });

  /// The profile of a fresh install.
  static const empty = Profile();

  final String userName;
  final String pigName;

  /// Null until the user picks one on N3.
  final Trait? trait;

  /// True only once the user reaches N15 Day one done.
  final bool onboardingDone;

  Profile copyWith({
    String? userName,
    String? pigName,
    Trait? trait,
    bool? onboardingDone,
  }) {
    return Profile(
      userName: userName ?? this.userName,
      pigName: pigName ?? this.pigName,
      trait: trait ?? this.trait,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.userName == userName &&
      other.pigName == pigName &&
      other.trait == trait &&
      other.onboardingDone == onboardingDone;

  @override
  int get hashCode => Object.hash(userName, pigName, trait, onboardingDone);

  @override
  String toString() =>
      'Profile(userName: $userName, pigName: $pigName, trait: $trait, '
      'onboardingDone: $onboardingDone)';
}
