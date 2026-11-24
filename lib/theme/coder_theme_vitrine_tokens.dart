// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'coder_theme.dart';

/// Vitrine design tokens. The neutrals are the Hugo Coder palette and the accent is the user's choice
/// (appearance.dart); widgets read colours from the theme (`Theme.of(context).colorScheme`,
/// [VitrineColors]). Hex-string mirrors for embedded WebView / R code live below.
class VitrineTokens {
  VitrineTokens._();

  // ── Hex-string mirrors for code-as-string (WebView CSS, embedded R) ──
  // The WebR console page is always dark: Hugo Coder dark neutrals and state colours (appearance.dart).
  // The accent arrives at run time as a query parameter; this is its default (Coder blue, dark).
  static const String accentHex = '#42A5F5';
  static const String darkBgHex = '#212121';
  static const String darkTextHex = '#DADADA';
  static const String darkTextMutedHex = '#BDBDBD';
  static const String darkBorderHex = '#4F4F4F';
  static const String warnHex = '#FFCA28';
  static const String errorHex = '#EF9A9A';

  // ── Typography ───────────────────────────────────────────────────────
  static const String monoFamily = Coder.fontMono;
  static const List<String> monoFallback = ['Menlo', 'monospace'];

  // ── Spacing scale (whitespace-heavy) ─────────────────────────────────
  static const double space1 = Coder.xs;
  static const double space2 = Coder.sm;
  static const double space3 = 12;
  static const double space4 = Coder.md;
  static const double space5 = Coder.lg;
  static const double space6 = Coder.xl;
  static const double space7 = Coder.xxl;

  // ── Geometry — borders over shadows ──────────────────────────────────
  static const double radius = 6;
  static const double borderWidth = 1;
}
