// Copyright 2026 Raban Heller
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitrine/app.dart';
import 'package:vitrine/data/models/shiny_app.dart';
import 'package:vitrine/data/repositories/library_repository.dart';
import 'package:vitrine/theme/theme_controller.dart';

void main() {
  testWidgets('Library shows empty display case on first launch',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          // Avoid the native Drift/path_provider stack in the test VM by
          // feeding an empty library directly.
          libraryStreamProvider.overrideWith(
            (ref) => Stream<List<ShinyApp>>.value(const []),
          ),
        ],
        child: const VitrineApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Établi Vitrine'), findsOneWidget);
    expect(find.text('The display case is empty'), findsOneWidget);
  });
}
