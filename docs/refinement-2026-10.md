# October–November 2026 refinement

## Purpose and acceptance criteria

Import and run R Shiny apps locally, including the bundled examples. Preserve existing user data. A clean checkout must prepare pinned runtimes, pass analysis and meaningful tests, and build an Android APK. Exercise the runtime in a browser with external network requests blocked, then retain physical-device/WebView and iOS checks as explicit gates.

## Confirmed findings and plan

1. **Release blocker — runtimes absent.** `tool/fetch_runtimes.sh` only created empty directories and printed a false checksum-verification message. Replace it with pinned downloads, SHA-256 checks, safe extraction and complete asset packaging. Validate the actual bundled kernels and sample apps.
2. **High — data integrity.** Archive import deletes an existing staging directory before validation, skips malicious paths silently, and has no expanded-size limit. URL downloads buffer the whole response before enforcing their size limit. Add confinement and regression tests before exposing imported data to the runtime.
3. **Medium — provenance and reproducibility.** `THIRD_PARTY.md` has version placeholders and incorrectly describes the WebR binary license. Record actual versions, source URLs, binary checksums and upstream notices. Refresh the Flutter lockfile against the tested SDK and add CI.

## Baseline evidence

Flutter 3.47.9 / Dart 3.13.7. Frozen dependency resolution initially failed against this SDK; a normal resolution followed by a frozen install passed. Analysis failed for the absent assets/webr directory; 13 tests passed, without executing a Shiny app. No Xcode installation is available, so iOS compilation cannot be claimed.

## Implementation and verification

Completed local milestones:

- ZIP/source imports validate paths, duplicates, expanded sizes and entrypoints before replacement; downloads enforce streaming bounds and deadlines. Failed library persistence removes only newly staged assets. Runtime installation is versioned, single-flight and checks required files; failed upgrades retain the prior installation. Share imports preserve multi-file R apps, bound reads, serialize deliveries and report failures. The real Shiny sample responds to controls and renders a histogram without external networking.
- Pinned runtime preparation verifies SHA-256, rejects unsafe extraction, caches inputs and produces deterministic assets. Three preparation regression tests pass.
- Flutter **27 tests pass**, analyzer passes, and the arm64 Android debug APK builds. Frozen dependency resolution passes with Flutter 3.47.9. The local browser smoke journey passes with external requests blocked; captured output was visually inspected.
- CI repeats installation, asset preparation, analysis, tests, runtime exercise and Android packaging. Local verification does not establish the remote CI result; inspect workflow runs for the source commit.
- OSV checked the exact resolved Pub package/version pairs for the three Flutter repositories on 2026-10-30: no matching advisories in 206 distinct pairs. This query does not audit the bundled native/WebAssembly dependencies or prove absence of vulnerabilities.

Raw suite receipts: `vitrine-share-check-r2, vitrine-analyze-final-r2, vitrine-runtime-final, vitrine-android-final, vitrine-runtime-preparation-tests` in `.refinement/2026-10-30/logs/`. First-use prerequisites and commands are in [README](https://github.com/etabli-dev/etabli-vitrine/blob/main/README.md).

The host test, offline browser runtime and Android packaging gates are satisfied. The scoped November 2 Android WebView rendering/reactivity result is recorded below. Broader physical-device lifecycle/share-sheet behavior, full iOS compilation and signed distribution remain separate gates. The F-Droid draft is explicitly disabled; neither its old tag nor binary-runtime downloads constitute a completed source-build recipe. Before distribution, provide the corresponding GPL runtime source and tested source-build instructions, select the approved version/signing plan, then exercise upgrades and offline operation on devices. No signed application release or store submission occurred.

## Deferred work

Additional kernels, collaborative editing and new server-backed features are outside this repair release. Store acceptance and F-Droid approval require external review; a successful local build is not evidence of acceptance.

### Share import review

Confirmed: the OS-share listener read entire files without an input bound, imported each R source independently and swallowed failures. Serialize deliveries, bound streamed input before allocation grows, import multi-file R sources together, and report failures through the application messenger. Verify grouped sources, missing/oversized inputs and unchanged source files with focused tests. Device share-sheet entitlement/intent delivery remains an external gate.

The tested AGP 8.13.2 / Gradle 8.14.3 combination builds, but Flutter warns about a future minimum of AGP 9.0.1 / Gradle 9.1.0. Schedule that supported-toolchain migration before upgrading Flutter again.

## Android emulator preparation review

Confirmed: the Dart share listener groups ui.R/server.R, but Android declared only single-file SEND. Add SEND_MULTIPLE with the supported MIME types so the OS can dispatch a multi-file share to that existing importer; validate the packaged intent filter on the emulator.

Confirmed: the Shiny runner bound its loopback server before saving last-run metadata, then transferred ownership only after that write. A database failure leaked the listening socket. Keep ownership local until startup succeeds and dispose it on every startup failure. Exercise the actual runner with an injected metadata failure and verify that its bound port can be reused.

Verification: `vitrine-runtime-tests` passed all 27 Flutter tests and `vitrine-runtime-analyze` found no issues. The new regression injects a last-run metadata failure through the production runner and confirms its real bound port can immediately be reused. Grouped-source share tests also pass. Android intent resolution remains an emulator check.

Final local build receipt `vitrine-android-runtime-review` completed with exit 0 on 2026-10-30 and produced the arm64 debug APK. SHA-256: `c425e91075b62562c4a17db08a322205c5d5347766f1936583e8c1471c95537b`. The socket regression and 27-test suite verify local behavior; actual Android Shiny rendering, import persistence and share intent delivery still require the device journeys. The publication-wording documentation render also passed; the suite link check found no missing targets across 12 sites and 156 generated pages.

### Published CI outcome — 2026-10-31

Published source commit `2dd7c9a6dd54cbd84ee0c934cc380104313742a3` passed [application CI](https://github.com/etabli-dev/etabli-vitrine/actions/runs/41200149672), including frozen dependency resolution, runtime preparation, analysis, all 27 Flutter tests, the offline browser Shiny journey and Android APK packaging. The [documentation Pages build/deployment](https://github.com/etabli-dev/etabli-vitrine/actions/runs/41200149679) also passed. These are observed remote results for that source commit, separate from the local checks above.

The runtime journey ran in a browser; it does not establish Android WebView execution. Android runtime/device acceptance and full iOS compilation remain open, as do signing and store acceptance. The unsuccessful Android attempt is retained below.

### Android device attempt — 2026-10-31

The final APK installed successfully on the local API 35 arm64 emulator (4 KiB pages). The planned Vitrine UI journey was not reached: the preceding Flutter startup stalled, and a bounded retry after stopping the separate test emulator and idle build JVMs still produced a black screenshot and a null accessibility root. Android logged system-wide `DeadSystemException` failures, including System UI and the keyboard, with system-server watchdog/lock contention during recovery. No Vitrine runtime defect can be inferred from that environment failure.

Actual Android sample rendering, control interaction, import persistence, SEND_MULTIPLE resolution and share-sheet delivery remain unverified. The 27 passing Flutter tests, real socket cleanup regression and browser Shiny smoke are the observed behavior checks. Repeat the prepared sample/import/share journeys on a responsive emulator or physical device before claiming Android runtime acceptance; API 36/16 KiB device execution and iOS remain unverified. Installation and attempt evidence is in the suite's `.refinement/2026-10-30/android-local/` (`api35-installs.json`, `flutter-api35-first-attempt.json`, `flutter-api35-retry.json`, `flutter-api35-system-failure.log`); `FLUTTER_JOURNEYS.md` contains the next steps.

## Runtime artifact distribution review — 2026-11-02

Confirmed: application CI uploaded debug APKs containing GPL-licensed WebR binaries while complete corresponding-source delivery for the bundled runtime and R package image remained unverified. Pinned binary hashes and source-tag links do not close that distribution gate. Preserve all preparation, analysis, unit/runtime tests and APK-build checks; retain screenshots and preparation receipts, and pause automatic APK uploads until matching source materials and delivery instructions have been checked. Historical artifacts/releases are preserved and are not retroactively described as source-verified. Corresponding-source preparation and the disabled F-Droid recipe are deferred maintainer work, not an unavailable account or device prerequisite.

### Installed Android Shiny journey — 2026-11-02

The debug APK, SHA-256 `c425e91075b62562c4a17db08a322205c5d5347766f1936583e8c1471c95537b`, passed a scoped actual API 35 ARM64/4 KiB emulator journey with guest external networking disabled. Importing the bundled sample produced a persistent library entry and rendered the real Shiny application in Android WebView. Changing Variable from `mpg` to `cyl` updated the histogram to counts 11/7/14 at 4/6/8 and the summary to median 6, mean 6.188. The library entry survived force-stop/relaunch and the runtime rendered again offline. Runtime input selection started again at default `mpg`; the persisted object was the library entry.

Android resolved SEND_MULTIPLE with text/plain to Vitrine's MainActivity. That checks installed intent routing, **not actual incoming multi-file share delivery**. UIAutomator exposed the Flutter toolbar but not embedded HTML nodes; the actual HTML controls were operated from fresh inspected screenshots. Initial loading completed within the bounded observation sequence. The earlier October 31 system failure remains separate historical evidence.

Screenshots, hierarchies, process logs, routing output and the exact install receipt are retained in `.refinement/2026-10-30/android-local/games-flutter-20261102-pass1/` (`vitrine-result.json`, `vitrine-send-multiple-routing.txt`, `RESULTS.md`) in the suite workspace. The scoped Android WebView rendering, reactivity and import-persistence checks are now observed. Actual share-sheet delivery, broader lifecycle/accessibility, physical-device and 16 KiB execution, full iOS compilation, corresponding-source delivery and signed distribution remain open.
