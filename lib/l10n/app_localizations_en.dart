// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get libraryTitle => 'Établi Vitrine';

  @override
  String get librarySettings => 'Settings';

  @override
  String get libraryImport => 'Import';

  @override
  String libraryLoadFailed(String detail) {
    return 'Failed to load library:\n$detail';
  }

  @override
  String get importSheetTitle => 'IMPORT';

  @override
  String get importFromFiles => 'From device files';

  @override
  String get importFromFilesHint =>
      'A shinylive .zip, or app.R / ui.R + server.R';

  @override
  String get importFromUrl => 'From URL';

  @override
  String get importFromUrlHint =>
      'Download a .zip (shinylive bundle or source)';

  @override
  String get importSampleShinylive => 'Sample shinylive app';

  @override
  String get importSampleShinyliveHint => 'Bundled demo — runs offline';

  @override
  String get importSampleRaw => 'Sample raw R app';

  @override
  String get importSampleRawHint => 'Raw app.R staged + run via WebR';

  @override
  String get importUrlTitle => 'Import from URL';

  @override
  String get importing => 'Importing…';

  @override
  String get imported => 'Imported.';

  @override
  String importFailed(String detail) {
    return 'Import failed: $detail';
  }

  @override
  String get importDefaultName => 'Imported app';

  @override
  String get importSharedName => 'Shared app';

  @override
  String get importSampleName => 'Sample (shinylive)';

  @override
  String get importSampleRawName => 'Raw R sample';

  @override
  String get emptyTitle => 'The display case is empty';

  @override
  String get emptyBody => 'Import a Shiny app to run it offline.';

  @override
  String get tagOnlineOnly => 'Online only';

  @override
  String get appDetails => 'Details';

  @override
  String appDetailsFor(String name) {
    return 'Details for $name';
  }

  @override
  String get appRename => 'Rename';

  @override
  String get appNameHint => 'App name';

  @override
  String get appDeleteTitle => 'Delete app?';

  @override
  String appDeleteBody(String name) {
    return 'Remove “$name” and its staged files? This cannot be undone.';
  }

  @override
  String get appLaunchOffline => 'Launch (offline)';

  @override
  String get appOpenOnline => 'Open (online)';

  @override
  String get appImported => 'Imported';

  @override
  String get appLastRun => 'Last run';

  @override
  String get appLastRunFull => 'Last run';

  @override
  String get appNever => 'Never';

  @override
  String get appSource => 'Source';

  @override
  String get appResolveFailed => 'This app failed to resolve.';

  @override
  String get appPackagesMaybeMissing => 'Some packages may be unavailable.';

  @override
  String resolutionNotBundled(String packages) {
    return 'Not bundled (needs a connection at launch): $packages';
  }

  @override
  String get launchResolutionFailed => 'Resolution failed';

  @override
  String get launchPackageWarnings => 'Package warnings';

  @override
  String launchAnywayBody(String detail) {
    return '$detail\n\nLaunch anyway? Missing packages would need a connection at launch.';
  }

  @override
  String get launchAnyway => 'Launch anyway';

  @override
  String get sourceShinylive => 'Shinylive bundle';

  @override
  String get sourceRaw => 'Raw Shiny source';

  @override
  String get sourcePackage => 'Package app';

  @override
  String get sourceLiveUrl => 'Live URL';

  @override
  String get statePending => 'Pending';

  @override
  String get stateReady => 'Ready';

  @override
  String get stateWarnings => 'Warnings';

  @override
  String get stateFailed => 'Failed';

  @override
  String get stateNotApplicable => 'N/A';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'APPEARANCE';

  @override
  String get settingsRuntime => 'RUNTIME';

  @override
  String get settingsAbout => 'ABOUT';

  @override
  String get settingsWebrConsole => 'WebR Console';

  @override
  String settingsWebrConsoleHint(String version) {
    return 'Offline R $version REPL — boot test';
  }

  @override
  String get settingsAboutBody => 'Offline Shiny app runner.';

  @override
  String get settingsLicenses => 'Open-source licenses';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get settingsMode => 'Mode';

  @override
  String get modeSystem => 'System';

  @override
  String get modeLight => 'Light';

  @override
  String get modeDark => 'Dark';

  @override
  String get languageSystem => 'System';

  @override
  String get settingsAccent => 'Accent colour';

  @override
  String get accentCoderBlue => 'Coder blue';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentYellow => 'Yellow';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentRed => 'Red';

  @override
  String get accentPurple => 'Purple';

  @override
  String get accentGraphite => 'Graphite';

  @override
  String get settingsAppearanceNote =>
      'Language, mode and accent colour apply at once. Default: Hugo Coder palette.';

  @override
  String get consoleTitle => 'WebR Console';

  @override
  String get consoleUnpacking => 'Unpacking WebR runtime…';

  @override
  String consoleFailed(String detail) {
    return 'WebR failed to start:\n\n$detail';
  }

  @override
  String get consoleLive => '● R session live (offline)';

  @override
  String get consoleStarting => '○ starting…';

  @override
  String get consoleStatusBooting => '○ booting';

  @override
  String runnerFailed(String detail) {
    return 'Failed to launch:\n\n$detail';
  }

  @override
  String get runnerAppJsonMissing =>
      'Staged app.json is missing — re-import this app.';

  @override
  String get runnerFilesMissing =>
      'Staged files are missing — re-import this app.';

  @override
  String get webConsolePlaceholder => 'starting WebR…';

  @override
  String webConsoleBooting(String version, String rVersion) {
    return 'Booting WebR $version (R $rVersion) — offline…';
  }

  @override
  String get webConsolePlatform => 'Platform:';

  @override
  String get webConsoleChannel => 'Channel:';

  @override
  String get webConsoleIsolated => 'SharedArrayBuffer (cross-origin isolated)';

  @override
  String get webConsoleNotIsolated => 'PostMessage (no isolation)';

  @override
  String get webConsoleReady => 'WebR is ready. Type R expressions below.';

  @override
  String get webConsoleInitError => 'Init error:';

  @override
  String get shareReadFailed =>
      'Could not read the shared files. Retry from Files.';

  @override
  String get shareReceiveFailed =>
      'Could not receive the share. Retry from Files.';

  @override
  String shareImportFailed(String path) {
    return 'Could not import $path. Use a readable .zip or app.R (or ui.R with server.R) within the import limit. Source files are unchanged.';
  }

  @override
  String get shareSourcesFailed =>
      'Could not import the shared R sources. Include app.R, or both ui.R and server.R. Source files are unchanged.';

  @override
  String get errorSizeLimit => 'Import exceeds the size limit.';

  @override
  String get errorNotZip => 'Not a valid zip archive.';

  @override
  String get errorNotShinyApp =>
      'Not a recognized Shiny app or shinylive bundle.';

  @override
  String get errorSourcesLimit => 'Source files exceed the import limit.';

  @override
  String get errorNoAppR =>
      'No app.R (or ui.R + server.R) found in the source.';

  @override
  String get errorUrlScheme => 'Enter an HTTP or HTTPS URL.';

  @override
  String errorHttpStatus(String status) {
    return 'Download failed (HTTP $status).';
  }

  @override
  String get errorArchiveUnsafe =>
      'The archive contains unsafe or duplicate paths.';

  @override
  String get errorArchiveLinks =>
      'Archives and staged apps cannot contain symbolic links.';

  @override
  String get errorArchiveEmpty => 'The archive contains no app files.';

  @override
  String get errorRuntimeIncomplete => 'The bundled runtime is incomplete.';

  @override
  String get errorTimeout => 'The download timed out.';

  @override
  String get errorNetwork =>
      'The download failed. Check the connection and the URL.';
}
