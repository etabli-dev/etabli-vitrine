// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

// Screenshot tour on a simulator or device: library, import sheet and dialogs, app details, the running
// sample app, settings and the WebR console in English and German, plus dark mode with the yellow accent.
// Run it with
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/tour_test.dart -d <device>
//
// The screenshots land in build/tour/ (git-ignored).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vitrine/app.dart';
import 'package:vitrine/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshot tour', (tester) async {
    await app.main();

    Future<void> settle([int ms = 700]) async {
      for (var t = 0; t < ms; t += 50) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    for (var i = 0; i < 80 && find.byType(VitrineApp).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await settle(1500);
    final view = tester.view;
    final device = view.physicalSize.width / view.devicePixelRatio >= 600
        ? 'ipad'
        : 'phone';
    var lang = 'en';
    var n = 0;

    Future<void> shot(String name) async {
      await settle();
      n++;
      final id = '$device-$lang-${n.toString().padLeft(2, '0')}-$name';
      await binding.takeScreenshot(id);
      debugPrint('TOUR: screenshot $id');
    }

    Future<void> tap(Finder finder) async {
      await tester.tap(finder.hitTestable().first);
      await settle();
    }

    Future<void> back() => tap(find.byType(BackButton));

    Future<void> dismiss() async {
      await tester.tapAt(const Offset(8, 120));
      await settle();
    }

    Future<void> openSettings() => tap(find.byIcon(Icons.settings_outlined));

    Future<void> setLanguage(String option) async {
      await openSettings();
      await tap(find.byKey(const ValueKey('settings.appearance.language')));
      await tap(find.text(option));
      await back();
    }

    Future<void> setLook(int mode, String accent) async {
      await openSettings();
      await tap(
        find
            .descendant(
              of: find.byKey(const ValueKey('settings.appearance.mode')),
              matching: find.byType(Text),
            )
            .at(mode),
      );
      await tap(find.byKey(ValueKey('settings.appearance.accent.$accent')));
      await back();
    }

    Future<void> screens({required bool importSample}) async {
      await shot('library');
      await tap(find.byIcon(Icons.add));
      await shot('import-sheet');
      if (importSample) {
        await tap(find.byIcon(Icons.science_outlined));
        await settle(4000);
      } else {
        await tap(find.byIcon(Icons.link));
        await shot('dialog-import-url');
        await tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextButton),
          ),
        );
      }
      await shot('library-with-app');
      await tap(find.byIcon(Icons.info_outline));
      await shot('app-details');
      await tap(find.byIcon(Icons.edit_outlined));
      await shot('dialog-rename');
      await tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextButton),
        ),
      );
      await tap(find.byIcon(Icons.delete_outline));
      await shot('dialog-delete');
      await tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextButton),
        ),
      );
      await tap(find.byIcon(Icons.play_arrow));
      await settle(20000);
      await shot('runner');
      await back();
      await back();
      await openSettings();
      await shot('settings');
      await tap(find.byKey(const ValueKey('settings.appearance.language')));
      await shot('language-menu');
      await dismiss();
      await tester.drag(find.byType(ListView).last, const Offset(0, -900));
      await settle();
      await tap(find.byIcon(Icons.terminal));
      await settle(20000);
      await shot('webr-console');
      await back();
      await back();
    }

    await setLanguage('English');
    await setLook(1, 'coderBlue');
    await screens(importSample: true);
    await setLook(2, 'yellow');
    await openSettings();
    await shot('dark-yellow-settings');
    await back();
    await tap(find.byIcon(Icons.add));
    await shot('dark-yellow-import-sheet');
    await dismiss();
    await setLook(1, 'orange');
    await shot('light-orange-library');

    await setLanguage('Deutsch');
    lang = 'de';
    n = 0;
    await setLook(1, 'coderBlue');
    await screens(importSample: false);
    await setLook(2, 'purple');
    await shot('dark-purple-library');
    await setLook(0, 'coderBlue');
  });
}
