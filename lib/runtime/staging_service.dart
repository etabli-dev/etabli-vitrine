// Copyright 2026 Raban Heller
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final stagingServiceProvider = Provider<StagingService>((_) => StagingService());

/// Owns the on-disk staging area for imported apps. Each library entry's files
/// live under `<app-support>/staged/<appId>/`; the runner serves that directory.
class StagingService {
  Future<Directory> _stagedRoot() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'staged'));
  }

  /// Resolves (without creating) the staging directory for [appId].
  Future<Directory> dirFor(String appId) async =>
      Directory(p.join((await _stagedRoot()).path, appId));

  /// Extracts a zip [bytes] into a fresh staging dir for [appId].
  Future<Directory> stageZip(Uint8List bytes, String appId) =>
      stageArchiveSubtree(appId, ZipDecoder().decodeBytes(bytes), '');

  /// Extracts the files of [archive] under [prefix] into a fresh staging dir,
  /// stripping [prefix] (used to drop a single wrapping folder). Guards against
  /// zip-slip path traversal.
  Future<Directory> stageArchiveSubtree(
      String appId, Archive archive, String prefix) async {
    final dir = await dirFor(appId);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);

    for (final entry in archive) {
      if (!entry.isFile) continue;
      final name = entry.name.replaceAll('\\', '/');
      if (!name.startsWith(prefix)) continue;
      final rel = name.substring(prefix.length);
      if (rel.isEmpty) continue;
      final outPath = p.normalize(p.join(dir.path, rel));
      if (!p.isWithin(dir.path, outPath)) continue; // zip-slip guard
      final f = File(outPath);
      await f.parent.create(recursive: true);
      await f.writeAsBytes(entry.content as List<int>);
    }
    return dir;
  }

  /// Writes a single file into [appId]'s staging dir (used for raw-source
  /// apps, which stage only a generated `app.json`).
  Future<File> writeStagedFile(String appId, String relPath, List<int> bytes) async {
    final dir = await dirFor(appId);
    final f = File(p.normalize(p.join(dir.path, relPath)));
    if (!p.isWithin(dir.path, f.path)) {
      throw ArgumentError('relPath escapes staging dir: $relPath');
    }
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes);
    return f;
  }

  /// Removes a staged app's files (used when deleting a library entry).
  Future<void> remove(String appId) async {
    final dir = await dirFor(appId);
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
