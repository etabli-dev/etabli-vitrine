// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/import/import_controller.dart';
import 'features/import/share_listener.dart';
import 'l10n/l10n.dart';
import 'routing/router.dart';
import 'theme/coder_theme_vitrine.dart';
import 'theme/theme_controller.dart';

/// The app's and Flutter's own (Material, Cupertino, widgets) German and English strings.
const List<LocalizationsDelegate<Object>> vitrineLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class VitrineApp extends ConsumerStatefulWidget {
  const VitrineApp({super.key});

  @override
  ConsumerState<VitrineApp> createState() => _VitrineAppState();
}

class _VitrineAppState extends ConsumerState<VitrineApp> {
  ShareImportListener? _shareListener;
  final _messenger = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _shareListener = ShareImportListener(
      ref.read(importControllerProvider),
      onError: (message) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _messenger.currentState?.showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 10),
              ),
            );
          }
        });
      },
    )..start();
  }

  @override
  void dispose() {
    _shareListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appearanceModeProvider);
    final accent = ref.watch(accentProvider);
    final language = ref.watch(appLanguageProvider);
    return MaterialApp.router(
      title: 'Établi Vitrine',
      scaffoldMessengerKey: _messenger,
      debugShowCheckedModeBanner: false,
      theme: VitrineTheme.light(accent),
      darkTheme: VitrineTheme.dark(accent),
      themeMode: mode.themeMode,
      // null follows the device; English (listed first) is the fallback for other device languages.
      locale: language.locale,
      supportedLocales: appSupportedLocales,
      localizationsDelegates: vitrineLocalizationsDelegates,
      builder: (context, child) {
        // Texts made outside widgets (share import errors) follow the same language.
        L10n.update(Localizations.localeOf(context));
        return child ?? const SizedBox.shrink();
      },
      routerConfig: appRouter,
    );
  }
}
