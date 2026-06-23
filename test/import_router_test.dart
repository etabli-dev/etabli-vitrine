import 'package:flutter_test/flutter_test.dart';
import 'package:vitrine/features/import/import_router.dart';

void main() {
  group('ImportRouter.classify', () {
    test('shinylive bundle at root', () {
      final d = ImportRouter.classify([
        'index.html', 'app.json', 'shinylive/shinylive.js', 'shinylive-sw.js',
      ]);
      expect(d.kind, ImportKind.shinyliveBundle);
      expect(d.rootPrefix, '');
    });

    test('shinylive bundle under a wrapping folder', () {
      final d = ImportRouter.classify([
        'myapp/index.html', 'myapp/app.json', 'myapp/shinylive/shinylive.js',
      ]);
      expect(d.kind, ImportKind.shinyliveBundle);
      expect(d.rootPrefix, 'myapp/');
    });

    test('raw single-file app.R', () {
      final d = ImportRouter.classify(['app.R']);
      expect(d.kind, ImportKind.rawSource);
      expect(d.rootPrefix, '');
    });

    test('raw ui.R + server.R under a folder', () {
      final d = ImportRouter.classify(['proj/ui.R', 'proj/server.R', 'proj/www/style.css']);
      expect(d.kind, ImportKind.rawSource);
      expect(d.rootPrefix, 'proj/');
    });

    test('ui.R without server.R is not raw source', () {
      final d = ImportRouter.classify(['ui.R', 'notes.txt']);
      expect(d.kind, ImportKind.unknown);
    });

    test('unrelated zip is unknown', () {
      final d = ImportRouter.classify(['readme.md', 'data.csv']);
      expect(d.kind, ImportKind.unknown);
    });

    test('prefers shinylive bundle when both markers exist', () {
      final d = ImportRouter.classify([
        'index.html', 'shinylive/x.js', 'app.R',
      ]);
      expect(d.kind, ImportKind.shinyliveBundle);
    });
  });
}
