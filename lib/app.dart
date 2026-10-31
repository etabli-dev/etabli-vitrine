// Copyright 2026 R. Heller
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/import/import_controller.dart';
import 'features/import/share_listener.dart';
import 'routing/router.dart';
import 'theme/coder_theme_vitrine.dart';
import 'theme/theme_controller.dart';

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
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Établi Vitrine',
      scaffoldMessengerKey: _messenger,
      debugShowCheckedModeBanner: false,
      theme: VitrineTheme.light(),
      darkTheme: VitrineTheme.dark(),
      themeMode: mode,
      routerConfig: appRouter,
    );
  }
}
