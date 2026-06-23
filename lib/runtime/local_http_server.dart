import 'dart:io';

import 'package:path/path.dart' as p;

/// A loopback static file server used to run staged content inside the WebView.
///
/// Two serving modes matter:
///  * [crossOriginIsolated] = true — inject COOP/COEP/CORP so WebR can use its
///    SharedArrayBuffer channel (the raw-WebR / console path).
///  * [crossOriginIsolated] = false — serve plain. A shinylive bundle manages
///    its own cross-origin isolation via its bundled service worker, and our
///    `require-corp` header would otherwise break it.
class LocalHttpServer {
  LocalHttpServer({
    required this.rootDir,
    this.crossOriginIsolated = true,
    this.virtualRoutes = const {},
  });

  /// Directory whose files are served at the URL root.
  final Directory rootDir;

  /// Whether to send cross-origin-isolation headers.
  final bool crossOriginIsolated;

  /// In-memory HTML routes (e.g. a generated index) served before disk files.
  final Map<String, String> virtualRoutes;

  HttpServer? _server;
  Uri? _baseUri;

  Uri? get baseUri => _baseUri;

  Future<Uri> start() async {
    if (_baseUri != null) return _baseUri!;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    server.listen(_handle);
    _baseUri = Uri.parse('http://127.0.0.1:${server.port}/');
    return _baseUri!;
  }

  Future<void> dispose() async {
    await _server?.close(force: true);
    _server = null;
    _baseUri = null;
  }

  Future<void> _handle(HttpRequest req) async {
    final res = req.response;
    if (crossOriginIsolated) {
      res.headers
        ..set('Cross-Origin-Opener-Policy', 'same-origin')
        ..set('Cross-Origin-Embedder-Policy', 'require-corp')
        ..set('Cross-Origin-Resource-Policy', 'same-origin');
    }
    res.headers.set('Cache-Control', 'no-store');

    final path = req.uri.path;
    final virtual = virtualRoutes[path];
    if (virtual != null) {
      res.headers.contentType =
          (path == '/' || path.endsWith('.html')) ? ContentType.html : mimeFor(path);
      res.write(virtual);
      await res.close();
      return;
    }

    final rel = path.startsWith('/') ? path.substring(1) : path;
    final file = File(p.normalize(p.join(rootDir.path, rel)));
    if (!p.isWithin(rootDir.path, file.path) || !await file.exists()) {
      res.statusCode = HttpStatus.notFound;
      await res.close();
      return;
    }
    res.headers.contentType = mimeFor(rel);
    await res.addStream(file.openRead());
    await res.close();
  }

  static ContentType mimeFor(String path) {
    final ext = p.extension(path).toLowerCase();
    return switch (ext) {
      '.js' || '.mjs' || '.cjs' =>
        ContentType('text', 'javascript', charset: 'utf-8'),
      '.wasm' || '.so' => ContentType('application', 'wasm'),
      '.json' => ContentType('application', 'json', charset: 'utf-8'),
      '.html' || '.htm' => ContentType.html,
      '.css' => ContentType('text', 'css', charset: 'utf-8'),
      '.svg' => ContentType('image', 'svg+xml'),
      '.wasm.gz' => ContentType('application', 'wasm'),
      // Gzipped VFS payloads and everything else: raw bytes, no Content-Encoding.
      _ => ContentType('application', 'octet-stream'),
    };
  }
}
