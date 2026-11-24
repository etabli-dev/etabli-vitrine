# Changelog

## Unreleased

### Added

- Settings → Appearance: the app language (System / Deutsch / English), the mode (System / Light / Dark)
  and an accent colour (Coder blue, Green, Yellow, Orange, Red, Purple, Graphite), the same keys, values and
  order as the other Établi apps. All three apply at once and are stored under `app.language`,
  `appearance.mode` and `appearance.accent`; unknown stored values fall back to System and Coder blue. The
  earlier `vitrine.themeMode` setting carries over.
- German translation of every screen, sheet, dialog, import error, share message, the WebR console page and
  the accessibility labels (`lib/l10n/app_de.arb`); dates follow the chosen language. English stays the
  fallback for other device languages.
- `integration_test/tour_test.dart`: a screenshot tour of the library, import sheet, dialogs, app details,
  the running sample app, settings and the WebR console in English and German.

### Changed

- Colours follow the Hugo Coder palette (background #FAFAFA / #212121, text #212121 / #DADADA, surface
  #E0E0E0 / #424242) with Coder blue as the default accent instead of the fixed green; the WebR console
  page uses the same dark neutrals and the chosen accent. Selection fills of the yellow and orange accents
  are neutral grey, so no background is tinted yellow.
- Labels never wrap or truncate on a 375-pt iPhone in either language.
- The bundled JetBrains Mono font is now actually used (the theme named a family that did not exist, so
  iOS fell back to a proportional font).
- Removed three stray editor temp files (`*.dart.tmp.*`) that came in with the source import.
