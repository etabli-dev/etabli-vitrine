#!/usr/bin/env bash
# capture.sh — deterministic screenshot harness for etabli-vitrine (v0.1.0)
set -euo pipefail
PKG=com.raban.etabli.vitrine
OUT="$(cd "$(dirname "$0")/.." && pwd)/vignettes/assets/0.1.0"; mkdir -p "$OUT"
cap(){ for t in 1 2 3; do adb exec-out screencap -p > "$OUT/$1.png"; [ "$(wc -c < "$OUT/$1.png")" -gt 1000 ] && break; sleep 1; done; echo "  + $1.png"; }
adb shell pm clear "$PKG" >/dev/null 2>&1 || true
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; sleep 10
cap 01-library
adb shell input tap 894 2246; sleep 1.5; cap 02-import           # + Import sheet
adb shell input tap 400 2048; sleep 3;   cap 03-import-failed-asset  # Sample shinylive (asset missing in v0.1.0)
adb shell am force-stop "$PKG"; adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; sleep 9
adb shell input tap 1000 197; sleep 1.2; cap 04-settings
echo "Captured $(ls "$OUT"/*.png|wc -l) frames"
