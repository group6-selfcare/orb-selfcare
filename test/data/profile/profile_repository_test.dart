import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/data/profile/profile.dart';
import 'package:orb_pm/data/profile/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const saved = Profile(
    userName: 'Dara',
    pigName: 'Mochi',
    trait: Trait.cheerful,
    onboardingDone: true,
  );

  group('ProfileRepository', () {
    test('a fresh install reads the empty profile', () async {
      SharedPreferences.setMockInitialValues({});

      final profile = await ProfileRepository().load();

      expect(profile, Profile.empty);
      expect(profile.onboardingDone, isFalse);
      expect(profile.userName, isEmpty);
      expect(profile.pigName, isEmpty);
      expect(profile.trait, isNull);
    });

    test('save then load returns the same values', () async {
      SharedPreferences.setMockInitialValues({});

      await ProfileRepository().save(saved);

      expect(await ProfileRepository().load(), saved);
    });

    test('values survive a restart', () async {
      // What a restart leaves behind on disk, read by a new instance.
      SharedPreferences.setMockInitialValues({
        'profile.userName': 'Dara',
        'profile.pigName': 'Mochi',
        'profile.trait': 'cheerful',
        'profile.onboardingDone': true,
      });

      expect(await ProfileRepository().load(), saved);
    });

    test('saving no trait clears a stored one', () async {
      SharedPreferences.setMockInitialValues({'profile.trait': 'gentle'});
      final repo = ProfileRepository();

      await repo.save(const Profile(userName: 'Dara'));

      expect((await repo.load()).trait, isNull);
    });

    test('an unknown trait reads as not picked', () async {
      SharedPreferences.setMockInitialValues({'profile.trait': 'grumpy'});

      expect((await ProfileRepository().load()).trait, isNull);
    });
  });

  group('profileProvider', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('loads the stored profile', () async {
      expect(await container.read(profileProvider.future), Profile.empty);
    });

    test('saveAnswers stores the answers but not onboardingDone', () async {
      final notifier = container.read(profileProvider.notifier);

      await notifier.saveAnswers(
        userName: 'Dara',
        pigName: 'Mochi',
        trait: Trait.gentle,
      );

      final expected = const Profile(
        userName: 'Dara',
        pigName: 'Mochi',
        trait: Trait.gentle,
      );
      expect(container.read(profileProvider).value, expected);
      expect(await ProfileRepository().load(), expected);
    });

    test('completeOnboarding notifies listeners and persists', () async {
      await container.read(profileProvider.future);
      final seen = <bool?>[];
      container.listen(
        profileProvider,
        (_, next) => seen.add(next.value?.onboardingDone),
      );

      await container.read(profileProvider.notifier).completeOnboarding();

      expect(seen, [true]);
      expect((await ProfileRepository().load()).onboardingDone, isTrue);
    });

    test('reset forgets the profile, as on a fresh install', () async {
      SharedPreferences.setMockInitialValues({
        'profile.userName': 'Dara',
        'profile.pigName': 'Mochi',
        'profile.trait': 'cheerful',
        'profile.onboardingDone': true,
      });
      await container.read(profileProvider.future);

      await container.read(profileProvider.notifier).reset();

      expect(container.read(profileProvider).value, Profile.empty);
      expect(await ProfileRepository().load(), Profile.empty);
    });
  });
}
