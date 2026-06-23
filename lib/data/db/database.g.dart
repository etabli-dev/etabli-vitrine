// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LibraryAppsTable extends LibraryApps
    with TableInfo<$LibraryAppsTable, LibraryApp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryAppsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<int> sourceType = GeneratedColumn<int>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionStateMeta = const VerificationMeta(
    'resolutionState',
  );
  @override
  late final GeneratedColumn<int> resolutionState = GeneratedColumn<int>(
    'resolution_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionDetailMeta = const VerificationMeta(
    'resolutionDetail',
  );
  @override
  late final GeneratedColumn<String> resolutionDetail = GeneratedColumn<String>(
    'resolution_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stagedPathMeta = const VerificationMeta(
    'stagedPath',
  );
  @override
  late final GeneratedColumn<String> stagedPath = GeneratedColumn<String>(
    'staged_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUriMeta = const VerificationMeta(
    'sourceUri',
  );
  @override
  late final GeneratedColumn<String> sourceUri = GeneratedColumn<String>(
    'source_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastRunAtMeta = const VerificationMeta(
    'lastRunAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRunAt = GeneratedColumn<DateTime>(
    'last_run_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sourceType,
    resolutionState,
    resolutionDetail,
    stagedPath,
    sourceUri,
    importedAt,
    lastRunAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryApp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('resolution_state')) {
      context.handle(
        _resolutionStateMeta,
        resolutionState.isAcceptableOrUnknown(
          data['resolution_state']!,
          _resolutionStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolutionStateMeta);
    }
    if (data.containsKey('resolution_detail')) {
      context.handle(
        _resolutionDetailMeta,
        resolutionDetail.isAcceptableOrUnknown(
          data['resolution_detail']!,
          _resolutionDetailMeta,
        ),
      );
    }
    if (data.containsKey('staged_path')) {
      context.handle(
        _stagedPathMeta,
        stagedPath.isAcceptableOrUnknown(data['staged_path']!, _stagedPathMeta),
      );
    }
    if (data.containsKey('source_uri')) {
      context.handle(
        _sourceUriMeta,
        sourceUri.isAcceptableOrUnknown(data['source_uri']!, _sourceUriMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('last_run_at')) {
      context.handle(
        _lastRunAtMeta,
        lastRunAt.isAcceptableOrUnknown(data['last_run_at']!, _lastRunAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryApp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryApp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_type'],
      )!,
      resolutionState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolution_state'],
      )!,
      resolutionDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_detail'],
      ),
      stagedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staged_path'],
      ),
      sourceUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_uri'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      lastRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_run_at'],
      ),
    );
  }

  @override
  $LibraryAppsTable createAlias(String alias) {
    return $LibraryAppsTable(attachedDatabase, alias);
  }
}

class LibraryApp extends DataClass implements Insertable<LibraryApp> {
  final String id;
  final String name;
  final int sourceType;
  final int resolutionState;
  final String? resolutionDetail;
  final String? stagedPath;
  final String? sourceUri;
  final DateTime importedAt;
  final DateTime? lastRunAt;
  const LibraryApp({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.resolutionState,
    this.resolutionDetail,
    this.stagedPath,
    this.sourceUri,
    required this.importedAt,
    this.lastRunAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['source_type'] = Variable<int>(sourceType);
    map['resolution_state'] = Variable<int>(resolutionState);
    if (!nullToAbsent || resolutionDetail != null) {
      map['resolution_detail'] = Variable<String>(resolutionDetail);
    }
    if (!nullToAbsent || stagedPath != null) {
      map['staged_path'] = Variable<String>(stagedPath);
    }
    if (!nullToAbsent || sourceUri != null) {
      map['source_uri'] = Variable<String>(sourceUri);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || lastRunAt != null) {
      map['last_run_at'] = Variable<DateTime>(lastRunAt);
    }
    return map;
  }

  LibraryAppsCompanion toCompanion(bool nullToAbsent) {
    return LibraryAppsCompanion(
      id: Value(id),
      name: Value(name),
      sourceType: Value(sourceType),
      resolutionState: Value(resolutionState),
      resolutionDetail: resolutionDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionDetail),
      stagedPath: stagedPath == null && nullToAbsent
          ? const Value.absent()
          : Value(stagedPath),
      sourceUri: sourceUri == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUri),
      importedAt: Value(importedAt),
      lastRunAt: lastRunAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRunAt),
    );
  }

  factory LibraryApp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryApp(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sourceType: serializer.fromJson<int>(json['sourceType']),
      resolutionState: serializer.fromJson<int>(json['resolutionState']),
      resolutionDetail: serializer.fromJson<String?>(json['resolutionDetail']),
      stagedPath: serializer.fromJson<String?>(json['stagedPath']),
      sourceUri: serializer.fromJson<String?>(json['sourceUri']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      lastRunAt: serializer.fromJson<DateTime?>(json['lastRunAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sourceType': serializer.toJson<int>(sourceType),
      'resolutionState': serializer.toJson<int>(resolutionState),
      'resolutionDetail': serializer.toJson<String?>(resolutionDetail),
      'stagedPath': serializer.toJson<String?>(stagedPath),
      'sourceUri': serializer.toJson<String?>(sourceUri),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'lastRunAt': serializer.toJson<DateTime?>(lastRunAt),
    };
  }

  LibraryApp copyWith({
    String? id,
    String? name,
    int? sourceType,
    int? resolutionState,
    Value<String?> resolutionDetail = const Value.absent(),
    Value<String?> stagedPath = const Value.absent(),
    Value<String?> sourceUri = const Value.absent(),
    DateTime? importedAt,
    Value<DateTime?> lastRunAt = const Value.absent(),
  }) => LibraryApp(
    id: id ?? this.id,
    name: name ?? this.name,
    sourceType: sourceType ?? this.sourceType,
    resolutionState: resolutionState ?? this.resolutionState,
    resolutionDetail: resolutionDetail.present
        ? resolutionDetail.value
        : this.resolutionDetail,
    stagedPath: stagedPath.present ? stagedPath.value : this.stagedPath,
    sourceUri: sourceUri.present ? sourceUri.value : this.sourceUri,
    importedAt: importedAt ?? this.importedAt,
    lastRunAt: lastRunAt.present ? lastRunAt.value : this.lastRunAt,
  );
  LibraryApp copyWithCompanion(LibraryAppsCompanion data) {
    return LibraryApp(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      resolutionState: data.resolutionState.present
          ? data.resolutionState.value
          : this.resolutionState,
      resolutionDetail: data.resolutionDetail.present
          ? data.resolutionDetail.value
          : this.resolutionDetail,
      stagedPath: data.stagedPath.present
          ? data.stagedPath.value
          : this.stagedPath,
      sourceUri: data.sourceUri.present ? data.sourceUri.value : this.sourceUri,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      lastRunAt: data.lastRunAt.present ? data.lastRunAt.value : this.lastRunAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryApp(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sourceType: $sourceType, ')
          ..write('resolutionState: $resolutionState, ')
          ..write('resolutionDetail: $resolutionDetail, ')
          ..write('stagedPath: $stagedPath, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('importedAt: $importedAt, ')
          ..write('lastRunAt: $lastRunAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sourceType,
    resolutionState,
    resolutionDetail,
    stagedPath,
    sourceUri,
    importedAt,
    lastRunAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryApp &&
          other.id == this.id &&
          other.name == this.name &&
          other.sourceType == this.sourceType &&
          other.resolutionState == this.resolutionState &&
          other.resolutionDetail == this.resolutionDetail &&
          other.stagedPath == this.stagedPath &&
          other.sourceUri == this.sourceUri &&
          other.importedAt == this.importedAt &&
          other.lastRunAt == this.lastRunAt);
}

class LibraryAppsCompanion extends UpdateCompanion<LibraryApp> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sourceType;
  final Value<int> resolutionState;
  final Value<String?> resolutionDetail;
  final Value<String?> stagedPath;
  final Value<String?> sourceUri;
  final Value<DateTime> importedAt;
  final Value<DateTime?> lastRunAt;
  final Value<int> rowid;
  const LibraryAppsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.resolutionState = const Value.absent(),
    this.resolutionDetail = const Value.absent(),
    this.stagedPath = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.lastRunAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryAppsCompanion.insert({
    required String id,
    required String name,
    required int sourceType,
    required int resolutionState,
    this.resolutionDetail = const Value.absent(),
    this.stagedPath = const Value.absent(),
    this.sourceUri = const Value.absent(),
    required DateTime importedAt,
    this.lastRunAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sourceType = Value(sourceType),
       resolutionState = Value(resolutionState),
       importedAt = Value(importedAt);
  static Insertable<LibraryApp> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sourceType,
    Expression<int>? resolutionState,
    Expression<String>? resolutionDetail,
    Expression<String>? stagedPath,
    Expression<String>? sourceUri,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? lastRunAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sourceType != null) 'source_type': sourceType,
      if (resolutionState != null) 'resolution_state': resolutionState,
      if (resolutionDetail != null) 'resolution_detail': resolutionDetail,
      if (stagedPath != null) 'staged_path': stagedPath,
      if (sourceUri != null) 'source_uri': sourceUri,
      if (importedAt != null) 'imported_at': importedAt,
      if (lastRunAt != null) 'last_run_at': lastRunAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryAppsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sourceType,
    Value<int>? resolutionState,
    Value<String?>? resolutionDetail,
    Value<String?>? stagedPath,
    Value<String?>? sourceUri,
    Value<DateTime>? importedAt,
    Value<DateTime?>? lastRunAt,
    Value<int>? rowid,
  }) {
    return LibraryAppsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceType: sourceType ?? this.sourceType,
      resolutionState: resolutionState ?? this.resolutionState,
      resolutionDetail: resolutionDetail ?? this.resolutionDetail,
      stagedPath: stagedPath ?? this.stagedPath,
      sourceUri: sourceUri ?? this.sourceUri,
      importedAt: importedAt ?? this.importedAt,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<int>(sourceType.value);
    }
    if (resolutionState.present) {
      map['resolution_state'] = Variable<int>(resolutionState.value);
    }
    if (resolutionDetail.present) {
      map['resolution_detail'] = Variable<String>(resolutionDetail.value);
    }
    if (stagedPath.present) {
      map['staged_path'] = Variable<String>(stagedPath.value);
    }
    if (sourceUri.present) {
      map['source_uri'] = Variable<String>(sourceUri.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (lastRunAt.present) {
      map['last_run_at'] = Variable<DateTime>(lastRunAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryAppsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sourceType: $sourceType, ')
          ..write('resolutionState: $resolutionState, ')
          ..write('resolutionDetail: $resolutionDetail, ')
          ..write('stagedPath: $stagedPath, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('importedAt: $importedAt, ')
          ..write('lastRunAt: $lastRunAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VitrineDatabase extends GeneratedDatabase {
  _$VitrineDatabase(QueryExecutor e) : super(e);
  $VitrineDatabaseManager get managers => $VitrineDatabaseManager(this);
  late final $LibraryAppsTable libraryApps = $LibraryAppsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [libraryApps];
}

typedef $$LibraryAppsTableCreateCompanionBuilder =
    LibraryAppsCompanion Function({
      required String id,
      required String name,
      required int sourceType,
      required int resolutionState,
      Value<String?> resolutionDetail,
      Value<String?> stagedPath,
      Value<String?> sourceUri,
      required DateTime importedAt,
      Value<DateTime?> lastRunAt,
      Value<int> rowid,
    });
typedef $$LibraryAppsTableUpdateCompanionBuilder =
    LibraryAppsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> sourceType,
      Value<int> resolutionState,
      Value<String?> resolutionDetail,
      Value<String?> stagedPath,
      Value<String?> sourceUri,
      Value<DateTime> importedAt,
      Value<DateTime?> lastRunAt,
      Value<int> rowid,
    });

class $$LibraryAppsTableFilterComposer
    extends Composer<_$VitrineDatabase, $LibraryAppsTable> {
  $$LibraryAppsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolutionState => $composableBuilder(
    column: $table.resolutionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionDetail => $composableBuilder(
    column: $table.resolutionDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stagedPath => $composableBuilder(
    column: $table.stagedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRunAt => $composableBuilder(
    column: $table.lastRunAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryAppsTableOrderingComposer
    extends Composer<_$VitrineDatabase, $LibraryAppsTable> {
  $$LibraryAppsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolutionState => $composableBuilder(
    column: $table.resolutionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionDetail => $composableBuilder(
    column: $table.resolutionDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stagedPath => $composableBuilder(
    column: $table.stagedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRunAt => $composableBuilder(
    column: $table.lastRunAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryAppsTableAnnotationComposer
    extends Composer<_$VitrineDatabase, $LibraryAppsTable> {
  $$LibraryAppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolutionState => $composableBuilder(
    column: $table.resolutionState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolutionDetail => $composableBuilder(
    column: $table.resolutionDetail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stagedPath => $composableBuilder(
    column: $table.stagedPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUri =>
      $composableBuilder(column: $table.sourceUri, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastRunAt =>
      $composableBuilder(column: $table.lastRunAt, builder: (column) => column);
}

class $$LibraryAppsTableTableManager
    extends
        RootTableManager<
          _$VitrineDatabase,
          $LibraryAppsTable,
          LibraryApp,
          $$LibraryAppsTableFilterComposer,
          $$LibraryAppsTableOrderingComposer,
          $$LibraryAppsTableAnnotationComposer,
          $$LibraryAppsTableCreateCompanionBuilder,
          $$LibraryAppsTableUpdateCompanionBuilder,
          (
            LibraryApp,
            BaseReferences<_$VitrineDatabase, $LibraryAppsTable, LibraryApp>,
          ),
          LibraryApp,
          PrefetchHooks Function()
        > {
  $$LibraryAppsTableTableManager(_$VitrineDatabase db, $LibraryAppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryAppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryAppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryAppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sourceType = const Value.absent(),
                Value<int> resolutionState = const Value.absent(),
                Value<String?> resolutionDetail = const Value.absent(),
                Value<String?> stagedPath = const Value.absent(),
                Value<String?> sourceUri = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<DateTime?> lastRunAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryAppsCompanion(
                id: id,
                name: name,
                sourceType: sourceType,
                resolutionState: resolutionState,
                resolutionDetail: resolutionDetail,
                stagedPath: stagedPath,
                sourceUri: sourceUri,
                importedAt: importedAt,
                lastRunAt: lastRunAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int sourceType,
                required int resolutionState,
                Value<String?> resolutionDetail = const Value.absent(),
                Value<String?> stagedPath = const Value.absent(),
                Value<String?> sourceUri = const Value.absent(),
                required DateTime importedAt,
                Value<DateTime?> lastRunAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryAppsCompanion.insert(
                id: id,
                name: name,
                sourceType: sourceType,
                resolutionState: resolutionState,
                resolutionDetail: resolutionDetail,
                stagedPath: stagedPath,
                sourceUri: sourceUri,
                importedAt: importedAt,
                lastRunAt: lastRunAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryAppsTableProcessedTableManager =
    ProcessedTableManager<
      _$VitrineDatabase,
      $LibraryAppsTable,
      LibraryApp,
      $$LibraryAppsTableFilterComposer,
      $$LibraryAppsTableOrderingComposer,
      $$LibraryAppsTableAnnotationComposer,
      $$LibraryAppsTableCreateCompanionBuilder,
      $$LibraryAppsTableUpdateCompanionBuilder,
      (
        LibraryApp,
        BaseReferences<_$VitrineDatabase, $LibraryAppsTable, LibraryApp>,
      ),
      LibraryApp,
      PrefetchHooks Function()
    >;

class $VitrineDatabaseManager {
  final _$VitrineDatabase _db;
  $VitrineDatabaseManager(this._db);
  $$LibraryAppsTableTableManager get libraryApps =>
      $$LibraryAppsTableTableManager(_db, _db.libraryApps);
}
