// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

// Localized labels for model values and stored texts, made when they are shown.

import '../data/models/resolution_status.dart';
import '../data/models/source_type.dart';
import '../features/import/import_errors.dart';
import 'app_localizations.dart';

extension ModelLabels on AppLocalizations {
  String sourceTypeLabel(SourceType type) => switch (type) {
    SourceType.shinyliveZip => sourceShinylive,
    SourceType.rawSource => sourceRaw,
    SourceType.packageApp => sourcePackage,
    SourceType.liveUrl => sourceLiveUrl,
  };

  String resolutionLabel(ResolutionState state) => switch (state) {
    ResolutionState.pending => statePending,
    ResolutionState.ready => stateReady,
    ResolutionState.warnings => stateWarnings,
    ResolutionState.failed => stateFailed,
    ResolutionState.notApplicable => stateNotApplicable,
  };

  /// A stored resolution detail (English, see PackageResolver) in the current language.
  String resolutionDetailText(String detail) {
    const notBundled = 'Not bundled (needs a connection at launch): ';
    if (detail.startsWith(notBundled)) {
      return resolutionNotBundled(detail.substring(notBundled.length));
    }
    return detail;
  }

  /// A failed import, download or launch: the localized reason where it is known.
  String importErrorText(Object error) => describeImportError(error, this);
}
