import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orb_pm/app/theme/app_theme.dart';
import 'package:orb_pm/app/theme/tokens.dart';

void main() {
  final theme = AppTheme.light();

  test('uses the Midnight porcelain colours', () {
    expect(theme.colorScheme.primary, OrbColors.primary);
    expect(theme.colorScheme.onSurface, OrbColors.ink);
    expect(theme.scaffoldBackgroundColor, OrbColors.background);
  });

  test('filled buttons are sapphire pills', () {
    final style = theme.filledButtonTheme.style!;
    expect(style.backgroundColor!.resolve({}), OrbColors.primary);
    expect(style.shape!.resolve({}), isA<StadiumBorder>());
  });

  test('there are 14 mood colours, one per Figma mood face', () {
    expect(Mood.values, hasLength(14));
  });
}
