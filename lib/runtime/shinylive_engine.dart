import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final shinyliveEngineProvider = Provider<ShinyliveEngine>((_) => ShinyliveEngine());

/// The bundled shinylive **R** runtime engine (WebR 0.6.0 + the shiny library
/// image + the engine JS/service-worker). Raw Shiny source is run by wrapping
/// it in a tiny `app.json` and serving it over this shared, extract-once engine
/// — the proven way to run R Shiny offline (the standalone httpuv shim is
/// incompatible with WebR 0.6.0 in the browser).
class ShinyliveEngine {
  static const String version = '0.10.12';
  static const String _assetZip = 'assets/shinylive-r/engine.zip';

  Directory? _dir;

  /// Extracts the engine once to app-support; returns its directory.
  Future<Directory> ensureReady() async {
    if (_dir != null) return _dir!;
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, 'shinylive_r_engine'));
    final marker = File(p.join(root.path, '.engine_version'));

    if (await marker.exists() &&
        (await marker.readAsString()).trim() == version) {
      return _dir = root;
    }
    if (await root.exists()) await root.delete(recursive: true);
    await root.create(recursive: true);

    final data = await rootBundle.load(_assetZip);
    final archive = ZipDecoder().decodeBytes(data.buffer.asUint8List());
    for (final entry in archive) {
      final outPath = p.normalize(p.join(root.path, entry.name));
      if (!p.isWithin(root.path, outPath)) continue;
      if (entry.isFile) {
        final f = File(outPath);
        await f.parent.create(recursive: true);
        await f.writeAsBytes(entry.content as List<int>);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
    await marker.writeAsString(version);
    return _dir = root;
  }

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
