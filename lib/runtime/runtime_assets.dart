import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'staging_service.dart';

/// Prepare a complete version beside the previous runtime, then swap it in.
/// A failed load, extraction or validation leaves the previous version intact.
class RuntimeAssets {
  RuntimeAssets({
    required this.name,
    required this.version,
    required this.asset,
    required this.requiredFiles,
    this.supportDirectory,
    this.loadAsset,
  });
  final String name, version, asset;
  final List<String> requiredFiles;
  final Directory? supportDirectory;
  final Future<Uint8List> Function()? loadAsset;
  Future<Directory>? _pending;

  Future<Directory> ensureReady() =>
      _pending ??= _prepare().whenComplete(() => _pending = null);

  Future<bool> _valid(Directory root) async {
    final marker = File(p.join(root.path, '.runtime_version'));
    if (!await marker.exists() || await marker.readAsString() != version) {
      return false;
    }
    for (final name in requiredFiles) {
      final file = File(p.join(root.path, name));
      if (!await file.exists() || await file.length() == 0) return false;
    }
    return true;
  }

  Future<Directory> _prepare() async {
    final support = supportDirectory ?? await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, name));
    if (await FileSystemEntity.type(root.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const FormatException(
        'Runtime directory cannot be a symbolic link.',
      );
    }
    if (await _valid(root)) return root;
    final bytes = loadAsset == null
        ? (await rootBundle.load(asset)).buffer.asUint8List()
        : await loadAsset!();
    final archive = ZipDecoder().decodeBytes(bytes);
    StagingService.validateArchive(archive);
    await support.create(recursive: true);
    final transaction = await support.createTemp('.runtime-');
    final fresh = await Directory(p.join(transaction.path, 'new')).create();
    final backup = Directory(p.join(transaction.path, 'previous'));
    var safeToClean = true;
    try {
      for (final entry in archive) {
        if (!entry.isFile) continue;
        final file = File(
          p.join(fresh.path, StagingService.validateRelativePath(entry.name)),
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(entry.content as List<int>, flush: true);
      }
      await File(
        p.join(fresh.path, '.runtime_version'),
      ).writeAsString(version, flush: true);
      if (!await _valid(fresh)) {
        throw const FormatException('The bundled runtime is incomplete.');
      }
      final hadPrevious = await root.exists();
      if (hadPrevious) {
        await root.rename(backup.path);
        safeToClean = false;
      }
      try {
        await fresh.rename(root.path);
        safeToClean = true;
      } catch (_) {
        if (hadPrevious) await backup.rename(root.path);
        safeToClean = true;
        rethrow;
      }
    } finally {
      if (safeToClean) await transaction.delete(recursive: true);
    }
    return root;
  }
}
