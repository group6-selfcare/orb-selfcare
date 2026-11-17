import 'package:flutter/painting.dart';

/// Design tokens for Orb's "Midnight porcelain" theme.
///
/// This is the only file in the app that may contain raw hex colours or
/// raw sizes. Screens read colours and sizes from here or from the theme.
/// Decision record: PMG6-46.
abstract final class OrbColors {
  // Brand palette.

  /// Main text colour and outlines.
  static const ink = Color(0xFF1B2550);

  /// Sapphire. Buttons, the selected tab and selected chips.
  static const primary = Color(0xFF2F4BA8);

  /// Periwinkle. Fills and borders only. Too light for text.
  static const soft = Color(0xFF8FA6E8);

  /// Selected backgrounds, the pig's hero area and chip fills.
  static const mist = Color(0xFFE9EEFB);

  /// Porcelain. The page background.
  static const background = Color(0xFFF7F8FC);

  /// Cards, sheets, text fields and the tab bar.
  static const surface = Color(0xFFFFFFFF);

  /// Small celebratory accents only, such as milestones.
  static const champagne = Color(0xFFD9B98A);

  /// Text that sits next to a [champagne] accent.
  static const champagneInk = Color(0xFF7A5A2E);

  // Neutrals.

  /// Supporting text, such as helper text and captions.
  static const textSecondary = Color(0xFF5E6685);

  /// Hints, placeholders and inactive tab labels.
  static const textMuted = Color(0xFF626985);

  /// Hairline borders and dividers.
  static const border = Color(0xFFDDE3F3);

  // Status colours. Soft, so an error never feels alarming.
  // Use them on [background] or [surface], not on [mist].

  static const success = Color(0xFF2F7A5C);
  static const warning = Color(0xFF9A6212);
  static const error = Color(0xFFB83A4E);
}

/// The check-in emotions, grouped by the Mood Meter (energy × pleasantness).
///
/// Body colours come from the Figma "ORB · Mood colors" variables. They're
/// part of the mood-face art, so they stay as drawn, whatever the UI palette.
enum Mood {
  // Pleasant, more energy.
  happy(Color(0xFFF7A8AF)),
  excited(Color(0xFFFFE27A)),
  loved(Color(0xFFFFADD9)),
  surprised(Color(0xFFF9C7A4)),
  // Pleasant, less energy.
  peaceful(Color(0xFFA9D7B6)),
  okay(Color(0xFFCFE8E6)),
  tired(Color(0xFFE0E2DC)),
  sleepy(Color(0xFFC2D7EC)),
  // Unpleasant, more energy.
  angry(Color(0xFFEA6F7E)),
  anxious(Color(0xFFBAA6E8)),
  stressed(Color(0xFFE59B8F)),
  // Unpleasant, less energy.
  sad(Color(0xFF93B3E6)),
  disappointed(Color(0xFFF6E39D)),
  numb(Color(0xFFE2CEEA));

  const Mood(this.color);

  /// The face's body colour. A fill only: draw text on it in [OrbColors.ink].
  final Color color;
}

/// Spacing on a 4-point grid.
abstract final class OrbSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Side padding for every screen.
  static const double screen = 20;
}

/// Corner radii.
abstract final class OrbRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Fully rounded ends, for pill buttons and chips.
  static const double pill = 999;
}
