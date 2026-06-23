import 'package:path/path.dart' as p;

enum ImportKind { shinyliveBundle, rawSource, unknown }

/// Decision about what an imported archive/folder contains and where its root
/// is (zips often wrap everything in a single top-level folder).
class ImportDecision {
  const ImportDecision(this.kind, this.rootPrefix);

  final ImportKind kind;

  /// Path prefix (with trailing '/') under which the app's files live, or ''
  /// when the app is at the archive root.
  final String rootPrefix;

  bool get recognized => kind != ImportKind.unknown;
}

/// Classifies a set of archive entry paths as a self-contained shinylive
/// bundle, raw Shiny source, or unknown — and finds the directory the app
/// lives in so a wrapping folder can be stripped on staging.
class ImportRouter {
  /// [entryNames] are forward-slash relative paths of files in the archive.
  static ImportDecision classify(Iterable<String> entryNames) {
    final names = entryNames
        .map((n) => n.replaceAll('\\', '/'))
        .where((n) => !n.endsWith('/'))
        .toList();

    // Shinylive bundle: an index.html with a sibling shinylive/ engine dir
    // (or an app.json manifest). Prefer the shallowest such index.html.
    String? bundleRoot;
    for (final n in names) {
      if (p.basename(n) != 'index.html') continue;
      final dir = _dir(n);
      final hasEngine = names.any((m) =>
          m.startsWith('${dir}shinylive/') || m == '${dir}app.json');
      if (hasEngine) {
        if (bundleRoot == null || dir.length < bundleRoot.length) bundleRoot = dir;
      }
    }
    if (bundleRoot != null) {
      return ImportDecision(ImportKind.shinyliveBundle, bundleRoot);
    }

    // Raw source: app.R, or ui.R + server.R in the same directory. Shallowest.
    String? rawRoot;
    for (final n in names) {
      final base = p.basename(n).toLowerCase();
      final dir = _dir(n);
      final isApp = base == 'app.r';
      final isPair = base == 'ui.r' &&
          names.any((m) => _dir(m) == dir && p.basename(m).toLowerCase() == 'server.r');
      if (isApp || isPair) {
        if (rawRoot == null || dir.length < rawRoot.length) rawRoot = dir;
      }
    }
    if (rawRoot != null) {
      return ImportDecision(ImportKind.rawSource, rawRoot);
    }

    return const ImportDecision(ImportKind.unknown, '');
  }

  /// Directory portion of an entry path, '' for root, else with trailing '/'.
  static String _dir(String name) {
    final i = name.lastIndexOf('/');
    return i < 0 ? '' : name.substring(0, i + 1);
  }

  /// Text-source extensions kept as `type:text` in a shinylive app.json.
  static bool isTextSource(String name) {
    final ext = p.extension(name).toLowerCase();
    return const {
      '.r', '.rmd', '.qmd', '.csv', '.txt', '.json', '.html', '.htm', '.css',
      '.js', '.md', '.svg', '.tsv', '.yaml', '.yml',
    }.contains(ext);
  }
}
