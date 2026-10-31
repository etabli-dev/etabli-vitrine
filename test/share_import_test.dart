import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitrine/features/import/share_listener.dart';
import 'package:vitrine/features/import/import_controller.dart';
import 'package:vitrine/data/models/shiny_app.dart';

class CaptureImporter implements ImportController {
  final List<Map<String, Uint8List>> batches = [];
  @override
  Future<ShinyApp> importRawSourceFiles(
    Map<String, Uint8List> files, {
    required String name,
    String? sourceUri,
  }) async {
    batches.add(files);
    throw StateError('Injected persistence failure');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'shared ui/server arrive together; persistence failure is visible and originals survive',
    () async {
      final dir = await Directory.systemTemp.createTemp('vitrine-share-');
      addTearDown(() => dir.delete(recursive: true));
      final ui = await File(
        '${dir.path}/ui.R',
      ).writeAsString('ui <- fluidPage()');
      final server = await File(
        '${dir.path}/server.R',
      ).writeAsString('server <- function(input, output) {}');
      final capture = CaptureImporter();
      final errors = <String>[];
      await ShareImportListener(
        capture,
        onError: errors.add,
      ).importPaths([ui.path, server.path]);
      expect(
        capture.batches.single.keys,
        unorderedEquals(['ui.R', 'server.R']),
      );
      expect(errors, hasLength(1));
      expect(await ui.readAsString(), 'ui <- fluidPage()');
      expect(await server.exists(), isTrue);
    },
  );
  test(
    'oversized or missing files never start a partial source import',
    () async {
      final dir = await Directory.systemTemp.createTemp('vitrine-share-');
      addTearDown(() => dir.delete(recursive: true));
      final app = await File('${dir.path}/app.R').writeAsString('a' * 20);
      final capture = CaptureImporter();
      final errors = <String>[];
      final listener = ShareImportListener(
        capture,
        onError: errors.add,
        maxBytes: 10,
      );
      await listener.importPaths([app.path]);
      await listener.importPaths(['${dir.path}/missing.R']);
      expect(capture.batches, isEmpty);
      expect(errors, hasLength(2));
      expect(await app.length(), 20);
    },
  );
}
