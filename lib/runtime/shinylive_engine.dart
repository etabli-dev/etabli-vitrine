// Copyright 2026 R. Heller
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'runtime_assets.dart';

final shinyliveEngineProvider = Provider<ShinyliveEngine>(
  (_) => ShinyliveEngine(),
);

/// The bundled shinylive **R** runtime engine (WebR 0.6.0 + the shiny library
/// image + the engine JS/service-worker). Raw Shiny source is run by wrapping
/// it in a tiny `app.json` and serving it over this shared, extract-once engine
/// — the proven way to run R Shiny offline (the standalone httpuv shim is
/// incompatible with WebR 0.6.0 in the browser).
class ShinyliveEngine {
  static const String version = '0.10.12';
  static const String _assetZip = 'assets/shinylive-r/engine.zip';

  final _assets = RuntimeAssets(
    name: 'shinylive_r_engine',
    version: '$version-prepared-1',
    asset: _assetZip,
    requiredFiles: [
      'shinylive-sw.js',
      'shinylive/shinylive.js',
      'shinylive/webr/webr.mjs',
      'shinylive/webr/library.data.gz',
    ],
  );

  Future<Directory> ensureReady() => _assets.ensureReady();

  /// The `index.html` that boots the shinylive R engine for a served app.json.
  static String indexHtml() => '''<!doctype html>
<html lang="en"><head><meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Shiny App</title>
<script src="./shinylive/load-shinylive-sw.js" type="module"></script>
<script type="module">
  import { runExportedApp } from "./shinylive/shinylive.js";
  runExportedApp({ id: "root", appEngine: "r", relPath: "" });
</script>
<link rel="stylesheet" href="./shinylive/style-resets.css"/>
<link rel="stylesheet" href="./shinylive/shinylive.css"/>
</head><body><div style="height:100vh;width:100vw" id="root"></div></body></html>''';
}
