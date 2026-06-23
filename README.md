# Etabli Vitrine

> Run interactive Shiny apps entirely on-device.

`iOS` `Android` `macOS` `Windows` `Linux` · Apache-2.0 · Part of the [Etabli Suite](https://github.com/etabli-dev)

Etabli Vitrine bundles WebR and shinylive-R to execute interactive Shiny applications entirely on your device, with no server and no network. Share apps in via the system share sheet. Ships with sample apps to get started.

## Availability

- **App Store (iOS):** available.
- **Google Play:** available.
- **F-Droid:** main-repo submission in progress; meanwhile available via the **Etabli F-Droid repo** and as a signed APK on **[Releases](../../releases)**.
- **macOS:** notarized build available.
- **Desktop (Windows, Linux):** build from source.

## Privacy

No analytics. No third-party SDKs. No accounts. Credentials, where needed, live only in the platform secure store (iOS Keychain / Android EncryptedSharedPreferences). This app is fully offline.

## Repository layout

```
lib/         app, features, data, theme, widgets
android/     Android runner
ios/         iOS runner
macos/ windows/ linux/    desktop runners
.fdroid.yml  F-Droid build recipe (main-repo submission)
fastlane/    store + F-Droid listing metadata
```

## Tech

Dart 3.12+, flutter_riverpod, go_router, drift, flutter_inappwebview

**Status:** Complete, iOS submission in progress

## Support development

- 💚 **[Liberapay](https://liberapay.com/rabanheller/)** — recurring, 0% commission, shown on F-Droid.
- ☕ [Buy Me a Coffee](https://buymeacoffee.com/rabanheller) — one-off tip (also the in-app link on iOS/Android).

## License

Apache License 2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE).

Copyright 2026 Raban Heller.
