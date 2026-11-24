// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

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

    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
        actions: [
          IconButton(
            tooltip: l.appRename,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _rename(context, ref, app),
          ),
          IconButton(
            tooltip: l.commonDelete,
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
            label: Text(
              app.sourceType.isOfflineCapable
                  ? l.appLaunchOffline
                  : l.appOpenOnline,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    ShinyApp app,
  ) async {
    final controller = TextEditingController(text: app.name);
    final l = context.l10n;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.appRename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.appNameHint),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.commonCancel, maxLines: 1, softWrap: false),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l.commonSave, maxLines: 1, softWrap: false),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await ref.read(libraryRepositoryProvider).rename(app.id, name);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ShinyApp app,
  ) async {
    final l = context.l10n;
    final colors = VitrineColors.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.appDeleteTitle),
        content: Text(l.appDeleteBody(app.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.commonCancel, maxLines: 1, softWrap: false),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onAccent,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.commonDelete, maxLines: 1, softWrap: false),
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
    final l = context.l10n;
    final colors = VitrineColors.of(context);
    return BorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: VitrineTokens.space4),
          _row(context, l.appImported, _fmt(app.importedAt, l)),
          _row(
            context,
            l.appLastRun,
            app.lastRunAt != null ? _fmt(app.lastRunAt!, l) : l.appNever,
            semanticLabel: l.appLastRunFull,
          ),
          if (app.sourceUri != null) _row(context, l.appSource, app.sourceUri!),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    String? semanticLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VitrineTokens.space1),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 84,
              child: Text(
                label,
                semanticsLabel: semanticLabel,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            Expanded(
              child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  static Color? _statusColor(VitrineColors c, ResolutionState s) => switch (s) {
    ResolutionState.ready => c.success,
    ResolutionState.warnings => c.warn,
    ResolutionState.failed => c.error,
    _ => null,
  };

  /// Date and time in the app language's format (e.g. 24 Nov 2026, 14:05 / 24.11.2026, 14:05).
  static String _fmt(DateTime d, AppLocalizations l) =>
      DateFormat.yMMMd(l.dateLocale).add_Hm().format(d.toLocal());
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.app});
  final ShinyApp app;

  @override
  Widget build(BuildContext context) {
    final failed = app.resolutionState == ResolutionState.failed;
    final colors = VitrineColors.of(context);
    final l = context.l10n;
    final color = failed ? colors.error : colors.warn;
    return Container(
      padding: const EdgeInsets.all(VitrineTokens.space4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VitrineTokens.radius),
        border: Border.all(color: color),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            failed ? Icons.error_outline : Icons.warning_amber_outlined,
            color: color,
            size: 18,
          ),
          const SizedBox(width: VitrineTokens.space3),
          Expanded(
            child: Text(
              app.resolutionDetail != null
                  ? l.resolutionDetailText(app.resolutionDetail!)
                  : (failed ? l.appResolveFailed : l.appPackagesMaybeMissing),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
