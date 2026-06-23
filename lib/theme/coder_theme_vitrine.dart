// Copyright 2026 Raban Heller
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'coder_theme_vitrine_tokens.dart';

/// Builds the light/dark [ThemeData] for Établi Vitrine entirely from
/// [VitrineTokens]. Nothing here invents new colors — it only maps tokens
/// onto Material's scheme so the "borders over shadows", monospaced,
/// whitespace-heavy aesthetic is consistent everywhere.
class VitrineTheme {
  VitrineTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: VitrineTokens.lightBg,
        surface: VitrineTokens.lightSurface,
        border: VitrineTokens.lightBorder,
        text: VitrineTokens.lightText,
        textMuted: VitrineTokens.lightTextMuted,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: VitrineTokens.darkBg,
        surface: VitrineTokens.darkSurface,
        border: VitrineTokens.darkBorder,
        text: VitrineTokens.darkText,
        textMuted: VitrineTokens.darkTextMuted,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color border,
    required Color text,
    required Color textMuted,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: VitrineTokens.accent,
      onPrimary: Colors.white,
      secondary: VitrineTokens.accent,
      onSecondary: Colors.white,
      error: VitrineTokens.error,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
    );

    final baseText = TextStyle(color: text, fontFamily: VitrineTokens.monoFamily);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme,
      fontFamily: VitrineTokens.monoFamily,
      // Borders over shadows everywhere.
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: border, width: VitrineTokens.borderWidth),
          borderRadius: BorderRadius.circular(VitrineTokens.radius),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bg,
        foregroundColor: text,
        centerTitle: false,
        titleTextStyle: baseText.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: VitrineTokens.borderWidth),
      iconTheme: IconThemeData(color: textMuted),
      textTheme: _textTheme(text, textMuted),
      extensions: [VitrineColors(border: border, textMuted: textMuted, surface: surface)],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: VitrineTokens.accent,
          foregroundColor: Colors.white,
          textStyle: baseText.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
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
          foregroundColor: text,
          side: BorderSide(color: border, width: VitrineTokens.borderWidth),
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

/// Extra semantic colors not covered by [ColorScheme], exposed via theme so
/// widgets never hardcode border/muted/surface values.
@immutable
class VitrineColors extends ThemeExtension<VitrineColors> {
  const VitrineColors({
    required this.border,
    required this.textMuted,
    required this.surface,
  });

  final Color border;
  final Color textMuted;
  final Color surface;

  @override
  VitrineColors copyWith({Color? border, Color? textMuted, Color? surface}) =>
      VitrineColors(
        border: border ?? this.border,
        textMuted: textMuted ?? this.textMuted,
        surface: surface ?? this.surface,
      );

  @override
  VitrineColors lerp(ThemeExtension<VitrineColors>? other, double t) {
    if (other is! VitrineColors) return this;
    return VitrineColors(
      border: Color.lerp(border, other.border, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }

  static VitrineColors of(BuildContext context) =>
      Theme.of(context).extension<VitrineColors>()!;
}
