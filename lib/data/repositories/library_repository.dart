import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../models/resolution_status.dart';
import '../models/shiny_app.dart';
import '../models/source_type.dart';

final databaseProvider = Provider<VitrineDatabase>((ref) {
  final db = VitrineDatabase();
  ref.onDispose(db.close);
  return db;
});

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(ref.watch(databaseProvider)),
);

/// Reactive list of display-case entries, newest import first.
final libraryStreamProvider = StreamProvider<List<ShinyApp>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchAll(),
);

/// CRUD over the display case. Staging of files on disk is handled by the
/// import layer (later milestones); this owns only the metadata store.
class LibraryRepository {
  LibraryRepository(this._db);

  final VitrineDatabase _db;

  Stream<List<ShinyApp>> watchAll() {
    final query = _db.select(_db.libraryApps)
      ..orderBy([(t) => OrderingTerm.desc(t.importedAt)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<void> upsert(ShinyApp app) =>
      _db.into(_db.libraryApps).insertOnConflictUpdate(_toRow(app));

  Future<void> rename(String id, String name) =>
      (_db.update(_db.libraryApps)..where((t) => t.id.equals(id)))
          .write(LibraryAppsCompanion(name: Value(name)));

  Future<void> delete(String id) =>
      (_db.delete(_db.libraryApps)..where((t) => t.id.equals(id))).go();

  Future<void> touchLastRun(String id, DateTime when) =>
      (_db.update(_db.libraryApps)..where((t) => t.id.equals(id)))
          .write(LibraryAppsCompanion(lastRunAt: Value(when)));

  ShinyApp _toDomain(LibraryApp r) => ShinyApp(
        id: r.id,
        name: r.name,
        sourceType: SourceType.values[r.sourceType],
        resolutionState: ResolutionState.values[r.resolutionState],
        resolutionDetail: r.resolutionDetail,
        stagedPath: r.stagedPath,
        sourceUri: r.sourceUri,
        importedAt: r.importedAt,
        lastRunAt: r.lastRunAt,
      );

  LibraryAppsCompanion _toRow(ShinyApp a) => LibraryAppsCompanion(
        id: Value(a.id),
        name: Value(a.name),
        sourceType: Value(a.sourceType.index),
        resolutionState: Value(a.resolutionState.index),
        resolutionDetail: Value(a.resolutionDetail),
        stagedPath: Value(a.stagedPath),
        sourceUri: Value(a.sourceUri),
        importedAt: Value(a.importedAt),
        lastRunAt: Value(a.lastRunAt),
      );
}
