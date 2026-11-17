import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile/profile.dart';
import 'shell/orb_tab.dart';

/// Where the app opens on a cold start, before the profile is loaded.
const splashPath = '/splash';

/// The first onboarding screen, N1 Meet your companion.
const onboardingStartPath = '/onboarding/meet';

/// Decides where a navigation to [location] should go instead, or null to
/// allow it.
///
/// - While the profile is loading, everything waits on the splash, so
///   neither Home nor onboarding flashes up on cold start.
/// - Until onboarding is done, the splash and the four tabs send the user
///   to N1. Onboarding and check-in routes are allowed, so the first
///   check-in (N12, N13) and N15 work inside onboarding.
/// - Once onboarding is done, the splash opens Home.
///
/// Onboarding is only marked done on N15, so a user who quits halfway
/// starts again from N1 next time.
String? firstLaunchRedirect(AsyncValue<Profile> profile, String location) {
  if (!profile.hasValue && !profile.hasError) {
    return location == splashPath ? null : splashPath;
  }

  // If the profile can't be read, treat the user as new: onboarding is
  // safer than an empty Home. Riverpod retries the load on its own.
  final done = profile.value?.onboardingDone ?? false;

  if (done) {
    return location == splashPath ? OrbTab.home.path : null;
  }
  if (location == splashPath || _isTab(location)) {
    return onboardingStartPath;
  }
  return null;
}

bool _isTab(String location) => OrbTab.values.any(
  (tab) => location == tab.path || location.startsWith('${tab.path}/'),
);
