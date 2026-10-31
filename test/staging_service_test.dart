import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitrine/runtime/staging_service.dart';

void main() {
  late Directory temp;
  late StagingService staging;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('vitrine-import-test-');
    staging = StagingService(supportDirectory: temp);
  });
  tearDown(() => temp.delete(recursive: true));

  Archive app(String contents) =>
      Archive()..addFile(ArchiveFile.string('app.R', contents));

  test('successful replacement uses only the new archive', () async {
    final old = app('old')..addFile(ArchiveFile.string('stale.txt', 'stale'));
    await staging.stageArchiveSubtree('example', old, '');
    final dir = await staging.stageArchiveSubtree('example', app('new'), '');
    expect(await File('${dir.path}/app.R').readAsString(), 'new');
    expect(await File('${dir.path}/stale.txt').exists(), isFalse);
  });

  test('invalid replacement preserves the existing runnable app', () async {
    final dir = await staging.stageArchiveSubtree(
      'example',
      app('preserve'),
      '',
    );
    for (final bad in [
      '../outside',
      '/absolute',
      r'C:\absolute',
      'a/../../outside',
    ]) {
      final malicious = app('changed')..addFile(ArchiveFile.string(bad, 'bad'));
      await expectLater(
        staging.stageArchiveSubtree('example', malicious, ''),
        throwsFormatException,
      );
      expect(await File('${dir.path}/app.R').readAsString(), 'preserve');
    }
  });

  test('oversized entries and symlinks fail before extraction', () async {
    final huge = ArchiveFile(
      'huge',
      StagingService.maxExpandedBytes + 1,
      Uint8List(0),
    );
    await expectLater(
      staging.stageArchiveSubtree('example', Archive()..addFile(huge), ''),
      throwsFormatException,
    );
    final linked = Archive()
      ..addFile(ArchiveFile.symlink('link', '../../outside'));
    await expectLater(
      staging.stageArchiveSubtree('example', linked, ''),
      throwsFormatException,
    );
    expect(await (await staging.dirFor('example')).exists(), isFalse);
  });

  test('invalid app identifiers cannot delete another directory', () async {
    await File('${temp.path}/keep').writeAsString('preserve');
    for (final id in ['..', '../keep', '/tmp', r'a\b', '']) {
      await expectLater(staging.remove(id), throwsArgumentError);
    }
    expect(await File('${temp.path}/keep').readAsString(), 'preserve');
  });

  test('wrapped source is extracted and a corrupt zip preserves it', () async {
    final wrapped = Archive()
      ..addFile(ArchiveFile.string('folder/app.R', 'preserve'));
    final dir = await staging.stageArchiveSubtree(
      'example',
      wrapped,
      'folder/',
    );
    await expectLater(
      staging.stageZip(Uint8List.fromList([1, 2, 3]), 'example'),
      throwsA(anything),
    );
    expect(await File('${dir.path}/app.R').readAsString(), 'preserve');
  });
}
