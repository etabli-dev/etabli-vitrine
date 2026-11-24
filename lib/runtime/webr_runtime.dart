// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:convert';
import 'dart:io';

import '../l10n/app_localizations.dart';
import '../theme/appearance.dart';
import '../theme/coder_theme_vitrine_tokens.dart';
import 'local_http_server.dart';
import 'runtime_assets.dart';

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

  /// The R version the bundled WebR runs (shown in the console banner).
  static const String rVersion = '4.6.0';
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

  /// The console page with its texts in the app's language and the user's accent (dark value).
  static Uri consoleUri(Uri baseUri, AppLocalizations l, AccentChoice accent) {
    final texts = {
      'placeholder': l.webConsolePlaceholder,
      'booting': l.webConsoleBooting(webrVersion, rVersion),
      'platform': l.webConsolePlatform,
      'channel': l.webConsoleChannel,
      'isolated': l.webConsoleIsolated,
      'notIsolated': l.webConsoleNotIsolated,
      'ready': l.webConsoleReady,
      'initError': l.webConsoleInitError,
    };
    return baseUri.replace(
      queryParameters: {
        't': base64Url.encode(utf8.encode(jsonEncode(texts))),
        'accent': accent.dark.toRadixString(16).padLeft(6, '0').toUpperCase(),
        'lang': l.localeName,
      },
    );
  }

  final _assets = RuntimeAssets(
    name: 'webr_runtime',
    version: '$webrVersion-prepared-1',
    asset: _assetZip,
    requiredFiles: ['webr.mjs', 'webr.js', 'R.wasm'],
  );
  Future<Directory> _ensureExtracted() => _assets.ensureReady();

  /// The runner document: boots WebR from this same origin, prints the R
  /// banner, and exposes a minimal REPL. Output is mirrored to Flutter via the
  /// `webr` JS handler. Its texts and accent arrive as query parameters
  /// (see [consoleUri]); English and Coder blue are the fallbacks.
  static const String _indexHtml =
      '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<title>WebR Console</title>
<style>
  :root { color-scheme: dark; --accent: ${VitrineTokens.accentHex}; }
  * { box-sizing: border-box; }
  html, body { margin: 0; height: 100%; background: ${VitrineTokens.darkBgHex}; color: ${VitrineTokens.darkTextHex};
    font-family: 'JetBrains Mono', ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
  body { display: flex; flex-direction: column; font-size: 13px; }
  #out { flex: 1; overflow-y: auto; padding: 12px; white-space: pre-wrap;
    word-break: break-word; line-height: 1.5; }
  .stderr { color: ${VitrineTokens.warnHex}; }
  .err { color: ${VitrineTokens.errorHex}; }
  .cmd { color: var(--accent); }
  .muted { color: ${VitrineTokens.darkTextMutedHex}; }
  #row { display: flex; align-items: center; border-top: 1px solid ${VitrineTokens.darkBorderHex};
    padding: 8px 12px; gap: 8px; }
  #row span { color: var(--accent); }
  #cmd { flex: 1; background: transparent; border: none; color: ${VitrineTokens.darkTextHex};
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

// Texts in the app's language and the accent colour, from the query (base64url JSON / RRGGBB hex).
const params = new URLSearchParams(window.location.search);
let T = {
  placeholder: 'starting WebR…', booting: 'Booting WebR 0.6.0 (R 4.6.0) — offline…',
  platform: 'Platform:', channel: 'Channel:', isolated: 'SharedArrayBuffer (cross-origin isolated)',
  notIsolated: 'PostMessage (no isolation)', ready: 'WebR is ready. Type R expressions below.',
  initError: 'Init error:',
};
try {
  const raw = params.get('t');
  if (raw) {
    const bin = atob(raw.replace(/-/g, '+').replace(/_/g, '/'));
    const bytes = Uint8Array.from(bin, (c) => c.charCodeAt(0));
    T = Object.assign(T, JSON.parse(new TextDecoder().decode(bytes)));
  }
} catch (_) {}
const accent = params.get('accent');
if (accent && /^[0-9A-Fa-f]{6}\$/.test(accent)) {
  document.documentElement.style.setProperty('--accent', '#' + accent);
}
const lang = params.get('lang');
if (lang && /^[a-z]{2}\$/.test(lang)) document.documentElement.lang = lang;
input.placeholder = T.placeholder;

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
  print(T.booting, 'muted');
  bridge('status', 'booting');

  const webR = new WebR({ baseUrl: window.location.origin + '/' });
  await webR.init();

  const isolated = self.crossOriginIsolated === true;
  const version = await webR.evalRString('R.version.string');
  const platform = await webR.evalRString('R.version\$platform');

  print(version);
  print(T.platform + ' ' + platform);
  print(T.channel + ' ' + (isolated ? T.isolated : T.notIsolated), 'muted');
  print(T.ready, 'cmd');
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
  print(T.initError + ' ' + (e && e.message ? e.message : e), 'err');
  bridge('error', String(e && e.message ? e.message : e));
});
</script>
</body>
</html>''';
}
