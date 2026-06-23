// Copyright 2026 Raban Heller
// SPDX-License-Identifier: Apache-2.0

import '../../data/models/resolution_status.dart';

/// Result of scanning raw Shiny source for required R packages and checking
/// them against what is available offline (bundled in the shinylive R image).
class PackageResolution {
  const PackageResolution({
    required this.required_,
    required this.missing,
    required this.state,
    required this.detail,
  });

  final Set<String> required_;
  final Set<String> missing;
  final ResolutionState state;
  final String? detail;
}

/// Resolves R package availability for raw Shiny source.
///
/// Available-offline = the packages baked into the bundled shinylive R image
/// plus base/recommended R packages. Anything else would need an online
/// install from the WASM repo at launch, so we warn before running.
class PackageResolver {
  /// Packages present in the bundled shinylive R library image (offline-ready).
  static const Set<String> bundled = {
    'shiny', 'httpuv', 'R6', 'Rcpp', 'base64enc', 'bslib', 'cachem', 'cli',
    'codetools', 'colorspace', 'commonmark', 'crayon', 'digest', 'ellipsis',
    'fastmap', 'fontawesome', 'fs', 'glue', 'htmltools', 'jquerylib',
    'jsonlite', 'later', 'lifecycle', 'magrittr', 'memoise', 'mime', 'munsell',
    'otel', 'promises', 'rappdirs', 'renv', 'rlang', 'sass', 'sourcetools',
    'withr', 'xtable',
  };

  /// Base + recommended packages shipped inside WebR itself.
  static const Set<String> base = {
    'base', 'compiler', 'datasets', 'grDevices', 'graphics', 'grid', 'methods',
    'parallel', 'splines', 'stats', 'stats4', 'tcltk', 'tools', 'utils',
    'MASS', 'Matrix', 'lattice',
  };

  static final RegExp _libCall = RegExp(
    r'''(?:library|require|requireNamespace|loadNamespace)\(\s*['"]?([A-Za-z][A-Za-z0-9._]*)['"]?''',
  );
  static final RegExp _nsCall = RegExp(r'''([A-Za-z][A-Za-z0-9._]*)::''');

  /// Scans combined source text for package usage.
  static Set<String> scan(String source) {
    final found = <String>{};
    for (final m in _libCall.allMatches(source)) {
      found.add(m.group(1)!);
    }
    for (final m in _nsCall.allMatches(source)) {
      found.add(m.group(1)!);
    }
    found.remove('base');
    return found;
  }

  /// Resolves [source]'s packages against what runs offline.
  static PackageResolution resolve(String source) {
    final required_ = scan(source)..add('shiny');
    final missing = required_
        .where((p) => !bundled.contains(p) && !base.contains(p))
        .toSet();

    if (missing.isEmpty) {
      return PackageResolution(
        required_: required_,
        missing: const {},
        state: ResolutionState.ready,
        detail: null,
      );
    }
    return PackageResolution(
      required_: required_,
      missing: missing,
      state: ResolutionState.warnings,
      detail: 'Not bundled (needs a connection at launch): '
          '${(missing.toList()..sort()).join(', ')}',
    );
  }
}
