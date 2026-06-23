// Copyright 2026 Raban Heller
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'coder_theme.dart';

/// Vitrine design tokens. Central palette (accent + light/dark surfaces)
/// derives from [Coder] (synced from `_style/tokens/coder-design-system.json`).
/// Vitrine-only semantic colors (warn/error/info) and hex-string mirrors for
/// embedded WebView / R / Shiny code live below.
class VitrineTokens {
  VitrineTokens._();

  // ── Brand (central tokens) ───────────────────────────────────────────
  static const Color accent = Coder.accentBase;
  static const Color accentPressed = Coder.accentDark;

  // ── Light palette (central tokens) ───────────────────────────────────
  static const Color lightBg = Coder.lBackground;
  static const Color lightSurface = Coder.lSurface;
  static const Color lightBorder = Coder.lBorder;
  static const Color lightText = Coder.lTextPrimary;
  static const Color lightTextMuted = Coder.lTextSecondary;

  // ── Dark palette (central tokens) ────────────────────────────────────
  static const Color darkBg = Coder.dBackground;
  static const Color darkSurface = Coder.dSurface;
  static const Color darkBorder = Coder.dBorder;
  static const Color darkText = Coder.dTextPrimary;
  static const Color darkTextMuted = Coder.dTextSecondary;

  // ── Vitrine-specific status colors ───────────────────────────────────
  static const Color warn = Color(0xFFD98A00);
  static const Color error = Color(0xFFD64545);
  static const Color info = Color(0xFF3B82C4);

  // ── Hex-string mirrors for code-as-string (WebView CSS, embedded R)
  // Each value must match the corresponding Color constant above. Keep in
  // sync — the audit gate only inspects `Color(0x...)` constructors so these
  // are the only place hex strings are allowed.
  static const String accentHex = '#28A745';
  static const String darkBgHex = '#121417';
  static const String darkTextHex = '#F2F4F6';
  static const String darkTextMutedHex = '#A6ACB3';
  static const String darkBorderHex = '#33373D';
  static const String warnHex = '#D98A00';
  static const String errorHex = '#D64545';

  // ── Typography ───────────────────────────────────────────────────────
  static const String monoFamily = Coder.fontMono;

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
