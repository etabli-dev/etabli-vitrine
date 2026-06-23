import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'local_http_server.dart';

/// Manages the bundled, offline WebR runtime.
///
/// The WebR v0.6.0 distribution (~47 MB unpacked: loader, R.wasm, the base-R
/// `vfs/` tree, blas/lapack) ships as a single zip asset because Flutter's
/// asset directive is not recursive. On first use we unpack it once to
/// app-support, then serve it from a loopback [HttpServer].
///
/// The server injects cross-origin-isolation headers (COOP/COEP) and correct
/// MIME types so WebR can use its fast `SharedArrayBuffer` channel; if the
/// WebView declines isolation, WebR transparently falls back to PostMessage.
class WebRRuntime {
  static const String webrVersion = '0.6.0';
  static const String _assetZip = 'assets/webr/webr-dist.zip';

  LocalHttpServer? _server;

  Uri? get baseUri => _server?.baseUri;

  /// Starts the runtime (extract if needed + bind server). Idempotent.
  Future<Uri> start() async {
    final existing = _server?.baseUri;
    if (existing != null) return existing;
    final dir = await _ensureExtracted();
    // WebR needs cross-origin isolation for its SharedArrayBuffer channel.
    final server = LocalHttpServer(
      rootDir: dir,
      crossOriginIsolated: true,
      virtualRoutes: const {'/': _indexHtml, '/index.html': _indexHtml},
    );
    _server = server;
    return server.start();
  }

  Future<void> dispose() async {
    await _server?.dispose();
    _server = null;
  }

  Future<Directory> _ensureExtracted() async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, 'webr_runtime'));
    final marker = File(p.join(root.path, '.webr_version'));

    if (await marker.exists() &&
        (await marker.readAsString()).trim() == webrVersion) {
      return root;
    }

    if (await root.exists()) await root.delete(recursive: true);
    await root.create(recursive: true);

    final data = await rootBundle.load(_assetZip);
    final archive = ZipDecoder().decodeBytes(data.buffer.asUint8List());
    for (final entry in archive) {
      final outPath = p.normalize(p.join(root.path, entry.name));
      // Guard against path traversal in the archive.
      if (!p.isWithin(root.path, outPath)) continue;
      if (entry.isFile) {
        final f = File(outPath);
        await f.parent.create(recursive: true);
        await f.writeAsBytes(entry.content as List<int>, flush: false);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
    await marker.writeAsString(webrVersion);
    return root;
  }

  /// The runner document: boots WebR from this same origin, prints the R
  /// banner, and exposes a minimal REPL. Output is mirrored to Flutter via the
  /// `webr` JS handler.
  static const String _indexHtml = r'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<title>WebR Console</title>
<style>
  :root { color-scheme: dark; }
  * { box-sizing: border-box; }
  html, body { margin: 0; height: 100%; background: #0F1115; color: #E6E6E6;
    font-family: 'JetBrains Mono', ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
  body { display: flex; flex-direction: column; font-size: 13px; }
  #out { flex: 1; overflow-y: auto; padding: 12px; white-space: pre-wrap;
    word-break: break-word; line-height: 1.5; }
  .stderr { color: #D98A00; }
  .err { color: #D64545; }
  .cmd { color: #28a745; }
  .muted { color: #8A929E; }
  #row { display: flex; align-items: center; border-top: 1px solid #2A2F37;
    padding: 8px 12px; gap: 8px; }
  #row span { color: #28a745; }
  #cmd { flex: 1; background: transparent; border: none; color: #E6E6E6;
    font: inherit; outline: none; }
  #cmd:disabled { opacity: 0.4; }
</style>
</head>
<body>
<div id="out"></div>
<div id="row"><span>&gt;</span><input id="cmd" autocomplete="off"
  autocapitalize="off" spellcheck="false" disabled placeholder="starting WebR…"></div>
<script type="module">
import { WebR } from './webr.js';

const out = document.getElementById('out');
const input = document.getElementById('cmd');

function print(text, cls) {
  const div = document.createElement('div');
  if (cls) div.className = cls;
  div.textContent = text;
  out.appendChild(div);
  out.scrollTop = out.scrollHeight;
}
function bridge(type, data) {
  try { window.flutter_inappwebview?.callHandler('webr', { type, data }); } catch (_) {}
}

async function main() {
  print('Booting WebR ' + '0.6.0' + ' (R 4.6.0) — offline…', 'muted');
  bridge('status', 'booting');

  const webR = new WebR({ baseUrl: window.location.origin + '/' });
  await webR.init();

  const isolated = self.crossOriginIsolated === true;
  const version = await webR.evalRString('R.version.string');
  const platform = await webR.evalRString('R.version$platform');

  print(version);
  print('Platform: ' + platform);
  print('Channel: ' + (isolated ? 'SharedArrayBuffer (cross-origin isolated)'
                                 : 'PostMessage (no isolation)'), 'muted');
  print('WebR is ready. Type R expressions below.', 'cmd');
  bridge('ready', { version, platform, isolated });

  const shelter = await new webR.Shelter();
  input.disabled = false;
  input.placeholder = '';
  input.focus();

  input.addEventListener('keydown', async (e) => {
    if (e.key !== 'Enter' || input.disabled) return;
    const code = input.value.trim();
    input.value = '';
    if (!code) return;
    print('> ' + code, 'cmd');
    input.disabled = true;
    try {
      const cap = await shelter.captureR(code, {
        withAutoprint: true, captureStreams: true, captureConditions: false,
      });
      for (const line of cap.output) {
        print(line.data, line.type === 'stderr' ? 'stderr' : null);
      }
      await shelter.purge();
    } catch (err) {
      print(String(err && err.message ? err.message : err), 'err');
    } finally {
      input.disabled = false;
      input.focus();
    }
  });
}

main().catch((e) => {
  print('Init error: ' + (e && e.message ? e.message : e), 'err');
  bridge('error', String(e && e.message ? e.message : e));
});
</script>
</body>
</html>''';
}
