// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../runtime/webr_runtime.dart';
import '../../theme/appearance.dart';
import '../../theme/coder_theme_vitrine.dart';
import '../../theme/coder_theme_vitrine_tokens.dart';
import '../../theme/theme_controller.dart';
import '../../widgets/bordered_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = VitrineColors.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(VitrineTokens.space4),
        children: [
          _SectionTitle(l.settingsAppearance),
          const SizedBox(height: VitrineTokens.space3),
          const BorderedCard(child: AppearanceSection()),
          const SizedBox(height: VitrineTokens.space5),
          _SectionTitle(l.settingsRuntime),
          const SizedBox(height: VitrineTokens.space3),
          BorderedCard(
            onTap: () => context.push('/console'),
            child: Row(
              children: [
                Icon(Icons.terminal, color: colors.accent),
                const SizedBox(width: VitrineTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.settingsWebrConsole, style: t.bodyMedium),
                      const SizedBox(height: VitrineTokens.space1),
                      Text(
                        l.settingsWebrConsoleHint(WebRRuntime.webrVersion),
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: t.bodySmall?.color),
              ],
            ),
          ),
          const SizedBox(height: VitrineTokens.space5),
          _SectionTitle(l.settingsAbout),
          const SizedBox(height: VitrineTokens.space3),
          BorderedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Établi Vitrine', style: t.titleMedium),
                const SizedBox(height: VitrineTokens.space1),
                Text(l.settingsAboutBody, style: t.bodySmall),
                TextButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'Établi Vitrine',
                  ),
                  child: Text(l.settingsLicenses, maxLines: 1, softWrap: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings → Appearance: the app language (menu), the mode (segmented) and the accent (swatches), the
/// same as in the other Établi apps. Everything applies at once.
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appearanceModeProvider);
    final accent = ref.watch(accentProvider);
    final language = ref.watch(appLanguageProvider);
    final l = context.l10n;
    final colors = VitrineColors.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.settingsLanguage, style: t.bodyMedium)),
            const SizedBox(width: VitrineTokens.space2),
            DropdownButton<AppLanguage>(
              key: const ValueKey('settings.appearance.language'),
              value: language,
              underline: const SizedBox.shrink(),
              dropdownColor: colors.background,
              style: t.bodyMedium,
              onChanged: (v) {
                if (v != null) ref.read(appLanguageProvider.notifier).set(v);
              },
              items: [
                for (final option in AppLanguage.values)
                  DropdownMenuItem(
                    value: option,
                    child: Text(
                      l.languageLabel(option),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: VitrineTokens.space3),
        Text(l.settingsMode, style: t.bodyMedium),
        const SizedBox(height: VitrineTokens.space2),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AppearanceMode>(
            key: const ValueKey('settings.appearance.mode'),
            showSelectedIcon: false,
            segments: [
              for (final option in AppearanceMode.values)
                ButtonSegment(
                  value: option,
                  label: Text(
                    l.modeLabel(option),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
            ],
            selected: {mode},
            onSelectionChanged: (sel) =>
                ref.read(appearanceModeProvider.notifier).set(sel.first),
          ),
        ),
        const SizedBox(height: VitrineTokens.space3),
        ExcludeSemantics(child: Text(l.settingsAccent, style: t.bodyMedium)),
        const SizedBox(height: VitrineTokens.space2),
        Wrap(
          children: [
            for (final option in AccentChoice.values)
              _Swatch(
                choice: option,
                selected: option == accent,
                label: l.accentLabel(option),
                hint: l.settingsAccent,
                onTap: () => ref.read(accentProvider.notifier).set(option),
              ),
          ],
        ),
        const SizedBox(height: VitrineTokens.space2),
        Text(l.settingsAppearanceNote, style: t.bodySmall),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.choice,
    required this.selected,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final AccentChoice choice;
  final bool selected;
  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final c = VitrineColors.of(context);
    return Semantics(
      key: ValueKey('settings.appearance.accent.${choice.name}'),
      label: label,
      hint: hint,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      excludeSemantics: true,
      onTap: onTap,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: choice.color(b),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? c.text : c.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check, size: 18, color: c.onAccent)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: Theme.of(context).textTheme.labelSmall),
  );
}
