/// How an app entered the display case. Drives staging/run behavior and
/// what offline guarantees Vitrine can make for it.
enum SourceType {
  /// Already-exported shinylive bundle. Always offline-capable.
  shinyliveZip,

  /// Raw Shiny source (app.R or ui.R+server.R). Staged + package-resolved.
  rawSource,

  /// R package shipping an app under inst/ (stretch).
  packageApp,

  /// Live hosted Shiny URL. Online-only — never offline-capable.
  liveUrl;

  String get label => switch (this) {
        SourceType.shinyliveZip => 'Shinylive bundle',
        SourceType.rawSource => 'Raw Shiny source',
        SourceType.packageApp => 'Package app',
        SourceType.liveUrl => 'Live URL',
      };

  /// Whether this source type can run without a network connection.
  bool get isOfflineCapable => this != SourceType.liveUrl;
}
