# Platform roadmap

Établi Vitrine · state as of 2026-11-08 · this is a plan. Observed results stay in the
[current status page](current-status.qmd) and the [refinement record](refinement-2026-10.md);
runtime licensing and the distribution gate are in
[THIRD_PARTY.md](https://github.com/etabli-dev/etabli-vitrine/blob/main/THIRD_PARTY.md) and
[FDROID_NOTES.md](https://github.com/etabli-dev/etabli-vitrine/blob/main/FDROID_NOTES.md).

## 1. Platform role

Établi Vitrine is a **mobile-only** app for Android and iOS, **including tablets** (Android
tablets and iPad). Its point is running interactive Shiny apps on a phone or tablet without a
server: import an app once, then open it offline.

No Ubuntu/Debian, Windows or macOS application is planned. Desktops run Shiny natively with R,
and any desktop browser runs shinylive apps directly; a desktop build of Vitrine would add
maintenance without adding capability.

| Platform | Role | Used for |
|---|---|---|
| Android (phones, tablets) | release target | signed APK on GitHub Releases, Google Play, F-Droid if a source-build route is found |
| iOS / iPadOS | release target | TestFlight, then App Store, subject to decisions D4 and D5 and the M2 spike |
| Ubuntu/Debian, Windows, macOS | not planned | R with `shiny::runApp()`, RStudio or Positron, or shinylive in a browser |

## 2. Current state

| Platform | Status | Technology | How it is built | What is verified | Distribution |
|---|---|---|---|---|---|
| Android | in development | Flutter 3.47.9 / Dart 3.13.7; flutter_inappwebview 6.1.5 on Android System WebView; WebR 0.6.0 and shinylive 0.10.12; drift/SQLite, receive_sharing_intent 1.8.1, file_picker 11.0.2; AGP 8.13.2, Gradle 8.14.3. Release builds use private keystore.properties when supplied and otherwise remain unsigned | `bash tool/fetch_runtimes.sh`, then `flutter build apk --debug --target-platform android-arm64`; CI `.github/workflows/app.yml` (ubuntu-24.04) | CI on 2026-10-31 (commit `2dd7c9a`): runtime preparation, analysis, 27 Flutter tests, the offline Shiny journey in headless Chromium, APK build. Locally on an API 35 ARM64 emulator (2026-11-02, networking disabled): bundled sample imported and run in WebView, reactive update after an input change, library entry kept after restart; `SEND_MULTIPLE` resolves to the app. Not verified: actual incoming shares, a physical device, 16 KB page-size execution, release signing | GitHub Releases `v0.1.0` (2026-06-24): one APK signed with the Android debug key, built before the October–November changes; its release notes state a SHA-256 (`fa5f731d…`) that differs from the attached file (GitHub's asset digest `f9dc75ea…` matches the file). Automatic CI APK uploads are paused by the THIRD_PARTY.md source-delivery gate |
| iOS | simulator compilation verified | Flutter iOS runner, minimum iOS 15.0; WKWebView app-bound loopback domains; ZIP and `.R` document types | `flutter build ios --simulator --debug --no-codesign --no-pub`; added macOS CI job | Local unsigned simulator build, analyzer and 27 Flutter tests passed on 2026-11-08; runtime interaction and incoming shares remain device acceptance gates | none |
| Ubuntu/Debian | not planned | generated Flutter `linux/` runner; the locked flutter_inappwebview 6.1.5 has no Linux implementation and receive_sharing_intent is Android/iOS only | never built (no CI job, no recorded build) | nothing | none |
| Windows | not planned | generated Flutter `windows/` runner | never built | nothing | none |
| macOS | not planned | generated Flutter `macos/` runner | never built | nothing | none |

## 3. Architecture

**Now.** One Dart codebase in `lib/` serves every runner:

- `lib/features/import/`: ZIP, `app.R` and `ui.R` + `server.R` import from files
  (`file_picker`), URLs (`download.dart`, streaming bounds) and the system share sheet
  (`share_listener.dart`, Android and iOS only); `package_resolver.dart` reports packages that
  are not in the bundled image.
- `lib/runtime/`: staging, versioned runtime installation and `local_http_server.dart`, a
  loopback server that serves shinylive bundles plainly (shinylive's own service worker handles
  isolation) and the WebR console with COOP/COEP headers.
- `lib/features/runner/`: `shinylive_runner_page.dart` and `webr_console_page.dart` (WebViews);
  `lib/features/library/` (screens) backed by drift/SQLite in `lib/data/`.
- Runtimes are prepared by `tool/fetch_runtimes.sh` from `tool/runtimes.lock.json` and are
  identical for Android and iOS.

Platform-specific parts are only the runner folders (intent filters in
`android/app/src/main/AndroidManifest.xml`, document types and local networking in
`ios/Runner/Info.plist`) and the plugins.

**Target.** Unchanged: one Flutter codebase, Android and iOS runners as the only release
targets, desktop runner folders removed (section 4.7, recommendation). iOS gains a Share
Extension target (I5); everything else stays in `lib/`.

## 4. Per-platform execution

### 4.1 Android

Android is ahead: iOS has no feature that Android lacks. The remaining Android work is release
readiness.

| # | Item | Where it stands | Work | Accepted when |
|---|---|---|---|---|
| A1 | Release signing | `android/app/build.gradle.kts`: release build type uses `signingConfigs.getByName("debug")` | Load `android/keystore.properties` when present, as the native Établi apps do (`android/app/build.gradle.kts` in etabli-doc); keep the debug fallback only for local `flutter run --release`. `.gitignore` already excludes keystores and `keystore.properties` | The release workflow fails unless `apksigner` shows the owner's certificate |
| A2 | Corresponding-source delivery for the GPL runtime | THIRD_PARTY.md "Distribution gate": open | Collect matching sources and build scripts for every bundled runtime and package version, verify them against the binary inputs, and publish a source archive or durable source download beside every binary | THIRD_PARTY.md records the gate as closed with evidence; every release carries its source bundle |
| A3 | Release WebView hardening (both platforms) | `shinylive_runner_page.dart` and `webr_console_page.dart` set `isInspectable: true` and `MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW` unconditionally | Use `isInspectable: kDebugMode`, as Établi Atelier does in `lib/kernel/kernel_host.dart`; check whether the mixed-content override is still needed when everything is served from `http://localhost`, and drop it if not | Release build not inspectable; bundled sample and console still run |
| A4 | Incoming shares on a device | intent routing verified on the emulator only | Share a ZIP (`SEND`), `ui.R` + `server.R` together (`SEND_MULTIPLE`) and open a ZIP from a browser download (`VIEW`) on a device | Each import lands in the library once; oversized or invalid input reports an error |
| A5 | Toolchain | Flutter warns of a future minimum of AGP 9.0.1 / Gradle 9.1.0 (refinement record) | Migrate as Établi Atelier did; re-run all checks | CI green on the new toolchain |
| A6 | Release size and ABIs | the debug-signed `v0.1.0` APK is 195,980,306 bytes | Build the release AAB, measure with `bundletool get-size total`; choose ABIs (D6); if the base module exceeds Google Play's limit, move runtimes into a Play Asset Delivery install-time pack | Measured size recorded here and within the limit current at submission |
| A7 | Device coverage | API 35 ARM64 emulator, 4 KB pages | Run the journey on one physical phone, one physical or emulated tablet and a 16 KB page-size emulator image | All pass; results in `docs/current-status.qmd` |
| A8 | Repository hygiene | three tracked leftovers from the source import: `lib/features/import/import_controller.dart.tmp.55316.af5a825e6e99`, `lib/features/import/import_router.dart.tmp.55316.e38bd8a2c61b`, `test/import_router_test.dart.tmp.55316.d0f76440060c` (older copies of the real files) | Remove them in a separate commit | Analysis and tests unchanged |

**Build and run**

```sh
python3 tool/test_fetch_runtimes.py
bash tool/fetch_runtimes.sh
flutter pub get --enforce-lockfile
flutter analyze
flutter test
npm --prefix tool ci
(cd tool && npx playwright install chromium)
npm --prefix tool test
flutter build apk --debug --target-platform android-arm64
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Release candidate, after A1 and with `android/keystore.properties` in place:

```sh
flutter build appbundle --release --build-name="$VERSION" --build-number="$BUILD"
flutter build apk --release --split-per-abi --build-name="$VERSION" --build-number="$BUILD"
"$ANDROID_HOME/build-tools/35.0.0/apksigner" verify --print-certs build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
"$ANDROID_HOME/build-tools/35.0.0/zipalign" -c -P 16 -v 4 build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

**Packages and channels** (none of them before A2 is closed)

- *GitHub Releases:* signed APK per chosen ABI, the corresponding-source bundle and
  `SHA256SUMS`; the hashes in the release notes must equal GitHub's asset digests. A
  release-signed APK cannot update the debug-signed `v0.1.0` install; uninstalling removes the
  imported library, so the release notes must say so (re-import from the original files).
- *Google Play:* AAB with Play App Signing; internal testing, closed testing, production.
  Imported apps run as R code inside the WebView's WebAssembly runtime, and apps that need
  packages outside the bundled image fetch them online at launch; describe both in the review
  notes and the privacy policy. The first upload of a new app is done in Play Console.
- *F-Droid:* the disabled `.fdroid.yml` draft and FDROID_NOTES.md list the blockers: prebuilt
  WebAssembly runtimes (F-Droid's main repository builds from source), the GPL source delivery,
  version codes and signing. Treat F-Droid as the last Android channel.

**Signing prerequisites (owner):** an app signing key and an upload key per D1, kept outside
the repository with backups; a Google Play developer account (D3); privacy policy URL (D8). CI
secrets in a GitHub environment `release` with the owner as required reviewer:
`ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.

**CI**

- Keep `app.yml` as the per-push verification (APK uploads stay paused there).
- Add `.github/workflows/android-release.yml` once A1 and A2 are done: tags `v*` and
  `workflow_dispatch`; ubuntu-24.04; environment `release`; workflow `permissions: contents:
  read`, `contents: write` only on the job that creates the draft release; reuse the pinned
  `actions/checkout`, `actions/setup-java` and `subosito/flutter-action` SHAs from `app.yml`.
  Steps: prepare and verify runtimes, `flutter pub get --enforce-lockfile`, analyze, test,
  write the keystore into `$RUNNER_TEMP` and `android/keystore.properties`, build AAB and APKs,
  verify signature and 16 KB alignment, build the source bundle from A2, write `SHA256SUMS`,
  `gh release create "$GITHUB_REF_NAME" --draft` with APKs, source bundle and checksums; keep
  the AAB as a workflow artifact for Play; remove key material in an `if: always()` step.

**Acceptance criteria (Android)**

- A1–A8 closed as stated in the table.
- The installed release candidate, with networking disabled, imports the bundled sample, runs
  it, reacts to input changes, keeps the library across restart and upgrade, opens the WebR
  console, and imports shared ZIP and two-file R apps, on a phone, a tablet and a 16 KB
  page-size image.
- `apksigner` shows the owner's certificate; 16 KB alignment passes; a draft GitHub release
  contains APKs, source bundle and matching checksums.
- Play: internal-track install works; pre-launch report shows no crash; Data safety answers
  match the artifact.

### 4.2 iOS

**Feature gap: present on Android, missing or never run on iOS.**

| # | Feature | Where it exists | iOS work | Accepted when |
|---|---|---|---|---|
| I1 | The app builds for iOS | all of `lib/`, runner `ios/` | Add an `ios` job to `app.yml` on macos-15: prepare runtimes, `flutter pub get --enforce-lockfile`, `flutter build ios --release --no-codesign` | Job green |
| I2 | Shiny apps run offline in the WebView | `lib/features/runner/shinylive_runner_page.dart`, `lib/runtime/local_http_server.dart`; verified on the Android emulator | shinylive depends on a service worker. WebKit documents service workers in WKWebView only for apps that opt into App-Bound Domains (`WKAppBoundDomains` in `Info.plist`, with `limitsNavigationsToAppBoundDomains` in the WebView settings); neither is configured. Spike first: localhost as an app-bound domain, then the bundled sample | The bundled sample renders and reacts on the simulator in CI and on an iPhone; if service workers cannot be enabled, record iOS as blocked here |
| I3 | WebR console | `lib/features/runner/webr_console_page.dart` (served with COOP/COEP for SharedArrayBuffer) | Check that WKWebView reports `crossOriginIsolated` for the loopback page | `6*7` prints `[1] 42` on device |
| I4 | Import from files and URLs | `lib/features/import/` (`file_picker`, `download.dart`) | Verify the document picker and HTTPS downloads on iOS | ZIP and two-file imports land in the library |
| I5 | Import from the share sheet | Android intent filters (`SEND`, `SEND_MULTIPLE`, `VIEW`) in `android/app/src/main/AndroidManifest.xml`; Dart side `share_listener.dart` already enabled for iOS | receive_sharing_intent's iOS setup needs a Share Extension target and an App Group shared with the Runner; neither exists in `ios/`. Add both (App Group ID registered by the owner) | Sharing a ZIP, an `.R` file and two files at once from Files imports each once |
| I6 | "Open in Vitrine" from Files | `CFBundleDocumentTypes` for ZIP and `.R` and `LSSupportsOpeningDocumentsInPlace` in `ios/Runner/Info.plist` | Verify delivery under the scene lifecycle (`SceneDelegate.swift` is a plain `FlutterSceneDelegate`); because documents open in place, copy them under security-scoped access before staging | Opening a ZIP from Files imports it; the original file is unchanged |
| I7 | Library persistence | drift/SQLite in `lib/data/` | — | Library survives relaunch and a TestFlight update |
| I8 | Minimum iOS version | `ios/Podfile` and project: 13.0 | Set to the oldest iOS that passes I2/I3 | Value documented here and in the README |

**Build and run** (a Mac with Xcode, or CI on macos-15):

```sh
python3 tool/test_fetch_runtimes.py
bash tool/fetch_runtimes.sh
flutter pub get --enforce-lockfile
flutter build ios --release --no-codesign          # compile check
flutter devices && flutter run -d <simulator-id>   # local Mac only
```

Archive and upload to App Store Connect (TestFlight):

```sh
flutter build ios --release --no-codesign --build-name="$VERSION" --build-number="$BUILD"
xcodebuild archive -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'generic/platform=iOS' -archivePath build/Runner.xcarchive \
  DEVELOPMENT_TEAM="$APPLE_TEAM_ID" -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_KEY_PATH" -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID"
xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportPath build/export \
  -exportOptionsPlist "$RUNNER_TEMP/export.plist" -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_KEY_PATH" -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID"
```

`export.plist` sets `method` = `app-store-connect`, `destination` = `upload` and `teamID`; write
it at run time because `.gitignore` excludes `ExportOptions.plist`. With the Share Extension
(I5) the archive contains two signed targets; both need provisioning.

**Distribution path:** TestFlight internal testing → external TestFlight (Beta App Review) →
App Store. Before external testing, decide D4 (GPL-licensed WebR under Apple's terms) and D5
(running imported R code and fetching packages at launch, App Review guideline 2.5.2). Already
in place: `ITSAppUsesNonExemptEncryption` = false and a privacy manifest
(`ios/Runner/PrivacyInfo.xcprivacy`); check Xcode's privacy report of the archive. Listing needs
iPhone and iPad screenshots, privacy policy and support URLs, App Privacy answers and review
notes with a sample app to import.

**Signing prerequisites (owner):** Apple Developer Program membership and Team ID (D3); bundle
ID `com.raban.etabli.vitrine` plus one for the Share Extension, an App Group, and an App Store
Connect app record; an App Store Connect API team key (Key ID, Issuer ID, `.p8`) whose role may
manage signing, or additionally an Apple Distribution certificate as `.p12`. CI secrets in
environment `release`: `APPLE_TEAM_ID`, `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8_B64`, and if
needed `IOS_DIST_CERT_P12_B64`, `IOS_DIST_CERT_PASSWORD`.

**CI**

- I1 adds the `ios` compile job to `app.yml`; the I2 spike adds an `integration_test` that
  imports the bundled sample and waits for the rendered app on an iOS simulator (`xcrun simctl`
  boot, then `flutter test integration_test -d <id>`). Neither needs an Apple account.
- Add `.github/workflows/ios-release.yml` (macos-15, tags `v*` and `workflow_dispatch`,
  environment `release`, `permissions: contents: read`) after D3–D5: prepare runtimes, build,
  archive, export and upload as above; delete key material in an `if: always()` step.

**Acceptance criteria (iOS)**

- I1–I8 closed as stated in the table.
- On an iPhone and an iPad (TestFlight build), with networking off: import and run the bundled
  sample, react to input changes, keep the library across relaunch and a TestFlight update,
  open the WebR console, import from the share sheet and from Files.
- VoiceOver reaches the library, detail and runner controls; the largest Dynamic Type size
  stays usable outside the WebView.
- App Review approves the submission.

### 4.3 Tablets (Android tablets and iPad)

**Now.** No screen in `lib/` adapts to width: the library, detail and runner pages use the same
single-column layout at every size. The iPad declares all four orientations; Android does not
lock orientation. Shiny apps built with bslib are responsive themselves and benefit from the
full width.

**Target.**

- Library at expanded width (840 dp and wider): list and app detail side by side
  (`library_screen.dart` and `app_detail_screen.dart`), or a grid of app cards; one column below
  600 dp as today.
- Runner: full-width WebView with a collapsible app bar; landscape supported without reloading
  the running app.
- Hardware keyboard and pointer: Escape or Back leaves the runner; text fields and hover work
  inside the WebView.
- iPad Split View and Slide Over fall back to the phone layout; Android tablets, foldables and
  ChromeOS devices receive the app from Google Play by default, so test them or restrict them in
  Play Console's device catalog.

**Acceptance.** Widget tests for the library at 360×800, 800×1280, 1280×800 and 1366×1024
logical pixels; on one Android tablet (emulator acceptable before release) and one iPad
(TestFlight), the bundled sample uses the full width and survives rotation.

### 4.4 Ubuntu/Debian — not planned

No Linux application is planned. With R installed (`apt install r-base`, then the shiny
package), `shiny::runApp()` runs the same apps natively, in RStudio, Positron or a terminal. To
stay serverless, `shinylive::export()` turns an app into static files that any browser runs
locally, and the online shinylive editor runs apps without installing anything.

### 4.5 Windows — not planned

No Windows application is planned: R from CRAN with the shiny package, RStudio or Positron, or
shinylive in Edge, Firefox or Chrome cover the same use.

### 4.6 macOS — not planned

No macOS application is planned: R from CRAN with the shiny package, RStudio or Positron, or
shinylive in Safari or another browser. App Store Connect offers iPhone and iPad apps on Apple
silicon Macs by default; decision D10 covers whether to opt out until that is tested.

### 4.7 Existing desktop runner folders (recommendation for the owner)

`linux/`, `macos/` and `windows/` were generated by `flutter create`, came in with the source
import and have never been built or verified; on Linux the locked WebView plugin has no
implementation at all, and share import is Android/iOS only. **Recommendation: remove them in
a later, separate commit** (decision D9), not now. Reasons: they are not a target; keeping them
suggests desktop support that does not exist; they add work to every Flutter migration; and the
F-Droid draft already deletes them before building. If desktop support is ever wanted,
`flutter create --platforms=linux,macos,windows .` regenerates them in minutes.

Removal steps once approved: `git rm -r linux macos windows`; drop the three platform entries
from the `migration` list in `.metadata`; update the README layout block; confirm
`flutter analyze`, `flutter test`, the Android build and the iOS compile job still pass. Until
then the folders stay as unverified scaffolding and no CI job builds them.

## 5. Milestones

Owner decisions (section 6) can be prepared in parallel with M1–M4.

1. **M1 — iOS compiles in CI, hygiene.** I1, A8. *Exit:* the `ios` job is green on macos-15;
   leftover files removed.
2. **M2 — iOS Shiny spike on a simulator.** I2 and I3 with the `integration_test` path in CI.
   *Exit:* the bundled sample renders on an iOS simulator in CI, or the blocker is recorded
   here and the owner decides whether iOS continues.
3. **M3 — Release-ready code.** A1, A3, A5 and the tablet layout (4.3). *Exit:* tests for each,
   CI green, tablet emulator check.
4. **M4 — Source delivery.** A2. *Exit:* THIRD_PARTY.md gate closed with evidence.
5. **M5 — Android device acceptance.** A4, A6, A7. *Exit:* journeys pass on phone, tablet and
   16 KB image; recorded in `docs/current-status.qmd`.
6. **M6 — Signed Android release on GitHub.** Needs D1, D2, D6. Add `android-release.yml`.
   *Exit:* draft release with signed APKs, source bundle and matching checksums; README
   availability updated; CI APK uploads may resume.
7. **M7 — Google Play.** D3, D8. *Exit:* internal track installed; closed test completed where
   required; production approved.
8. **M8 — iOS share import and TestFlight.** Needs D3, D4, D5, D7. I4–I8 on devices.
   *Exit:* processed build with Share Extension on an iPhone and an iPad; the iOS journey passes.
9. **M9 — App Store.** *Exit:* App Review approved, release published.
10. **M10 — F-Droid.** Needs D11 and a source-build route for the runtimes. *Exit:* recipe
    enabled and accepted, or the decision not to publish recorded here.
11. **M11 — Desktop runner folders.** After D9, at any point. *Exit:* folders removed per 4.7,
    or kept with the reason recorded here.

## 6. Owner decisions and prerequisites

| ID | Decision or prerequisite | Recommendation |
|---|---|---|
| D1 | Android signing model: own app signing key uploaded to Play App Signing plus an upload key, or a Google-generated app signing key | Own app signing key, so GitHub and Play installs share one signature |
| D2 | Version scheme, reconciled with the `.fdroid.yml` draft (versionCode `100002` for arm64) and Flutter's per-ABI version codes | One documented scheme before the first signed build; it can never go backwards |
| D3 | Store accounts: Google Play developer account and Apple Developer Program (including an App Group for I5) | Check Play's rule for new personal accounts (currently a closed test with 12 opted-in testers for 14 days) |
| D4 | GPL-3.0 WebR under Apple's App Store and TestFlight terms | Get legal advice before external distribution: the FSF considers Apple's usage rules incompatible with the GPL. Options: proceed after advice, or no iOS release |
| D5 | Running imported R code and fetching packages at launch on iOS (App Review guideline 2.5.2) | At first, run on iOS only apps whose packages are in the bundled image (`package_resolver.dart` already detects missing ones); present the app as a runner for the user's own Shiny code in the review notes |
| D6 | Release ABIs: arm64-v8a only, or also armeabi-v7a and x86_64 | arm64-v8a only on GitHub; the AAB may add x86_64 for ChromeOS if tested |
| D7 | Minimum iOS version (I8) | The oldest version that passes M2 and the device journey |
| D8 | Privacy policy and support URLs, disclosing URL imports and package downloads at launch | Host on the documentation site |
| D9 | `linux/`, `macos/`, `windows/` folders | Remove later in a separate commit (4.7) |
| D10 | Offer the iPad app on Apple silicon Macs | Opt out until tested |
| D11 | F-Droid route: source-build recipe for the runtimes in the main repository, own repository, or none | Decide after M6 |
| D12 | Where CI signing secrets live | Per-repository `release` environment with required reviewer |

## November 2026 implementation update

See [the Apple build and refinement record](apple-audit-2026-11-08.md) for completed source changes, exact verification and remaining device/signing gates. Earlier platform observations are historical; Xcode is now available on the audit Mac.
