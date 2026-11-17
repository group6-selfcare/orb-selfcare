import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile.dart';

/// Reads and writes the [Profile] on the device with shared_preferences.
///
/// UI code should not use this directly: watch [profileProvider] and call
/// its notifier instead, so every listener sees the change.
class ProfileRepository {
  ProfileRepository({Future<SharedPreferences>? prefs})
    : _prefs = prefs ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _prefs;

  static const _userName = 'profile.userName';
  static const _pigName = 'profile.pigName';
  static const _trait = 'profile.trait';
  static const _onboardingDone = 'profile.onboardingDone';

  Future<Profile> load() async {
    final prefs = await _prefs;
    return Profile(
      userName: prefs.getString(_userName) ?? '',
      pigName: prefs.getString(_pigName) ?? '',
      trait: _traitFromName(prefs.getString(_trait)),
      onboardingDone: prefs.getBool(_onboardingDone) ?? false,
    );
  }

  Future<void> save(Profile profile) async {
    final prefs = await _prefs;
    await prefs.setString(_userName, profile.userName);
    await prefs.setString(_pigName, profile.pigName);
    final trait = profile.trait;
    if (trait == null) {
      await prefs.remove(_trait);
    } else {
      await prefs.setString(_trait, trait.name);
    }
    await prefs.setBool(_onboardingDone, profile.onboardingDone);
  }

  /// An unknown or missing name reads as "not picked yet", so an old or
  /// broken value can never crash the app.
  static Trait? _traitFromName(String? name) {
    for (final trait in Trait.values) {
      if (trait.name == name) return trait;
    }
    return null;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

/// The saved profile. It is loading on cold start, then holds the stored
/// value. Saving through the notifier updates every listener.
final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() => ref.watch(profileRepositoryProvider).load();

  /// Saves [profile] to the device and then updates listeners.
  Future<void> save(Profile profile) async {
    await ref.read(profileRepositoryProvider).save(profile);
    state = AsyncData(profile);
  }

  /// Saves the onboarding answers. Called when N4 is completed.
  Future<void> saveAnswers({
    required String userName,
    required String pigName,
    required Trait trait,
  }) async {
    final current = await future;
    await save(
      current.copyWith(userName: userName, pigName: pigName, trait: trait),
    );
  }

  /// Marks onboarding as finished. Called only on N15 Day one done.
  Future<void> completeOnboarding() async {
    final current = await future;
    await save(current.copyWith(onboardingDone: true));
  }
}
