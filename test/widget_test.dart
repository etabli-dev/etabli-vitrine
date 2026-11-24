// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitrine/app.dart';
import 'package:vitrine/data/models/shiny_app.dart';
import 'package:vitrine/data/repositories/library_repository.dart';
import 'package:vitrine/theme/theme_controller.dart';

void main() {
  testWidgets('Library shows empty display case on first launch', (
    WidgetTester tester,
  ) async {
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

  testWidgets('language, mode and accent switch at once and are stored', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'app.language': 'en'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          libraryStreamProvider.overrideWith(
            (ref) => Stream<List<ShinyApp>>.value(const []),
          ),
        ],
        child: const VitrineApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('APPEARANCE'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('settings.appearance.language')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch').last);
    await tester.pumpAndSettle();
    expect(find.text('DARSTELLUNG'), findsOneWidget);
    expect(find.text('Einstellungen'), findsOneWidget);
    expect(prefs.getString('app.language'), 'de');

    await tester.tap(find.text('Dunkel'));
    await tester.pumpAndSettle();
    final element = tester.element(find.text('DARSTELLUNG'));
    expect(Theme.of(element).brightness, Brightness.dark);
    expect(prefs.getString('appearance.mode'), 'dark');

    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Violett'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('DARSTELLUNG'))).colorScheme.primary,
      const Color(0xFFB39DDB),
    );
    expect(prefs.getString('appearance.accent'), 'purple');
    semantics.dispose();

    // Flutter's own strings follow too: the back button is "Zurück".
    expect(find.byTooltip('Zurück'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Die Vitrine ist leer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
