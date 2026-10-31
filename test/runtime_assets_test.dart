import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitrine/runtime/runtime_assets.dart';

void main() {
  late Directory support;
  setUp(() async {
    support = await Directory.systemTemp.createTemp('runtime-test');
  });
  tearDown(() => support.delete(recursive: true));
  Uint8List zip(Map<String, List<int>> files) {
    final archive = Archive();
    for (final e in files.entries) {
      archive.addFile(ArchiveFile(e.key, e.value.length, e.value));
    }
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  test(
    'concurrent requests share one installation; missing files trigger repair',
    () async {
      var loads = 0;
      final runtime = RuntimeAssets(
        name: 'engine',
        version: '1',
        asset: '',
        requiredFiles: ['engine.js'],
        supportDirectory: support,
        loadAsset: () async {
          loads++;
          return zip({
            'engine.js': [1, 2, 3],
          });
        },
      );
      final dirs = await Future.wait(
        List.generate(10, (_) => runtime.ensureReady()),
      );
      expect(loads, 1);
      expect(dirs.map((d) => d.path).toSet(), hasLength(1));
      await File('${dirs.first.path}/engine.js').delete();
      await runtime.ensureReady();
      expect(loads, 2);
    },
  );
  test(
    'incomplete or malicious upgrade preserves the previous runtime',
    () async {
      final old = Directory('${support.path}/engine');
      await old.create();
      await File('${old.path}/original').writeAsString('preserve');
      for (final files in [
        <String, List<int>>{
          'wrong.js': [1],
        },
        <String, List<int>>{
          '../outside': [1],
        },
      ]) {
        final runtime = RuntimeAssets(
          name: 'engine',
          version: '2',
          asset: '',
          requiredFiles: ['engine.js'],
          supportDirectory: support,
          loadAsset: () async => zip(files),
        );
        await expectLater(runtime.ensureReady(), throwsFormatException);
        expect(await File('${old.path}/original').readAsString(), 'preserve');
        expect(await File('${support.path}/outside').exists(), isFalse);
      }
    },
  );
}
