import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/resolution_status.dart';
import '../../data/models/shiny_app.dart';
import '../../theme/tokens.dart';

/// Launches an app, surfacing package-resolution warnings first so the user
/// knows before a (possibly failing) offline run.
Future<void> launchApp(BuildContext context, WidgetRef ref, ShinyApp app) async {
  final needsConfirm = app.resolutionState == ResolutionState.warnings ||
      app.resolutionState == ResolutionState.failed;

  if (needsConfirm) {
    final failed = app.resolutionState == ResolutionState.failed;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(failed ? 'Resolution failed' : 'Package warnings'),
        content: Text(
          '${app.resolutionDetail ?? 'Some packages may be unavailable.'}\n\n'
          'Launch anyway? Missing packages would need a connection at launch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: failed
                ? FilledButton.styleFrom(backgroundColor: VitrineTokens.warn)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Launch anyway'),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;
  }

  context.push('/run', extra: app);
}
