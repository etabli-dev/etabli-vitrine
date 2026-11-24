// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appearance.dart';

/// Persisted appearance for Établi Vitrine: System/Light/Dark, the accent colour and the app language,
/// under the keys shared with the other Établi apps (appearance.dart). These are preferences, not
/// secrets, so they live in [SharedPreferences]; credentials use secure storage instead.

/// The earlier Auto/Light/Dark key of this app; its values ("system", "light", "dark") are the same as
/// [AppearanceMode]'s raw values.
const legacyThemeModeKey = 'vitrine.themeMode';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden in main()');
});

/// Moves a mode saved under the earlier key to [AppearanceKeys.mode] once; a value already there wins.
Future<void> migrateLegacyThemeMode(SharedPreferences prefs) async {
  final legacy = prefs.getString(legacyThemeModeKey);
  if (legacy == null) return;
  if (prefs.getString(AppearanceKeys.mode) == null) {
    await prefs.setString(
      AppearanceKeys.mode,
      AppearanceMode.fromStored(legacy).name,
    );
  }
  await prefs.remove(legacyThemeModeKey);
}

final appearanceModeProvider =
    NotifierProvider<AppearanceModeController, AppearanceMode>(
      AppearanceModeController.new,
    );

class AppearanceModeController extends Notifier<AppearanceMode> {
  @override
  AppearanceMode build() => AppearanceMode.fromStored(
    ref.read(sharedPrefsProvider).getString(AppearanceKeys.mode),
  );

  Future<void> set(AppearanceMode mode) async {
    state = mode;
    await ref
        .read(sharedPrefsProvider)
        .setString(AppearanceKeys.mode, mode.name);
  }
}

final accentProvider = NotifierProvider<AccentController, AccentChoice>(
  AccentController.new,
);

class AccentController extends Notifier<AccentChoice> {
  @override
  AccentChoice build() => AccentChoice.fromStored(
    ref.read(sharedPrefsProvider).getString(AppearanceKeys.accent),
  );

  Future<void> set(AccentChoice accent) async {
    state = accent;
    await ref
        .read(sharedPrefsProvider)
        .setString(AppearanceKeys.accent, accent.name);
  }
}

final appLanguageProvider =
    NotifierProvider<AppLanguageController, AppLanguage>(
      AppLanguageController.new,
    );

/// The app language (System / Deutsch / English); views switch at once.
class AppLanguageController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.fromStored(
    ref.read(sharedPrefsProvider).getString(AppearanceKeys.language),
  );

  Future<void> set(AppLanguage language) async {
    state = language;
    await ref
        .read(sharedPrefsProvider)
        .setString(AppearanceKeys.language, language.name);
  }
}
