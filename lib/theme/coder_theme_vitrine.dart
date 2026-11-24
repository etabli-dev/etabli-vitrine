// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/material.dart';

import 'appearance.dart';
import 'coder_theme_vitrine_tokens.dart';

/// Builds the light/dark [ThemeData] for Établi Vitrine from the Hugo Coder neutrals and the user's accent
/// (appearance.dart). Borders over shadows, monospaced, whitespace-heavy. Containers (cards, dialogs, sheets)
/// use the page background, so accent text on them keeps at least 4.5:1; selection fills use
/// [AccentChoice.selectionColor] (neutral for yellow and orange), so no background is tinted yellow.
class VitrineTheme {
  VitrineTheme._();

  static ThemeData light([AccentChoice accent = AccentChoice.coderBlue]) =>
      build(Brightness.light, accent);

  static ThemeData dark([AccentChoice accent = AccentChoice.coderBlue]) =>
      build(Brightness.dark, accent);

  static ThemeData build(Brightness brightness, AccentChoice accentChoice) {
    final c = VitrineColors.resolve(brightness, accentChoice);
    final accent = c.accent;
    final selectionFill = c.selectionFill;
    final selectionOverlay = WidgetStateProperty.resolveWith<Color?>(
      (states) =>
          states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)
          ? selectionFill
          : null,
    );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: c.onAccent,
      primaryContainer: selectionFill,
      onPrimaryContainer: c.text,
      secondary: accent,
      onSecondary: c.onAccent,
      secondaryContainer: selectionFill,
      onSecondaryContainer: c.text,
      tertiary: accent,
      onTertiary: c.onAccent,
      tertiaryContainer: selectionFill,
      onTertiaryContainer: c.text,
      error: c.error,
      onError: c.onAccent,
      surface: c.background,
      onSurface: c.text,
      onSurfaceVariant: c.textMuted,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.background,
      surfaceContainer: c.background,
      surfaceContainerHigh: c.background,
      surfaceContainerHighest: c.surface,
      outline: c.border,
      outlineVariant: c.border,
      inverseSurface: c.text,
      onInverseSurface: c.background,
      inversePrimary: accentChoice.color(
        brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
      // No accent tint on elevated surfaces (dialogs, sheets, menus).
      surfaceTint: Colors.transparent,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final baseText = TextStyle(
      color: c.text,
      fontFamily: VitrineTokens.monoFamily,
      fontFamilyFallback: VitrineTokens.monoFallback,
    );
    final hairline = BorderSide(
      color: c.border,
      width: VitrineTokens.borderWidth,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      colorScheme: scheme,
      fontFamily: VitrineTokens.monoFamily,
      fontFamilyFallback: VitrineTokens.monoFallback,
      // Borders over shadows everywhere.
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.background,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: hairline,
          borderRadius: BorderRadius.circular(VitrineTokens.radius),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: c.background,
        foregroundColor: c.text,
        centerTitle: false,
        titleTextStyle: baseText.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: hairline,
          borderRadius: BorderRadius.circular(VitrineTokens.radius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: c.border,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.background,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.text,
        contentTextStyle: baseText.copyWith(color: c.background),
        actionTextColor: c.background,
      ),
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: VitrineTokens.borderWidth,
      ),
      iconTheme: IconThemeData(color: c.textMuted),
      textTheme: _textTheme(c.text, c.textMuted),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: c.selection.withValues(
          alpha: AccentChoice.textSelectionOpacity,
        ),
        selectionHandleColor: accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
      extensions: [c],
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: c.onAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? selectionFill
                : Colors.transparent,
          ),
          // Labels on a selection fill stay in the text colour (at least 4.5:1 on every fill).
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.disabled) ? c.textMuted : c.text,
          ),
          overlayColor: selectionOverlay,
          side: WidgetStatePropertyAll(hairline),
          textStyle: WidgetStatePropertyAll(
            baseText.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.disabled) ? c.textMuted : accent,
          ),
          overlayColor: selectionOverlay,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: c.onAccent,
          textStyle: baseText.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VitrineTokens.radius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: VitrineTokens.space4,
            vertical: VitrineTokens.space3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          side: hairline,
          textStyle: baseText.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VitrineTokens.radius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: VitrineTokens.space4,
            vertical: VitrineTokens.space3,
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color text, Color muted) {
    TextStyle s(double size, FontWeight w, {Color? c}) => TextStyle(
      fontFamily: VitrineTokens.monoFamily,
      fontFamilyFallback: VitrineTokens.monoFallback,
      fontSize: size,
      fontWeight: w,
      color: c ?? text,
    );
    return TextTheme(
      titleLarge: s(20, FontWeight.w700),
      titleMedium: s(16, FontWeight.w600),
      bodyLarge: s(15, FontWeight.w400),
      bodyMedium: s(14, FontWeight.w400),
      bodySmall: s(12, FontWeight.w400, c: muted),
      labelLarge: s(13, FontWeight.w600),
      labelSmall: s(11, FontWeight.w500, c: muted),
    );
  }
}

/// The resolved palette of the current theme, exposed via the theme so widgets never hardcode colours:
/// Hugo Coder neutrals, the user's accent and the state colours.
@immutable
class VitrineColors extends ThemeExtension<VitrineColors> {
  const VitrineColors({
    required this.accent,
    required this.onAccent,
    required this.selection,
    required this.background,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.surface,
    required this.success,
    required this.warn,
    required this.error,
  });

  factory VitrineColors.resolve(Brightness b, AccentChoice accent) =>
      VitrineColors(
        accent: accent.color(b),
        onAccent: CoderPalette.color(CoderPalette.onAccent(b)),
        selection: accent.selectionColor(b),
        background: CoderPalette.color(CoderPalette.background(b)),
        border: CoderPalette.color(CoderPalette.border(b)),
        text: CoderPalette.color(CoderPalette.foreground(b)),
        textMuted: CoderPalette.color(CoderPalette.muted(b)),
        surface: CoderPalette.color(CoderPalette.surface(b)),
        success: CoderPalette.color(CoderPalette.success(b)),
        warn: CoderPalette.color(CoderPalette.warning(b)),
        error: CoderPalette.color(CoderPalette.danger(b)),
      );

  /// The user's accent: text, icons, outlines and solid fills.
  final Color accent;

  /// Text and symbols on an accent, warn or error fill.
  final Color onAccent;

  /// The colour of selection fills, drawn at [AccentChoice.selectionOpacity] (neutral for yellow and orange).
  final Color selection;
  final Color background;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color surface;
  final Color success;
  final Color warn;
  final Color error;

  Color get selectionFill =>
      selection.withValues(alpha: AccentChoice.selectionOpacity);

  @override
  VitrineColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? selection,
    Color? background,
    Color? border,
    Color? text,
    Color? textMuted,
    Color? surface,
    Color? success,
    Color? warn,
    Color? error,
  }) => VitrineColors(
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    selection: selection ?? this.selection,
    background: background ?? this.background,
    border: border ?? this.border,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    surface: surface ?? this.surface,
    success: success ?? this.success,
    warn: warn ?? this.warn,
    error: error ?? this.error,
  );

  @override
  VitrineColors lerp(ThemeExtension<VitrineColors>? other, double t) {
    if (other is! VitrineColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return VitrineColors(
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      selection: l(selection, other.selection),
      background: l(background, other.background),
      border: l(border, other.border),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      surface: l(surface, other.surface),
      success: l(success, other.success),
      warn: l(warn, other.warn),
      error: l(error, other.error),
    );
  }

  static VitrineColors of(BuildContext context) =>
      Theme.of(context).extension<VitrineColors>() ??
      VitrineColors.resolve(
        Theme.of(context).brightness,
        AccentChoice.coderBlue,
      );
}
