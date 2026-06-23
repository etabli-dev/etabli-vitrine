// Copyright 2026 Raban Heller
// SPDX-License-Identifier: Apache-2.0

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

  String get label => switch (this) {
        ResolutionState.pending => 'Pending',
        ResolutionState.ready => 'Ready',
        ResolutionState.warnings => 'Warnings',
        ResolutionState.failed => 'Failed',
        ResolutionState.notApplicable => 'N/A',
      };
}
