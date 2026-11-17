import 'package:flutter/material.dart';

import 'tokens.dart';

/// Builds Orb's light theme from the tokens in `tokens.dart`.
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: OrbColors.primary,
      onPrimary: OrbColors.surface,
      primaryContainer: OrbColors.mist,
      onPrimaryContainer: OrbColors.ink,
      secondary: OrbColors.champagne,
      onSecondary: OrbColors.ink,
      secondaryContainer: OrbColors.mist,
      onSecondaryContainer: OrbColors.ink,
      error: OrbColors.error,
      onError: OrbColors.surface,
      surface: OrbColors.background,
      onSurface: OrbColors.ink,
      onSurfaceVariant: OrbColors.textSecondary,
      surfaceContainerLowest: OrbColors.surface,
      surfaceContainerLow: OrbColors.surface,
      surfaceContainer: OrbColors.surface,
      surfaceContainerHigh: OrbColors.mist,
      surfaceContainerHighest: OrbColors.mist,
      outline: OrbColors.soft,
      outlineVariant: OrbColors.border,
      shadow: OrbColors.ink,
      inverseSurface: OrbColors.ink,
      onInverseSurface: OrbColors.surface,
      inversePrimary: OrbColors.soft,
    );

    // Merge onto Material's base typography so every style carries the
    // platform font, not only the ones read through Theme.of(context).
    final textTheme = Typography.material2021().black.merge(_textTheme());
    const pill = StadiumBorder();
    const buttonSize = Size(64, 52);
    const buttonPadding = EdgeInsets.symmetric(horizontal: OrbSpacing.xl);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(OrbRadii.lg),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: OrbColors.background,
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: OrbColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: OrbColors.background,
        foregroundColor: OrbColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: OrbColors.primary,
          foregroundColor: OrbColors.surface,
          disabledBackgroundColor: OrbColors.mist,
          disabledForegroundColor: OrbColors.soft,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OrbColors.primary,
          side: const BorderSide(color: OrbColors.soft),
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OrbColors.primary,
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OrbColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OrbSpacing.lg,
          vertical: OrbSpacing.lg,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: OrbColors.textMuted),
        helperStyle: textTheme.bodySmall,
        border: inputBorder(OrbColors.border),
        enabledBorder: inputBorder(OrbColors.border),
        focusedBorder: inputBorder(OrbColors.primary, 1.5),
        errorBorder: inputBorder(OrbColors.error),
        focusedErrorBorder: inputBorder(OrbColors.error, 1.5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: OrbColors.mist,
        selectedColor: OrbColors.primary,
        disabledColor: OrbColors.mist,
        checkmarkColor: OrbColors.surface,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? OrbColors.surface
                : OrbColors.ink,
          ),
        ),
        side: BorderSide.none,
        shape: pill,
        padding: const EdgeInsets.symmetric(
          horizontal: OrbSpacing.md,
          vertical: OrbSpacing.sm,
        ),
      ),
      cardTheme: CardThemeData(
        color: OrbColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrbRadii.lg),
          side: const BorderSide(color: OrbColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: OrbColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        // No pill behind the selected icon: the coloured icon and the ink
        // label carry the selection, as in Figma.
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? OrbColors.primary
                : OrbColors.textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? textTheme.labelSmall?.copyWith(
                  color: OrbColors.ink,
                  fontWeight: FontWeight.w700,
                )
              : textTheme.labelSmall?.copyWith(color: OrbColors.textMuted),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: OrbColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: OrbColors.surface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrbRadii.md),
        ),
      ),
    );
  }

  /// The type scale. Headings are tight and weighted; body text is roomy.
  static TextTheme _textTheme() {
    const ink = OrbColors.ink;
    const secondary = OrbColors.textSecondary;
    return const TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: ink,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: ink),
      bodySmall: TextStyle(fontSize: 12, height: 1.45, color: secondary),
      labelLarge: TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: ink,
      ),
    );
  }
}
