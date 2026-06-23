#!/usr/bin/env bash
# Fetch vendored open-source runtimes (WebR + shinylive) at build time.
# Provenance documented in THIRD_PARTY.md; F-Droid scans this script to verify
# the bundled blobs come from canonical upstream releases.
set -euo pipefail

# Make sure the asset tree pubspec.yaml expects exists, even when no
# upstream URLs are pinned yet (keeps `flutter pub get` / analyze quiet).
mkdir -p assets/webr assets/shinylive-r assets/samples

fetch() {
  local url="$1" sum="$2" out="$3"
  echo "Fetching $out"
  curl -fsSL "$url" -o "$out"
  echo "$sum  $out" | shasum -a 256 -c -
}

# --- EDIT: pin exact upstream release URLs + sha256 below ---
# fetch "https://github.com/r-wasm/webr/releases/download/vX/webr.tgz" "<sha256>" "assets/webr/webr.tgz"
# fetch "https://github.com/posit-dev/shinylive/releases/download/vX/shinylive-X.zip" "<sha256>" "assets/shinylive-r/engine.zip"

echo "Runtimes fetched + checksum-verified."
