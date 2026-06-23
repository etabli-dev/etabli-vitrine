import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/import/import_controller.dart';
import 'features/import/share_listener.dart';
import 'routing/router.dart';
import 'theme/theme.dart';
import 'theme/theme_controller.dart';

class VitrineApp extends ConsumerStatefulWidget {
  const VitrineApp({super.key});

  @override
  ConsumerState<VitrineApp> createState() => _VitrineAppState();
}

class _VitrineAppState extends ConsumerState<VitrineApp> {
  ShareImportListener? _shareListener;

  @override
  void initState() {
    super.initState();
    _shareListener = ShareImportListener(ref.read(importControllerProvider))..start();
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
      debugShowCheckedModeBanner: false,
      theme: VitrineTheme.light(),
      darkTheme: VitrineTheme.dark(),
      themeMode: mode,
      routerConfig: appRouter,
    );
  }
}
