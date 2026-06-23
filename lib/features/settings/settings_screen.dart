import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../runtime/webr_runtime.dart';
import '../../theme/theme_controller.dart';
import '../../theme/tokens.dart';
import '../../widgets/bordered_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(VitrineTokens.space4),
        children: [
          Text('APPEARANCE',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: VitrineTokens.space3),
          BorderedCard(
            padding: const EdgeInsets.all(VitrineTokens.space2),
            child: RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (v) {
                if (v != null) ref.read(themeModeProvider.notifier).set(v);
              },
              child: Column(
                children: [
                  for (final m in ThemeMode.values)
                    RadioListTile<ThemeMode>(
                      value: m,
                      activeColor: VitrineTokens.accent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: VitrineTokens.space2),
                      title: Text(_label(m),
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: VitrineTokens.space5),
          Text('RUNTIME', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: VitrineTokens.space3),
          BorderedCard(
            onTap: () => context.push('/console'),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: VitrineTokens.accent),
                const SizedBox(width: VitrineTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WebR Console',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: VitrineTokens.space1),
                      Text('Offline R ${WebRRuntime.webrVersion} REPL — boot test',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: Theme.of(context).textTheme.bodySmall?.color),
              ],
            ),
          ),
          const SizedBox(height: VitrineTokens.space5),
          Text('ABOUT', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: VitrineTokens.space3),
          BorderedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Établi Vitrine',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: VitrineTokens.space1),
                Text('Offline Shiny app runner.',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _label(ThemeMode m) => switch (m) {
        ThemeMode.system => 'Auto (follow system)',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };
}
