import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/app/theme/tokens.dart';

/// WCAG 2.1 contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const minAA = 4.5;

  // Every text colour the theme draws, on every background it can sit on.
  final pairs = <String, (Color, Color)>{
    'ink on background': (OrbColors.ink, OrbColors.background),
    'ink on surface': (OrbColors.ink, OrbColors.surface),
    'ink on mist': (OrbColors.ink, OrbColors.mist),
    'ink on champagne': (OrbColors.ink, OrbColors.champagne),
    'secondary on background': (OrbColors.textSecondary, OrbColors.background),
    'secondary on surface': (OrbColors.textSecondary, OrbColors.surface),
    'secondary on mist': (OrbColors.textSecondary, OrbColors.mist),
    'muted on background': (OrbColors.textMuted, OrbColors.background),
    'muted on surface': (OrbColors.textMuted, OrbColors.surface),
    'primary on background': (OrbColors.primary, OrbColors.background),
    'primary on surface': (OrbColors.primary, OrbColors.surface),
    'primary on mist': (OrbColors.primary, OrbColors.mist),
    'surface on primary': (OrbColors.surface, OrbColors.primary),
    'surface on ink': (OrbColors.surface, OrbColors.ink),
    'surface on error': (OrbColors.surface, OrbColors.error),
    'champagne ink on surface': (OrbColors.champagneInk, OrbColors.surface),
    'champagne ink on background': (
      OrbColors.champagneInk,
      OrbColors.background,
    ),
    'success on surface': (OrbColors.success, OrbColors.surface),
    'success on background': (OrbColors.success, OrbColors.background),
    'warning on surface': (OrbColors.warning, OrbColors.surface),
    'warning on background': (OrbColors.warning, OrbColors.background),
    'error on surface': (OrbColors.error, OrbColors.surface),
    'error on background': (OrbColors.error, OrbColors.background),
  };

  for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries) {
    test('$name meets WCAG AA', () {
      expect(contrast(fg, bg), greaterThanOrEqualTo(minAA));
    });
  }

  test('ink text is readable on every mood colour', () {
    for (final mood in Mood.values) {
      expect(
        contrast(OrbColors.ink, mood.color),
        greaterThanOrEqualTo(minAA),
        reason: mood.name,
      );
    }
  });
}
