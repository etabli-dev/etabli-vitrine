// Copyright 2026 R. Heller
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'WebR 0.6.0 (binary: GPL-3.0)',
    ], await rootBundle.loadString('assets/licenses/webr-LICENSE.md'));
    yield LicenseEntryWithLineBreaks([
      'shinylive 0.10.12',
    ], await rootBundle.loadString('assets/licenses/shinylive-LICENSE.txt'));
  });
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const VitrineApp(),
    ),
  );
}
