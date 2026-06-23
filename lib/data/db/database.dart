import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'database.g.dart';

/// One imported app in the display case. Staged files live on disk; this row
/// holds the metadata and a reference (relative path under the app's staging
/// directory) so the library can list and relaunch entries.
class LibraryApps extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get name => text()();
  IntColumn get sourceType => integer()(); // SourceType.index
  IntColumn get resolutionState => integer()(); // ResolutionState.index
  TextColumn get resolutionDetail => text().nullable()(); // warnings/errors
  TextColumn get stagedPath => text().nullable()(); // relative staging dir
  TextColumn get sourceUri => text().nullable()(); // original source (url/file)
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get lastRunAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LibraryApps])
class VitrineDatabase extends _$VitrineDatabase {
  VitrineDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'vitrine.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
