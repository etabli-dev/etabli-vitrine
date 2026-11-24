// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/resolution_status.dart';
import '../../data/models/shiny_app.dart';
import '../../data/repositories/library_repository.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../theme/coder_theme_vitrine.dart';
import '../../theme/coder_theme_vitrine_tokens.dart';
import '../../widgets/bordered_card.dart';
import '../../widgets/mono_label.dart';
import '../import/import_controller.dart';
import 'launch.dart';

/// The display case — persisted shelf of imported apps.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryStreamProvider);
    final l = context.l10n;
    final colors = VitrineColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.libraryTitle),
        actions: [
          IconButton(
            tooltip: l.librarySettings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showImportSheet(context, ref),
        icon: const Icon(Icons.add),
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        label: Text(l.libraryImport, maxLines: 1, softWrap: false),
      ),
      body: library.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.libraryLoadFailed('$e'))),
        data: (apps) =>
            apps.isEmpty ? const _EmptyCase() : _LibraryList(apps: apps),
      ),
    );
  }

  Future<void> _showImportSheet(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final accent = VitrineColors.of(context).accent;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VitrineTokens.space4,
                0,
                VitrineTokens.space4,
                VitrineTokens.space2,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.importSheetTitle,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.folder_open, color: accent),
              title: Text(l.importFromFiles),
              subtitle: Text(l.importFromFilesHint),
              onTap: () => Navigator.pop(context, 'files'),
            ),
            ListTile(
              leading: Icon(Icons.link, color: accent),
              title: Text(l.importFromUrl),
              subtitle: Text(l.importFromUrlHint),
              onTap: () => Navigator.pop(context, 'url'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: Text(l.importSampleShinylive),
              subtitle: Text(l.importSampleShinyliveHint),
              onTap: () => Navigator.pop(context, 'sample'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: Text(l.importSampleRaw),
              subtitle: Text(l.importSampleRawHint),
              onTap: () => Navigator.pop(context, 'sampleRaw'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    switch (choice) {
      case 'sample':
        await _runImport(context, ref, (c) => c.importSample());
      case 'sampleRaw':
        await _runImport(context, ref, (c) => c.importSampleRaw());
      case 'files':
        await _importFromFiles(context, ref);
      case 'url':
        await _importFromUrl(context, ref);
    }
  }

  Future<void> _importFromFiles(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;

    final files = {
      for (final f in result.files)
        if (f.bytes != null) f.name: f.bytes!,
    };
    if (files.length == 1 && files.keys.first.toLowerCase().endsWith('.zip')) {
      final entry = files.entries.first;
      final name = entry.key.replaceAll(
        RegExp(r'\.zip$', caseSensitive: false),
        '',
      );
      await _runImport(
        context,
        ref,
        (c) => c.importZipBytes(entry.value, name: name, sourceUri: entry.key),
      );
    } else {
      await _runImport(
        context,
        ref,
        (c) =>
            c.importRawSourceFiles(files, name: context.l10n.importDefaultName),
      );
    }
  }

  Future<void> _importFromUrl(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final l = context.l10n;
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.importUrlTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com/app.zip',
          ),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.commonCancel, maxLines: 1, softWrap: false),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l.libraryImport, maxLines: 1, softWrap: false),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty || !context.mounted) return;
    await _runImport(context, ref, (c) => c.importUrl(url));
  }

  /// Runs an import action with progress + error feedback.
  Future<void> _runImport(
    BuildContext context,
    WidgetRef ref,
    Future<Object?> Function(ImportController) action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l10n;
    messenger.showSnackBar(SnackBar(content: Text(l.importing)));
    try {
      await action(ref.read(importControllerProvider));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.imported)));
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l.importFailed(l.importErrorText(e)))),
        );
    }
  }
}

class _EmptyCase extends StatelessWidget {
  const _EmptyCase();

  @override
  Widget build(BuildContext context) {
    final colors = VitrineColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VitrineTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: colors.textMuted),
            const SizedBox(height: VitrineTokens.space4),
            Text(
              context.l10n.emptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: VitrineTokens.space2),
            Text(
              context.l10n.emptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryList extends StatelessWidget {
  const _LibraryList({required this.apps});

  final List<ShinyApp> apps;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(VitrineTokens.space4),
      itemCount: apps.length,
      separatorBuilder: (_, _) => const SizedBox(height: VitrineTokens.space3),
      itemBuilder: (context, i) => _AppTile(app: apps[i]),
    );
  }
}

class _AppTile extends ConsumerWidget {
  const _AppTile({required this.app});

  final ShinyApp app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final colors = VitrineColors.of(context);
    return BorderedCard(
      onTap: () => launchApp(context, ref, app),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: VitrineTokens.space2),
                Wrap(
                  spacing: VitrineTokens.space2,
                  runSpacing: VitrineTokens.space2,
                  children: [
                    MonoTag(l.sourceTypeLabel(app.sourceType)),
                    MonoTag(
                      l.resolutionLabel(app.resolutionState),
                      color: _statusColor(colors, app.resolutionState),
                    ),
                    if (!app.sourceType.isOfflineCapable)
                      MonoTag(l.tagOnlineOnly, color: colors.warn),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.appDetailsFor(app.name),
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push('/app/${app.id}'),
          ),
        ],
      ),
    );
  }

  Color? _statusColor(VitrineColors c, ResolutionState s) => switch (s) {
    ResolutionState.ready => c.success,
    ResolutionState.warnings => c.warn,
    ResolutionState.failed => c.error,
    _ => null,
  };
}
