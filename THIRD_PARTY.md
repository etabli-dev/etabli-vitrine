# Runtime provenance and redistribution

The application source is Apache-2.0. Bundled runtimes and packages retain their own licenses; the WebR binary is **GPL-3.0**, not Apache-2.0. Upstream notices are included under `assets/licenses/` and exposed through Settings → Open-source licenses.

| Component | Exact version | Source and license |
|---|---|---|
| WebR | 0.6.0 (R 4.6.0 observed in the runtime) | [Source tag](https://github.com/r-wasm/webr/tree/v0.6.0), [binary GPL-3.0 and other components](https://github.com/r-wasm/webr/blob/v0.6.0/LICENSE.md) |
| shinylive | 0.10.12 | [Source tag](https://github.com/posit-dev/shinylive/tree/v0.10.12), MIT; bundled R packages retain their licenses |

`tool/runtimes.lock.json` records canonical download URLs and SHA-256 digests. Inputs are WebR's official zip and Posit's official shinylive tarball; the latter includes both its R engine and Pyodide distribution. The fetcher verifies every input before writing application assets and writes a per-file receipt to ignored `tool/runtimes.prepared.json`. `--offline` requires a previously verified cache and makes no download request. Corrupt cached inputs fail without replacing application assets.

Vitrine repacks the R engine and service worker into a zip with stable entry ordering, timestamps and permissions. The Python runtime and Pyright are omitted because Vitrine runs R. WebR is separately repacked for the console. The sample Shiny source is committed in `lib/features/import/import_controller.dart`.

## Distribution gate

These checks establish binary provenance, not a source build or store approval. Before publishing a binary, prepare and verify the corresponding-source materials for every bundled copyleft component, including the R package image, and review compatibility with the chosen distribution channel. An upstream tag link alone is not a completed corresponding-source delivery. F-Droid main-repository acceptance is unverified; do not describe `scanignore` as approval of prebuilt runtimes. See [FDROID_NOTES.md](FDROID_NOTES.md).
