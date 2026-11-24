// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get libraryTitle => 'Établi Vitrine';

  @override
  String get librarySettings => 'Einstellungen';

  @override
  String get libraryImport => 'Importieren';

  @override
  String libraryLoadFailed(String detail) {
    return 'Die Bibliothek konnte nicht geladen werden:\n$detail';
  }

  @override
  String get importSheetTitle => 'IMPORTIEREN';

  @override
  String get importFromFiles => 'Aus Dateien auf dem Gerät';

  @override
  String get importFromFilesHint =>
      'Ein shinylive-.zip oder app.R / ui.R + server.R';

  @override
  String get importFromUrl => 'Von einer URL';

  @override
  String get importFromUrlHint =>
      'Ein .zip laden (shinylive-Bundle oder Quelltext)';

  @override
  String get importSampleShinylive => 'Beispiel: shinylive-App';

  @override
  String get importSampleShinyliveHint => 'Mitgelieferte Demo – läuft offline';

  @override
  String get importSampleRaw => 'Beispiel: R-Quelltext-App';

  @override
  String get importSampleRawHint =>
      'app.R wird bereitgestellt und mit WebR ausgeführt';

  @override
  String get importUrlTitle => 'Von URL importieren';

  @override
  String get importing => 'Wird importiert …';

  @override
  String get imported => 'Importiert.';

  @override
  String importFailed(String detail) {
    return 'Import fehlgeschlagen: $detail';
  }

  @override
  String get importDefaultName => 'Importierte App';

  @override
  String get importSharedName => 'Geteilte App';

  @override
  String get importSampleName => 'Beispiel (shinylive)';

  @override
  String get importSampleRawName => 'R-Quelltext-Beispiel';

  @override
  String get emptyTitle => 'Die Vitrine ist leer';

  @override
  String get emptyBody =>
      'Importiere eine Shiny-App, um sie offline auszuführen.';

  @override
  String get tagOnlineOnly => 'Nur online';

  @override
  String get appDetails => 'Details';

  @override
  String appDetailsFor(String name) {
    return 'Details zu $name';
  }

  @override
  String get appRename => 'Umbenennen';

  @override
  String get appNameHint => 'App-Name';

  @override
  String get appDeleteTitle => 'App löschen?';

  @override
  String appDeleteBody(String name) {
    return '„$name“ und die bereitgestellten Dateien entfernen? Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get appLaunchOffline => 'Starten (offline)';

  @override
  String get appOpenOnline => 'Öffnen (online)';

  @override
  String get appImported => 'Importiert';

  @override
  String get appLastRun => 'Zuletzt';

  @override
  String get appLastRunFull => 'Zuletzt ausgeführt';

  @override
  String get appNever => 'Nie';

  @override
  String get appSource => 'Quelle';

  @override
  String get appResolveFailed =>
      'Die Pakete dieser App konnten nicht aufgelöst werden.';

  @override
  String get appPackagesMaybeMissing =>
      'Einige Pakete sind eventuell nicht verfügbar.';

  @override
  String resolutionNotBundled(String packages) {
    return 'Nicht mitgeliefert (braucht beim Start eine Verbindung): $packages';
  }

  @override
  String get launchResolutionFailed => 'Auflösung fehlgeschlagen';

  @override
  String get launchPackageWarnings => 'Paketwarnungen';

  @override
  String launchAnywayBody(String detail) {
    return '$detail\n\nTrotzdem starten? Fehlende Pakete bräuchten beim Start eine Verbindung.';
  }

  @override
  String get launchAnyway => 'Trotzdem starten';

  @override
  String get sourceShinylive => 'Shinylive-Bundle';

  @override
  String get sourceRaw => 'Shiny-Quelltext';

  @override
  String get sourcePackage => 'Paket-App';

  @override
  String get sourceLiveUrl => 'Live-URL';

  @override
  String get statePending => 'Ausstehend';

  @override
  String get stateReady => 'Bereit';

  @override
  String get stateWarnings => 'Warnungen';

  @override
  String get stateFailed => 'Fehlgeschlagen';

  @override
  String get stateNotApplicable => '–';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAppearance => 'DARSTELLUNG';

  @override
  String get settingsRuntime => 'LAUFZEIT';

  @override
  String get settingsAbout => 'ÜBER';

  @override
  String get settingsWebrConsole => 'WebR-Konsole';

  @override
  String settingsWebrConsoleHint(String version) {
    return 'Offline-R-$version-REPL – Starttest';
  }

  @override
  String get settingsAboutBody => 'Offline-Ausführung von Shiny-Apps.';

  @override
  String get settingsLicenses => 'Open-Source-Lizenzen';

  @override
  String get settingsLanguage => 'App-Sprache';

  @override
  String get settingsMode => 'Modus';

  @override
  String get modeSystem => 'System';

  @override
  String get modeLight => 'Hell';

  @override
  String get modeDark => 'Dunkel';

  @override
  String get languageSystem => 'System';

  @override
  String get settingsAccent => 'Akzentfarbe';

  @override
  String get accentCoderBlue => 'Coder-Blau';

  @override
  String get accentGreen => 'Grün';

  @override
  String get accentYellow => 'Gelb';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentRed => 'Rot';

  @override
  String get accentPurple => 'Violett';

  @override
  String get accentGraphite => 'Graphit';

  @override
  String get settingsAppearanceNote =>
      'Sprache, Modus und Akzentfarbe gelten sofort. Voreinstellung: Hugo-Coder-Palette.';

  @override
  String get consoleTitle => 'WebR-Konsole';

  @override
  String get consoleUnpacking => 'WebR-Laufzeit wird entpackt …';

  @override
  String consoleFailed(String detail) {
    return 'WebR konnte nicht starten:\n\n$detail';
  }

  @override
  String get consoleLive => '● R-Sitzung aktiv (offline)';

  @override
  String get consoleStarting => '○ startet …';

  @override
  String get consoleStatusBooting => '○ startet';

  @override
  String runnerFailed(String detail) {
    return 'Start fehlgeschlagen:\n\n$detail';
  }

  @override
  String get runnerAppJsonMissing =>
      'Die bereitgestellte app.json fehlt – importiere diese App erneut.';

  @override
  String get runnerFilesMissing =>
      'Die bereitgestellten Dateien fehlen – importiere diese App erneut.';

  @override
  String get webConsolePlaceholder => 'WebR startet …';

  @override
  String webConsoleBooting(String version, String rVersion) {
    return 'WebR $version (R $rVersion) startet – offline …';
  }

  @override
  String get webConsolePlatform => 'Plattform:';

  @override
  String get webConsoleChannel => 'Kanal:';

  @override
  String get webConsoleIsolated => 'SharedArrayBuffer (Cross-Origin-isoliert)';

  @override
  String get webConsoleNotIsolated => 'PostMessage (ohne Isolierung)';

  @override
  String get webConsoleReady => 'WebR ist bereit. Gib unten R-Ausdrücke ein.';

  @override
  String get webConsoleInitError => 'Startfehler:';

  @override
  String get shareReadFailed =>
      'Die geteilten Dateien konnten nicht gelesen werden. Versuche es erneut über „Dateien“.';

  @override
  String get shareReceiveFailed =>
      'Die Freigabe konnte nicht empfangen werden. Versuche es erneut über „Dateien“.';

  @override
  String shareImportFailed(String path) {
    return '$path konnte nicht importiert werden. Verwende ein lesbares .zip oder app.R (oder ui.R mit server.R) innerhalb der Importgrenze. Die Quelldateien bleiben unverändert.';
  }

  @override
  String get shareSourcesFailed =>
      'Die geteilten R-Quellen konnten nicht importiert werden. Füge app.R oder ui.R und server.R bei. Die Quelldateien bleiben unverändert.';

  @override
  String get errorSizeLimit => 'Der Import überschreitet die Größengrenze.';

  @override
  String get errorNotZip => 'Kein gültiges ZIP-Archiv.';

  @override
  String get errorNotShinyApp =>
      'Keine erkannte Shiny-App und kein shinylive-Bundle.';

  @override
  String get errorSourcesLimit =>
      'Die Quelldateien überschreiten die Importgrenze.';

  @override
  String get errorNoAppR =>
      'Im Quelltext wurde keine app.R (oder ui.R + server.R) gefunden.';

  @override
  String get errorUrlScheme => 'Gib eine HTTP- oder HTTPS-URL ein.';

  @override
  String errorHttpStatus(String status) {
    return 'Download fehlgeschlagen (HTTP $status).';
  }

  @override
  String get errorArchiveUnsafe =>
      'Das Archiv enthält unsichere oder doppelte Pfade.';

  @override
  String get errorArchiveLinks =>
      'Archive und bereitgestellte Apps dürfen keine symbolischen Links enthalten.';

  @override
  String get errorArchiveEmpty => 'Das Archiv enthält keine App-Dateien.';

  @override
  String get errorRuntimeIncomplete =>
      'Die mitgelieferte Laufzeitumgebung ist unvollständig.';

  @override
  String get errorTimeout => 'Der Download hat zu lange gedauert.';

  @override
  String get errorNetwork =>
      'Der Download ist fehlgeschlagen. Prüfe die Verbindung und die URL.';
}
