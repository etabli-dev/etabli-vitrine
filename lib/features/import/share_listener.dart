// Copyright 2026 R. Heller
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'import_controller.dart';

/// Serializes share deliveries. Source files remain untouched on any failure.
class ShareImportListener {
  ShareImportListener(
    this._controller, {
    required this.onError,
    this.maxBytes = ImportController.maxImportBytes,
  });
  final ImportController _controller;
  final void Function(String) onError;
  final int maxBytes;
  StreamSubscription<List<SharedMediaFile>>? _sub;
  Future<void> _queue = Future.value();
  bool _disposed = false;

  void start() {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((files) async {
          await _enqueue(files);
          if (!_disposed) await ReceiveSharingIntent.instance.reset();
        })
        .catchError(
          (Object _) =>
              _report('Could not read the shared files. Retry from Files.'),
        );
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) {
        _enqueue(files);
      },
      onError: (Object _) =>
          _report('Could not receive the share. Retry from Files.'),
    );
  }

  Future<void> _enqueue(List<SharedMediaFile> files) => _queue = _queue.then(
    (_) => importPaths(files.map((f) => f.path).toList()),
  );

  void _report(String message) {
    if (!_disposed) onError(message);
  }

  /// A share containing app.R or ui.R/server.R is one app, not separate apps.
  Future<void> importPaths(List<String> paths) async {
    if (_disposed || paths.isEmpty) return;
    final sources = <String, Uint8List>{};
    var total = 0;
    for (final path in paths) {
      if (_disposed) return;
      try {
        final name = p.basename(path);
        final extension = p.extension(name).toLowerCase();
        if (extension != '.r' && extension != '.zip') {
          throw const FormatException('Unsupported shared file.');
        }
        final file = File(path);
        if (await file.length() > maxBytes) {
          throw const FormatException('Shared file exceeds the import limit.');
        }
        final builder = BytesBuilder(copy: false);
        await for (final chunk in file.openRead()) {
          total += chunk.length;
          if (total > maxBytes) {
            throw const FormatException(
              'Shared files exceed the import limit.',
            );
          }
          builder.add(chunk);
        }
        final bytes = builder.takeBytes();
        if (extension == '.zip') {
          await _controller.importZipBytes(
            bytes,
            name: p.basenameWithoutExtension(name),
            sourceUri: path,
          );
        } else {
          if (sources.containsKey(name)) {
            throw const FormatException('Duplicate shared filename.');
          }
          sources[name] = bytes;
        }
      } catch (_) {
        _report(
          'Could not import $path. Use a readable .zip or app.R (or ui.R with server.R) within the import limit. Source files are unchanged.',
        );
        // A partial source set must not be imported as a complete application.
        return;
      }
    }
    if (sources.isNotEmpty && !_disposed) {
      try {
        await _controller.importRawSourceFiles(
          sources,
          name: 'Shared app',
          sourceUri: paths.join('\n'),
        );
      } catch (_) {
        _report(
          'Could not import the shared R sources. Include app.R, or both ui.R and server.R. Source files are unchanged.',
        );
      }
    }
  }

  void dispose() {
    _disposed = true;
    _sub?.cancel();
  }
}
