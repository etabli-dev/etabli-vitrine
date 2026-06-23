// Copyright 2026 Raban Heller
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'import_controller.dart';

/// Receives files shared into the app via the OS share-sheet and routes them
/// through the import pipeline. Mobile-only; a no-op on desktop.
class ShareImportListener {
  ShareImportListener(this._controller);

  final ImportController _controller;
  StreamSubscription<List<SharedMediaFile>>? _sub;

  void start() {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    // Files shared while the app was not running.
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      _handle(files);
      ReceiveSharingIntent.instance.reset();
    });
    // Files shared while the app is already open.
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(_handle);
  }

  Future<void> _handle(List<SharedMediaFile> files) async {
    for (final media in files) {
      try {
        final file = File(media.path);
        if (!await file.exists()) continue;
        final bytes = await file.readAsBytes();
        final name = p.basename(media.path);
        if (name.toLowerCase().endsWith('.zip')) {
          await _controller.importZipBytes(
            bytes,
            name: p.basenameWithoutExtension(name),
            sourceUri: media.path,
          );
        } else if (name.toLowerCase().endsWith('.r')) {
          await _controller.importRawSourceFiles(
            {name: bytes},
            name: 'Shared app',
            sourceUri: media.path,
          );
        }
      } catch (_) {
        // Ignore individual share failures; the library simply won't gain an entry.
      }
    }
  }

  void dispose() => _sub?.cancel();
}
