import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Établi Vitrine'**
  String get libraryTitle;

  /// No description provided for @librarySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get librarySettings;

  /// No description provided for @libraryImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get libraryImport;

  /// No description provided for @libraryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load library:\n{detail}'**
  String libraryLoadFailed(String detail);

  /// No description provided for @importSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'IMPORT'**
  String get importSheetTitle;

  /// No description provided for @importFromFiles.
  ///
  /// In en, this message translates to:
  /// **'From device files'**
  String get importFromFiles;

  /// No description provided for @importFromFilesHint.
  ///
  /// In en, this message translates to:
  /// **'A shinylive .zip, or app.R / ui.R + server.R'**
  String get importFromFilesHint;

  /// No description provided for @importFromUrl.
  ///
  /// In en, this message translates to:
  /// **'From URL'**
  String get importFromUrl;

  /// No description provided for @importFromUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Download a .zip (shinylive bundle or source)'**
  String get importFromUrlHint;

  /// No description provided for @importSampleShinylive.
  ///
  /// In en, this message translates to:
  /// **'Sample shinylive app'**
  String get importSampleShinylive;

  /// No description provided for @importSampleShinyliveHint.
  ///
  /// In en, this message translates to:
  /// **'Bundled demo — runs offline'**
  String get importSampleShinyliveHint;

  /// No description provided for @importSampleRaw.
  ///
  /// In en, this message translates to:
  /// **'Sample raw R app'**
  String get importSampleRaw;

  /// No description provided for @importSampleRawHint.
  ///
  /// In en, this message translates to:
  /// **'Raw app.R staged + run via WebR'**
  String get importSampleRawHint;

  /// No description provided for @importUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from URL'**
  String get importUrlTitle;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importing;

  /// No description provided for @imported.
  ///
  /// In en, this message translates to:
  /// **'Imported.'**
  String get imported;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {detail}'**
  String importFailed(String detail);

  /// No description provided for @importDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Imported app'**
  String get importDefaultName;

  /// No description provided for @importSharedName.
  ///
  /// In en, this message translates to:
  /// **'Shared app'**
  String get importSharedName;

  /// No description provided for @importSampleName.
  ///
  /// In en, this message translates to:
  /// **'Sample (shinylive)'**
  String get importSampleName;

  /// No description provided for @importSampleRawName.
  ///
  /// In en, this message translates to:
  /// **'Raw R sample'**
  String get importSampleRawName;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'The display case is empty'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Import a Shiny app to run it offline.'**
  String get emptyBody;

  /// No description provided for @tagOnlineOnly.
  ///
  /// In en, this message translates to:
  /// **'Online only'**
  String get tagOnlineOnly;

  /// No description provided for @appDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get appDetails;

  /// No description provided for @appDetailsFor.
  ///
  /// In en, this message translates to:
  /// **'Details for {name}'**
  String appDetailsFor(String name);

  /// No description provided for @appRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get appRename;

  /// No description provided for @appNameHint.
  ///
  /// In en, this message translates to:
  /// **'App name'**
  String get appNameHint;

  /// No description provided for @appDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete app?'**
  String get appDeleteTitle;

  /// No description provided for @appDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Remove “{name}” and its staged files? This cannot be undone.'**
  String appDeleteBody(String name);

  /// No description provided for @appLaunchOffline.
  ///
  /// In en, this message translates to:
  /// **'Launch (offline)'**
  String get appLaunchOffline;

  /// No description provided for @appOpenOnline.
  ///
  /// In en, this message translates to:
  /// **'Open (online)'**
  String get appOpenOnline;

  /// No description provided for @appImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get appImported;

  /// No description provided for @appLastRun.
  ///
  /// In en, this message translates to:
  /// **'Last run'**
  String get appLastRun;

  /// No description provided for @appLastRunFull.
  ///
  /// In en, this message translates to:
  /// **'Last run'**
  String get appLastRunFull;

  /// No description provided for @appNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get appNever;

  /// No description provided for @appSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get appSource;

  /// No description provided for @appResolveFailed.
  ///
  /// In en, this message translates to:
  /// **'This app failed to resolve.'**
  String get appResolveFailed;

  /// No description provided for @appPackagesMaybeMissing.
  ///
  /// In en, this message translates to:
  /// **'Some packages may be unavailable.'**
  String get appPackagesMaybeMissing;

  /// No description provided for @resolutionNotBundled.
  ///
  /// In en, this message translates to:
  /// **'Not bundled (needs a connection at launch): {packages}'**
  String resolutionNotBundled(String packages);

  /// No description provided for @launchResolutionFailed.
  ///
  /// In en, this message translates to:
  /// **'Resolution failed'**
  String get launchResolutionFailed;

  /// No description provided for @launchPackageWarnings.
  ///
  /// In en, this message translates to:
  /// **'Package warnings'**
  String get launchPackageWarnings;

  /// No description provided for @launchAnywayBody.
  ///
  /// In en, this message translates to:
  /// **'{detail}\n\nLaunch anyway? Missing packages would need a connection at launch.'**
  String launchAnywayBody(String detail);

  /// No description provided for @launchAnyway.
  ///
  /// In en, this message translates to:
  /// **'Launch anyway'**
  String get launchAnyway;

  /// No description provided for @sourceShinylive.
  ///
  /// In en, this message translates to:
  /// **'Shinylive bundle'**
  String get sourceShinylive;

  /// No description provided for @sourceRaw.
  ///
  /// In en, this message translates to:
  /// **'Raw Shiny source'**
  String get sourceRaw;

  /// No description provided for @sourcePackage.
  ///
  /// In en, this message translates to:
  /// **'Package app'**
  String get sourcePackage;

  /// No description provided for @sourceLiveUrl.
  ///
  /// In en, this message translates to:
  /// **'Live URL'**
  String get sourceLiveUrl;

  /// No description provided for @statePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statePending;

  /// No description provided for @stateReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get stateReady;

  /// No description provided for @stateWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get stateWarnings;

  /// No description provided for @stateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get stateFailed;

  /// No description provided for @stateNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get stateNotApplicable;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settingsAppearance;

  /// No description provided for @settingsRuntime.
  ///
  /// In en, this message translates to:
  /// **'RUNTIME'**
  String get settingsRuntime;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsAbout;

  /// No description provided for @settingsWebrConsole.
  ///
  /// In en, this message translates to:
  /// **'WebR Console'**
  String get settingsWebrConsole;

  /// No description provided for @settingsWebrConsoleHint.
  ///
  /// In en, this message translates to:
  /// **'Offline R {version} REPL — boot test'**
  String settingsWebrConsoleHint(String version);

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'Offline Shiny app runner.'**
  String get settingsAboutBody;

  /// No description provided for @settingsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get settingsLicenses;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguage;

  /// No description provided for @settingsMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get settingsMode;

  /// No description provided for @modeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get modeSystem;

  /// No description provided for @modeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get modeLight;

  /// No description provided for @modeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get modeDark;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @settingsAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get settingsAccent;

  /// No description provided for @accentCoderBlue.
  ///
  /// In en, this message translates to:
  /// **'Coder blue'**
  String get accentCoderBlue;

  /// No description provided for @accentGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get accentGreen;

  /// No description provided for @accentYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get accentYellow;

  /// No description provided for @accentOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get accentOrange;

  /// No description provided for @accentRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get accentRed;

  /// No description provided for @accentPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get accentPurple;

  /// No description provided for @accentGraphite.
  ///
  /// In en, this message translates to:
  /// **'Graphite'**
  String get accentGraphite;

  /// No description provided for @settingsAppearanceNote.
  ///
  /// In en, this message translates to:
  /// **'Language, mode and accent colour apply at once. Default: Hugo Coder palette.'**
  String get settingsAppearanceNote;

  /// No description provided for @consoleTitle.
  ///
  /// In en, this message translates to:
  /// **'WebR Console'**
  String get consoleTitle;

  /// No description provided for @consoleUnpacking.
  ///
  /// In en, this message translates to:
  /// **'Unpacking WebR runtime…'**
  String get consoleUnpacking;

  /// No description provided for @consoleFailed.
  ///
  /// In en, this message translates to:
  /// **'WebR failed to start:\n\n{detail}'**
  String consoleFailed(String detail);

  /// No description provided for @consoleLive.
  ///
  /// In en, this message translates to:
  /// **'● R session live (offline)'**
  String get consoleLive;

  /// No description provided for @consoleStarting.
  ///
  /// In en, this message translates to:
  /// **'○ starting…'**
  String get consoleStarting;

  /// No description provided for @consoleStatusBooting.
  ///
  /// In en, this message translates to:
  /// **'○ booting'**
  String get consoleStatusBooting;

  /// No description provided for @runnerFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to launch:\n\n{detail}'**
  String runnerFailed(String detail);

  /// No description provided for @runnerAppJsonMissing.
  ///
  /// In en, this message translates to:
  /// **'Staged app.json is missing — re-import this app.'**
  String get runnerAppJsonMissing;

  /// No description provided for @runnerFilesMissing.
  ///
  /// In en, this message translates to:
  /// **'Staged files are missing — re-import this app.'**
  String get runnerFilesMissing;

  /// No description provided for @webConsolePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'starting WebR…'**
  String get webConsolePlaceholder;

  /// No description provided for @webConsoleBooting.
  ///
  /// In en, this message translates to:
  /// **'Booting WebR {version} (R {rVersion}) — offline…'**
  String webConsoleBooting(String version, String rVersion);

  /// No description provided for @webConsolePlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform:'**
  String get webConsolePlatform;

  /// No description provided for @webConsoleChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel:'**
  String get webConsoleChannel;

  /// No description provided for @webConsoleIsolated.
  ///
  /// In en, this message translates to:
  /// **'SharedArrayBuffer (cross-origin isolated)'**
  String get webConsoleIsolated;

  /// No description provided for @webConsoleNotIsolated.
  ///
  /// In en, this message translates to:
  /// **'PostMessage (no isolation)'**
  String get webConsoleNotIsolated;

  /// No description provided for @webConsoleReady.
  ///
  /// In en, this message translates to:
  /// **'WebR is ready. Type R expressions below.'**
  String get webConsoleReady;

  /// No description provided for @webConsoleInitError.
  ///
  /// In en, this message translates to:
  /// **'Init error:'**
  String get webConsoleInitError;

  /// No description provided for @shareReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the shared files. Retry from Files.'**
  String get shareReadFailed;

  /// No description provided for @shareReceiveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not receive the share. Retry from Files.'**
  String get shareReceiveFailed;

  /// No description provided for @shareImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not import {path}. Use a readable .zip or app.R (or ui.R with server.R) within the import limit. Source files are unchanged.'**
  String shareImportFailed(String path);

  /// No description provided for @shareSourcesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not import the shared R sources. Include app.R, or both ui.R and server.R. Source files are unchanged.'**
  String get shareSourcesFailed;

  /// No description provided for @errorSizeLimit.
  ///
  /// In en, this message translates to:
  /// **'Import exceeds the size limit.'**
  String get errorSizeLimit;

  /// No description provided for @errorNotZip.
  ///
  /// In en, this message translates to:
  /// **'Not a valid zip archive.'**
  String get errorNotZip;

  /// No description provided for @errorNotShinyApp.
  ///
  /// In en, this message translates to:
  /// **'Not a recognized Shiny app or shinylive bundle.'**
  String get errorNotShinyApp;

  /// No description provided for @errorSourcesLimit.
  ///
  /// In en, this message translates to:
  /// **'Source files exceed the import limit.'**
  String get errorSourcesLimit;

  /// No description provided for @errorNoAppR.
  ///
  /// In en, this message translates to:
  /// **'No app.R (or ui.R + server.R) found in the source.'**
  String get errorNoAppR;

  /// No description provided for @errorUrlScheme.
  ///
  /// In en, this message translates to:
  /// **'Enter an HTTP or HTTPS URL.'**
  String get errorUrlScheme;

  /// No description provided for @errorHttpStatus.
  ///
  /// In en, this message translates to:
  /// **'Download failed (HTTP {status}).'**
  String errorHttpStatus(String status);

  /// No description provided for @errorArchiveUnsafe.
  ///
  /// In en, this message translates to:
  /// **'The archive contains unsafe or duplicate paths.'**
  String get errorArchiveUnsafe;

  /// No description provided for @errorArchiveLinks.
  ///
  /// In en, this message translates to:
  /// **'Archives and staged apps cannot contain symbolic links.'**
  String get errorArchiveLinks;

  /// No description provided for @errorArchiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'The archive contains no app files.'**
  String get errorArchiveEmpty;

  /// No description provided for @errorRuntimeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'The bundled runtime is incomplete.'**
  String get errorRuntimeIncomplete;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The download timed out.'**
  String get errorTimeout;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'The download failed. Check the connection and the URL.'**
  String get errorNetwork;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
