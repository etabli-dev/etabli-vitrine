// Copyright 2026 Raban Heller
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/resolution_status.dart';
import '../../data/models/shiny_app.dart';
import '../../data/repositories/library_repository.dart';
import '../../theme/coder_theme_vitrine_tokens.dart';
import '../../widgets/bordered_card.dart';
import '../../widgets/mono_label.dart';
import '../import/import_controller.dart';
import 'launch.dart';

/// Per-app metadata + management. Watches the library so edits (rename) and
/// deletes reflect live; pops if the entry disappears.
class AppDetailScreen extends ConsumerWidget {
  const AppDetailScreen({super.key, required this.appId});

  final String appId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(libraryStreamProvider);
    final app = apps.value?.where((a) => a.id == appId).firstOrNull;

    if (apps.hasValue && app == null) {
      // Deleted elsewhere — leave the detail view.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.canPop()) context.pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    if (app == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
        actions: [
          IconButton(
            tooltip: 'Rename',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _rename(context, ref, app),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref, app),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(VitrineTokens.space4),
        children: [
          _MetaCard(app: app),
          if (app.resolutionState == ResolutionState.warnings ||
              app.resolutionState == ResolutionState.failed)
            Padding(
              padding: const EdgeInsets.only(top: VitrineTokens.space3),
              child: _WarningCard(app: app),
            ),
          const SizedBox(height: VitrineTokens.space5),
          FilledButton.icon(
            onPressed: () => launchApp(context, ref, app),
            icon: const Icon(Icons.play_arrow),
            label: Text(app.sourceType.isOfflineCapable
                ? 'Launch (offline)'
                : 'Open (online)'),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, ShinyApp app) async {
    final controller = TextEditingController(text: app.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'App name'),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await ref.read(libraryRepositoryProvider).rename(app.id, name);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ShinyApp app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete app?'),
        content: Text('Remove "${app.name}" and its staged files? '
            'This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VitrineTokens.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(importControllerProvider).deleteApp(app);
    // The live watch will pop the screen once the entry is gone.
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.app});
  final ShinyApp app;

  @override
  Widget build(BuildContext context) {
    return BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: VitrineTokens.space2,
            runSpacing: VitrineTokens.space2,
            children: [
              MonoTag(app.sourceType.label),
              MonoTag(app.resolutionState.label,
                  color: _statusColor(app.resolutionState)),
              if (!app.sourceType.isOfflineCapable)
                const MonoTag('Online only', color: VitrineTokens.warn),
            ],
          ),
          const SizedBox(height: VitrineTokens.space4),
          _row(context, 'Imported', _fmt(app.importedAt)),
          _row(context, 'Last run',
              app.lastRunAt != null ? _fmt(app.lastRunAt!) : 'Never'),
          if (app.sourceUri != null) _row(context, 'Source', app.sourceUri!),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VitrineTokens.space1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  static Color? _statusColor(ResolutionState s) => switch (s) {
        ResolutionState.ready => VitrineTokens.accent,
        ResolutionState.warnings => VitrineTokens.warn,
        ResolutionState.failed => VitrineTokens.error,
        _ => null,
      };

  static String _fmt(DateTime d) {
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.app});
  final ShinyApp app;

  @override
  Widget build(BuildContext context) {
    final failed = app.resolutionState == ResolutionState.failed;
    final color = failed ? VitrineTokens.error : VitrineTokens.warn;
    return Container(
      padding: const EdgeInsets.all(VitrineTokens.space4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VitrineTokens.radius),
        border: Border.all(color: color),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(failed ? Icons.error_outline : Icons.warning_amber_outlined,
              color: color, size: 18),
          const SizedBox(width: VitrineTokens.space3),
          Expanded(
            child: Text(
              app.resolutionDetail ??
                  (failed ? 'This app failed to resolve.' : 'Some packages may be unavailable.'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
