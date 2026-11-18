import 'dart:math';

import '../../shared/copy.dart';

/// Picks a suggested pig name that differs from [current].
///
/// The comparison ignores case and surrounding spaces, so "bao " never
/// gets "Bao" back.
String suggestPigName(String current, {Random? random}) {
  final now = current.trim().toLowerCase();
  final choices = OnboardingCopy.pigNames
      .where((name) => name.toLowerCase() != now)
      .toList();
  return choices[(random ?? Random()).nextInt(choices.length)];
}

/// A pig or user name to save: [raw] without surrounding spaces, or null
/// when that leaves nothing or more than 20 characters. Used by N2 and N4.
String? validName(String raw) {
  final name = raw.trim();
  if (name.isEmpty || name.length > OnboardingCopy.nameMaxLength) return null;
  return name;
}
