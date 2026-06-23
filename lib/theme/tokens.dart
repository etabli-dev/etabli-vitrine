import 'package:flutter/material.dart';

/// The single source of truth for all design tokens in Établi Vitrine.
///
/// "Coder/Hugo" aesthetic: minimal, whitespace-heavy, monospaced type,
/// a single teal/green accent, borders over shadows. No color, spacing,
/// radius, or font family is hardcoded anywhere else in the app — pull it
/// from here so Auto/Light/Dark and future theming stay centralized.
class VitrineTokens {
  VitrineTokens._();

  // ── Brand ────────────────────────────────────────────────────────────
  /// Single accent used across light and dark.
  static const Color accent = Color(0xFF28A745);
  static const Color accentPressed = Color(0xFF1E7E34);

  // ── Light palette ────────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightBorder = Color(0xFFE2E2E2);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextMuted = Color(0xFF6B6B6B);

  // ── Dark palette ─────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF161A20);
  static const Color darkBorder = Color(0xFF2A2F37);
  static const Color darkText = Color(0xFFE6E6E6);
  static const Color darkTextMuted = Color(0xFF8A929E);

  // ── Status ───────────────────────────────────────────────────────────
  static const Color warn = Color(0xFFD98A00);
  static const Color error = Color(0xFFD64545);
  static const Color info = Color(0xFF3B82C4);

  // ── Typography ───────────────────────────────────────────────────────
  /// Monospaced family used for labels and data (bundled, offline).
  static const String monoFamily = 'JetBrainsMono';

  // ── Spacing scale (whitespace-heavy) ─────────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 48;

  // ── Geometry — borders over shadows ──────────────────────────────────
  static const double radius = 6;
  static const double borderWidth = 1;
}
