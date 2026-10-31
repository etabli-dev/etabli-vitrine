// Copyright 2026 R. Heller
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final stagingServiceProvider = Provider<StagingService>(
  (_) => StagingService(),
);

/// Owns the on-disk staging area for imported apps. Each library entry's files
/// live under `<app-support>/staged/<appId>/`; the runner serves that directory.
class StagingService {
  StagingService({this.supportDirectory});

  final Directory? supportDirectory;
  static const int maxExpandedBytes = 512 * 1024 * 1024;
  static const int maxArchiveFiles = 10000;

  Future<Directory> _stagedRoot() async {
    final support = supportDirectory ?? await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'staged'));
  }

  /// Resolves (without creating) the staging directory for [appId].
  Future<Directory> dirFor(String appId) async {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$').hasMatch(appId)) {
      throw ArgumentError.value(appId, 'appId', 'Invalid app identifier');
    }
    final dir = Directory(p.join((await _stagedRoot()).path, appId));
    if (await FileSystemEntity.type(dir.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const FormatException('A staged app cannot be a symbolic link.');
    }
    return dir;
  }

  static String validateRelativePath(String name) {
    final rel = name.replaceAll('\\', '/');
    if (rel.isEmpty ||
        rel.contains('\u0000') ||
        p.posix.isAbsolute(rel) ||
        p.windows.isAbsolute(rel) ||
        rel
            .split('/')
            .any((part) => part.isEmpty || part == '.' || part == '..')) {
      throw FormatException('Unsafe archive path: $name');
    }
    return rel;
  }

  /// Validate metadata before decompressing file contents or changing disk state.
  static void validateArchive(Archive archive) {
    var total = 0;
    var count = 0;
    final names = <String>{};
    for (final entry in archive) {
      if (entry.isSymbolicLink) {
        throw const FormatException('Archive symlinks are not supported.');
      }
      final name = entry.isDirectory && entry.name.endsWith('/')
          ? entry.name.substring(0, entry.name.length - 1)
          : entry.name;
      final rel = validateRelativePath(name);
      if (!names.add(rel)) {
        throw FormatException('Duplicate archive path: $rel');
      }
      if (entry.isFile) {
        total += entry.size;
        count++;
        if (entry.size < 0 ||
            total > maxExpandedBytes ||
            count > maxArchiveFiles) {
          throw const FormatException(
            'Expanded archive exceeds the import limit.',
          );
        }
      }
    }
  }

  /// Extracts a zip [bytes] into a fresh staging dir for [appId].
  Future<Directory> stageZip(Uint8List bytes, String appId) =>
      stageArchiveSubtree(appId, ZipDecoder().decodeBytes(bytes), '');

  /// Extracts the files of [archive] under [prefix] into a fresh staging dir,
  /// stripping [prefix] (used to drop a single wrapping folder). Guards against
  /// zip-slip path traversal.
  Future<Directory> stageArchiveSubtree(
    String appId,
    Archive archive,
    String prefix,
  ) async {
    validateArchive(archive);
    if (prefix.isNotEmpty) {
      if (!prefix.endsWith('/')) {
        throw const FormatException('Invalid archive prefix.');
      }
      validateRelativePath(prefix.substring(0, prefix.length - 1));
    }
    if (!archive.any(
      (entry) =>
          entry.isFile && entry.name.replaceAll('\\', '/').startsWith(prefix),
    )) {
      throw const FormatException('The archive contains no app files.');
    }
    final dir = await dirFor(appId);
    await dir.parent.create(recursive: true);
    final transaction = await dir.parent.createTemp('.import-');
    final fresh = await Directory(p.join(transaction.path, 'new')).create();
    final backup = Directory(p.join(transaction.path, 'previous'));
    var safeToClean = true;
    try {
      for (final entry in archive) {
        if (!entry.isFile) continue;
        final name = entry.name.replaceAll('\\', '/');
        if (!name.startsWith(prefix)) continue;
        final rel = validateRelativePath(name.substring(prefix.length));
        final f = File(p.join(fresh.path, rel));
        await f.parent.create(recursive: true);
        await f.writeAsBytes(entry.content as List<int>, flush: true);
      }
      final hadPrevious = await dir.exists();
      if (hadPrevious) {
        await dir.rename(backup.path);
        safeToClean = false;
      }
      try {
        await fresh.rename(dir.path);
        safeToClean = true;
      } catch (_) {
        if (hadPrevious) await backup.rename(dir.path);
        safeToClean = true;
        rethrow;
      }
    } finally {
      // If even recovery failed, retain the previous app under .import-*/previous.
      if (safeToClean) await transaction.delete(recursive: true);
    }
    return dir;
  }

  /// Writes a single file into [appId]'s staging dir (used for raw-source
  /// apps, which stage only a generated `app.json`).
  Future<File> writeStagedFile(
    String appId,
    String relPath,
    List<int> bytes,
  ) async {
    final dir = await dirFor(appId);
    final rel = validateRelativePath(relPath);
    var current = dir.path;
    for (final part in rel.split('/')) {
      current = p.join(current, part);
      if (await FileSystemEntity.type(current, followLinks: false) ==
          FileSystemEntityType.link) {
        throw const FormatException(
          'Staged paths cannot contain symbolic links.',
        );
      }
    }
    final f = File(current);
    await f.parent.create(recursive: true);
    final temp = await f.parent.createTemp('.write-');
    try {
      await File(p.join(temp.path, 'content')).writeAsBytes(bytes, flush: true);
      await File(p.join(temp.path, 'content')).rename(f.path);
    } finally {
      await temp.delete(recursive: true);
    }
    return f;
  }

  /// Removes a staged app's files (used when deleting a library entry).
  Future<void> remove(String appId) async {
    final dir = await dirFor(appId);
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
