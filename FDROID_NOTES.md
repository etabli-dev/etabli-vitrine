# F-Droid strategy for Etabli Vitrine

This app bundles **WebR + shinylive** as open-source WebAssembly. That is the one thing
standing between it and a frictionless main-repo acceptance, because F-Droid wants
every shipped byte to be either built from source in the recipe or fetched from a
trusted/provenanced source.

## Two-track plan (do both; they share artifacts)

### Track 1 — main-repo submission (best outcome, not guaranteed)
`.fdroid.yml` in the repo root is a complete Flutter recipe. It:
- builds the Dart/Flutter app from source via the `flutter@stable` srclib,
- removes all non-Android platform dirs,
- handles the WASM runtimes via `scanignore: assets/runtimes`, with their
  provenance fully documented in `THIRD_PARTY.md` and fetched in `prebuild`
  from canonical upstream release URLs by `tool/fetch_runtimes.sh`.

Submit by forking `gitlab.com/fdroid/fdroiddata`, copying this recipe to
`metadata/com.raban.etabli.vitrine.yml`, pushing to your fork, and letting CI build it.
Read the CI log: if the reviewer accepts scanignore'd provenanced runtimes, you're in.
If they insist the WASM be built from source, that's currently impractical for
WebR/Pyodide — fall back to Track 2 for those versions.

### Track 2 — guaranteed: your own F-Droid repo (reproducible-binary path)
You already host signed APKs on GitHub Releases. Your own F-Droid repo points at
them. Optionally use the **Binaries / AllowedAPKSigningKeys** directives so even
the main repo could publish *your* signed APK once it matches the recipe build —
this keeps a single signing identity across Play Store, your repo, and (if accepted)
the main repo. See `../fdroid-repo/` in the setup pack.

## ABI / version-code rule (important)
F-Droid keeps only the highest installable versionCode, so the ABI digit goes in
the lowest position and must order: armeabi-v7a < arm64-v8a < x86_64.
This recipe uses 1000 0X where X = 1 (v7a), 2 (arm64), 4 (x86_64). When you bump to
1.1, every ABI code must exceed the 1.0 codes.

## Before first F-Droid release
- Decide your signing key now — **it cannot be changed after first release**.
- Keep that keystore backed up and out of git (`.gitignore` already excludes it).
- Fill in `THIRD_PARTY.md` with exact pinned runtime versions + source URLs + licenses.
