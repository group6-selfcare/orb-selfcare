import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profile/profile.dart';

/// The answers given so far in onboarding, held in memory while the user
/// moves between N1 and N4.
///
/// The provider lives for the whole app session, so the answers survive
/// going back and forward. They are only written to the device on N4, via
/// `profileProvider.notifier.saveAnswers`.
class OnboardingDraft {
  const OnboardingDraft({this.pigName = '', this.trait, this.userName = ''});

  final String pigName;
  final Trait? trait;
  final String userName;

  OnboardingDraft copyWith({String? pigName, Trait? trait, String? userName}) {
    return OnboardingDraft(
      pigName: pigName ?? this.pigName,
      trait: trait ?? this.trait,
      userName: userName ?? this.userName,
    );
  }
}

final onboardingDraftProvider =
    NotifierProvider<OnboardingDraftNotifier, OnboardingDraft>(
      OnboardingDraftNotifier.new,
    );

class OnboardingDraftNotifier extends Notifier<OnboardingDraft> {
  @override
  OnboardingDraft build() => const OnboardingDraft();

  void setPigName(String name) => state = state.copyWith(pigName: name);
  void setTrait(Trait trait) => state = state.copyWith(trait: trait);
  void setUserName(String name) => state = state.copyWith(userName: name);
}
