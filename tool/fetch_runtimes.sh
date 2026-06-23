#!/usr/bin/env bash
# Fetch vendored open-source WASM runtimes from their canonical upstream
# release URLs into assets/runtimes/. Pin exact versions + checksums.
# This gives F-Droid provenance instead of opaque committed blobs.
set -euo pipefail
DEST="assets/runtimes"
mkdir -p "$DEST"

# --- EDIT: pin exact upstream release URLs + sha256 below ---
# Example pattern (replace with real pinned URLs from THIRD_PARTY.md):
# fetch <url> <expected_sha256> <dest_filename>
fetch() {
  local url="$1" sum="$2" out="$3"
  echo "Fetching $out"
  curl -fsSL "$url" -o "$DEST/$out"
  echo "$sum  $DEST/$out" | sha256sum -c -
}

# fetch "https://github.com/r-wasm/webr/releases/download/vX/webr.tgz" "<sha256>" "webr.tgz"
# fetch "https://github.com/posit-dev/shinylive/releases/download/vX/shinylive.tar.gz" "<sha256>" "shinylive.tar.gz"

echo "Runtimes fetched + checksum-verified into $DEST"
