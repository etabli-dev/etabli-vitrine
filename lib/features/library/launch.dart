// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/resolution_status.dart';
import '../../data/models/shiny_app.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../theme/coder_theme_vitrine.dart';

/// Launches an app, surfacing package-resolution warnings first so the user
/// knows before a (possibly failing) offline run.
Future<void> launchApp(
  BuildContext context,
  WidgetRef ref,
  ShinyApp app,
) async {
  final needsConfirm =
      app.resolutionState == ResolutionState.warnings ||
      app.resolutionState == ResolutionState.failed;

  if (needsConfirm) {
    final failed = app.resolutionState == ResolutionState.failed;
    final l = context.l10n;
    final colors = VitrineColors.of(context);
    final detail = app.resolutionDetail != null
        ? l.resolutionDetailText(app.resolutionDetail!)
        : l.appPackagesMaybeMissing;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          failed ? l.launchResolutionFailed : l.launchPackageWarnings,
        ),
        content: Text(l.launchAnywayBody(detail)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.commonCancel, maxLines: 1, softWrap: false),
          ),
          FilledButton(
            style: failed
                ? FilledButton.styleFrom(
                    backgroundColor: colors.warn,
                    foregroundColor: colors.onAccent,
                  )
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.launchAnyway, maxLines: 1, softWrap: false),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;
  }

  context.push('/run', extra: app);
}
