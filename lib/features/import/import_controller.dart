// Copyright 2026 R. Heller
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../data/models/resolution_status.dart';
import '../../data/models/shiny_app.dart';
import '../../data/models/source_type.dart';
import '../../data/repositories/library_repository.dart';
import '../../runtime/staging_service.dart';
import '../../theme/coder_theme_vitrine_tokens.dart';
import 'import_router.dart';
import 'package_resolver.dart';

final importControllerProvider = Provider<ImportController>(
  (ref) => ImportController(
    ref.watch(stagingServiceProvider),
    ref.watch(libraryRepositoryProvider),
  ),
);

/// Brings apps into the display case. Milestone 3 covers shinylive bundles
/// (the bundled sample); Files/zip/share/URL sources arrive in Milestone 5.
class ImportController {
  ImportController(this._staging, this._library);

  final StagingService _staging;
  final LibraryRepository _library;
  static const _uuid = Uuid();

  /// Imports the bundled sample app and returns its library entry. The app is
  /// embedded as source and staged for the bundled shinylive R engine, so it
  /// runs fully offline with no extra assets to ship.
  Future<ShinyApp> importSample() => importRawSourceFiles(
        {'app.R': Uint8List.fromList(utf8.encode(_sampleShinyliveAppR))},
        name: 'Sample (shinylive)',
        sourceUri: 'bundled:sample-shinylive',
      );

  static const String _sampleShinyliveAppR = '''library(shiny)

ui <- fluidPage(
  titlePanel("Établi Vitrine — sample app"),
  sidebarLayout(
    sidebarPanel(
      selectInput("var", "Variable", choices = names(mtcars), selected = "mpg"),
      sliderInput("bins", "Bins", min = 5, max = 30, value = 12)
    ),
    mainPanel(
      plotOutput("hist"),
      verbatimTextOutput("summary")
    )
  )
)

server <- function(input, output) {
  output\$hist <- renderPlot({
    hist(mtcars[[input\$var]], breaks = input\$bins,
         col = "#28A745", border = "white",
         main = input\$var, xlab = input\$var)
  })
  output\$summary <- renderPrint(summary(mtcars[[input\$var]]))
}

shinyApp(ui, server)
''';

  /// Stages a self-contained shinylive bundle and records it in the library.
  /// Shinylive bundles ship their own runtime, so they are offline-ready.
  Future<ShinyApp> importShinyliveZip(
    Uint8List zipBytes, {
    required String name,
    String? sourceUri,
  }) async {
    final id = _uuid.v4();
    await _staging.stageZip(zipBytes, id);
    final app = ShinyApp(
      id: id,
      name: name,
      sourceType: SourceType.shinyliveZip,
      resolutionState: ResolutionState.ready,
      stagedPath: id,
      sourceUri: sourceUri,
      importedAt: DateTime.now(),
    );
    await _library.upsert(app);
    return app;
  }

  // ── Import sources (Milestone 5) ────────────────────────────────────────

  /// Reject absurdly large imports before doing any work (sandboxing).
  static const int maxImportBytes = 300 * 1024 * 1024;

  /// Classifies a zip and routes it to the right importer (shinylive bundle or
  /// raw source), stripping any single wrapping folder. Throws [FormatException]
  /// if it is neither.
  Future<ShinyApp> importZipBytes(
    Uint8List zipBytes, {
    required String name,
    String? sourceUri,
  }) async {
    if (zipBytes.length > maxImportBytes) {
      throw const FormatException('Import exceeds the size limit.');
    }
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      throw const FormatException('Not a valid zip archive.');
    }
    final names = archive.where((e) => e.isFile).map((e) => e.name);
    final decision = ImportRouter.classify(names);

    switch (decision.kind) {
      case ImportKind.shinyliveBundle:
        final id = _uuid.v4();
        await _staging.stageArchiveSubtree(id, archive, decision.rootPrefix);
        final app = ShinyApp(
          id: id,
          name: name,
          sourceType: SourceType.shinyliveZip,
          resolutionState: ResolutionState.ready,
          stagedPath: id,
          sourceUri: sourceUri,
          importedAt: DateTime.now(),
        );
        await _library.upsert(app);
        return app;

      case ImportKind.rawSource:
        final files = <String, Uint8List>{};
        for (final e in archive) {
          if (!e.isFile) continue;
          final n = e.name.replaceAll('\\', '/');
          if (!n.startsWith(decision.rootPrefix)) continue;
          final rel = n.substring(decision.rootPrefix.length);
          if (rel.isEmpty) continue;
          files[rel] = Uint8List.fromList(e.content as List<int>);
        }
        return importRawSourceFiles(files, name: name, sourceUri: sourceUri);

      case ImportKind.unknown:
        throw const FormatException(
            'Not a recognized Shiny app or shinylive bundle.');
    }
  }

  /// Downloads a `.zip` from [url] and imports it.
  Future<ShinyApp> importUrl(String url, {String? name}) async {
    final uri = Uri.parse(url);
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw FormatException('Download failed (HTTP ${resp.statusCode}).');
    }
    final fallbackName = p.basenameWithoutExtension(uri.path);
    return importZipBytes(
      resp.bodyBytes,
      name: name ?? (fallbackName.isEmpty ? 'Imported app' : fallbackName),
      sourceUri: url,
    );
  }

  // ── Raw Shiny source (Milestone 4) ──────────────────────────────────────

  static const String _sampleAppR = '''library(shiny)

ui <- fluidPage(
  titlePanel("Établi Vitrine — Raw R sample"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins", "Number of bins", min = 1, max = 50, value = 30)
    ),
    mainPanel(plotOutput("distPlot"))
  )
)

server <- function(input, output) {
  output\$distPlot <- renderPlot({
    x <- faithful\$waiting
    bins <- seq(min(x), max(x), length.out = input\$bins + 1)
    hist(x, breaks = bins, col = "${VitrineTokens.accentHex}", border = "white",
         xlab = "Waiting time to next eruption (mins)",
         main = "Old Faithful — rendered offline by WebR")
  })
}

shinyApp(ui, server)
''';

  /// Imports the embedded raw-source sample app.
  Future<ShinyApp> importSampleRaw() => importRawSourceFiles(
        {'app.R': Uint8List.fromList(utf8.encode(_sampleAppR))},
        name: 'Raw R sample',
      );

  /// Stages raw Shiny source as a shinylive `app.json`, resolves packages, and
  /// records the library entry. Text files (.R, .csv, …) become `type:text`
  /// entries; everything else is base64 `type:binary`. The shared shinylive R
  /// engine runs it at launch.
  Future<ShinyApp> importRawSourceFiles(
    Map<String, Uint8List> files, {
    required String name,
    String? sourceUri,
  }) async {
    if (!_looksLikeShinyApp(files.keys)) {
      throw const FormatException(
          'No app.R (or ui.R + server.R) found in the source.');
    }
    final id = _uuid.v4();
    final textBlob = StringBuffer();
    final entries = <Map<String, String>>[];
    for (final e in files.entries) {
      if (ImportRouter.isTextSource(e.key)) {
        final content = utf8.decode(e.value, allowMalformed: true);
        textBlob.writeln(content);
        entries.add({'name': e.key, 'content': content, 'type': 'text'});
      } else {
        entries.add({'name': e.key, 'content': base64Encode(e.value), 'type': 'binary'});
      }
    }
    await _staging.writeStagedFile(id, 'app.json', utf8.encode(jsonEncode(entries)));

    final resolution = PackageResolver.resolve(textBlob.toString());
    final app = ShinyApp(
      id: id,
      name: name,
      sourceType: SourceType.rawSource,
      resolutionState: resolution.state,
      resolutionDetail: resolution.detail,
      stagedPath: id,
      sourceUri: sourceUri,
      importedAt: DateTime.now(),
    );
    await _library.upsert(app);
    return app;
  }

  bool _looksLikeShinyApp(Iterable<String> fileNames) {
    final names = fileNames.map((k) => p.basename(k).toLowerCase()).toSet();
    return names.contains('app.r') ||
        (names.contains('ui.r') && names.contains('server.r'));
  }

  /// Deletes a library entry and its staged files.
  Future<void> deleteApp(ShinyApp app) async {
    if (app.stagedPath != null) await _staging.remove(app.stagedPath!);
    await _library.delete(app.id);
  }
}
