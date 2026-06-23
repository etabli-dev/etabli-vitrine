import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';

import '../../data/models/shiny_app.dart';
import '../../data/models/source_type.dart';
import '../../data/repositories/library_repository.dart';
import '../../runtime/local_http_server.dart';
import '../../runtime/shinylive_engine.dart';
import '../../runtime/staging_service.dart';
import '../../theme/tokens.dart';

/// Runs an imported shinylive bundle offline. The bundle is self-contained
/// (ships its own runtime + service worker), so it is served *plain* — no
/// COOP/COEP injection, which would break shinylive's own isolation handling.
class ShinyliveRunnerPage extends ConsumerStatefulWidget {
  const ShinyliveRunnerPage({super.key, required this.app});

  final ShinyApp app;

  @override
  ConsumerState<ShinyliveRunnerPage> createState() => _ShinyliveRunnerPageState();
}

class _ShinyliveRunnerPageState extends ConsumerState<ShinyliveRunnerPage> {
  LocalHttpServer? _server;
  Uri? _baseUri;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final server = await _buildServer();
      final uri = await server.start();
      await ref
          .read(libraryRepositoryProvider)
          .touchLastRun(widget.app.id, DateTime.now());
      if (!mounted) {
        await server.dispose();
        return;
      }
      setState(() {
        _server = server;
        _baseUri = uri;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  /// Both source types are served *plain* (the shinylive runtime manages its
  /// own cross-origin isolation via its service worker):
  ///  * shinyliveZip — a self-contained staged bundle served from disk.
  ///  * rawSource — the shared shinylive R engine + the app's generated
  ///    `app.json`/`index.html` injected as in-memory routes.
  Future<LocalHttpServer> _buildServer() async {
    final staging = ref.read(stagingServiceProvider);
    if (widget.app.sourceType == SourceType.rawSource) {
      final engineDir = await ref.read(shinyliveEngineProvider).ensureReady();
      final appJsonFile =
          File('${(await staging.dirFor(widget.app.stagedPath!)).path}/app.json');
      if (!await appJsonFile.exists()) {
        throw StateError('Staged app.json is missing — re-import this app.');
      }
      final appJson = await appJsonFile.readAsString();
      final index = ShinyliveEngine.indexHtml();
      return LocalHttpServer(
        rootDir: engineDir,
        crossOriginIsolated: false,
        virtualRoutes: {
          '/': index,
          '/index.html': index,
          '/app.json': appJson,
        },
      );
    }

    // shinyliveZip: serve the self-contained staged bundle.
    final stagingDir = await staging.dirFor(widget.app.stagedPath!);
    if (!await stagingDir.exists()) {
      throw StateError('Staged files are missing — re-import this app.');
    }
    return LocalHttpServer(rootDir: stagingDir, crossOriginIsolated: false);
  }

  @override
  void dispose() {
    _server?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.app.name)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(VitrineTokens.space5),
          child: Text('Failed to launch:\n\n$_error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }
    if (_baseUri == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri.uri(_baseUri!.resolve('index.html'))),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        isInspectable: true,
        // shinylive serves its app into an iframe via its service worker.
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      ),
      onConsoleMessage: (controller, msg) =>
          debugPrint('[shinylive] ${msg.message}'),
    );
  }
}
