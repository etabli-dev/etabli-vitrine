// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

/// Outcome of resolving an app's R packages against the WebR WASM repo.
enum ResolutionState {
  /// Not yet attempted (e.g. freshly imported, or live URL).
  pending,

  /// All required packages resolved and installable offline.
  ready,

  /// Resolved, but with missing or unmet-WASM-dependency warnings.
  warnings,

  /// Resolution or staging failed.
  failed,

  /// Not applicable (live URL runs its R on the server).
  notApplicable;

  // Display names are localized in lib/l10n/labels.dart.
}
