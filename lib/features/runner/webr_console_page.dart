import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../runtime/webr_providers.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';

/// Milestone 2 surface: boots the bundled WebR runtime in an embedded WebView
/// and shows the R banner / a minimal REPL, fully offline.
class WebRConsolePage extends ConsumerWidget {
  const WebRConsolePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUri = ref.watch(webrBaseUriProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('WebR Console')),
      body: baseUri.when(
        loading: () => const _Booting(),
        error: (e, _) => _RuntimeError(message: '$e'),
        data: (uri) => _ConsoleView(baseUri: uri),
      ),
    );
  }
}

class _Booting extends StatelessWidget {
  const _Booting();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: VitrineTokens.space4),
          Text('Unpacking WebR runtime…',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RuntimeError extends StatelessWidget {
  const _RuntimeError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VitrineTokens.space5),
        child: Text('WebR failed to start:\n\n$message',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _ConsoleView extends StatefulWidget {
  const _ConsoleView({required this.baseUri});
  final Uri baseUri;

  @override
  State<_ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<_ConsoleView> {
  bool _ready = false;
  String? _status;

  @override
  Widget build(BuildContext context) {
    final colors = VitrineColors.of(context);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: VitrineTokens.space4, vertical: VitrineTokens.space2),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: Text(
            _ready ? '● R session live (offline)' : (_status ?? '○ starting…'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _ready ? VitrineTokens.accent : colors.textMuted,
                ),
          ),
        ),
        Expanded(
          child: InAppWebView(
            initialUrlRequest:
                URLRequest(url: WebUri.uri(widget.baseUri)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              transparentBackground: true,
              isInspectable: true,
              // Allow the loopback http origin inside the WebView.
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            ),
            onWebViewCreated: (controller) {
              controller.addJavaScriptHandler(
                handlerName: 'webr',
                callback: (args) {
                  if (args.isEmpty || args.first is! Map) return;
                  final msg = args.first as Map;
                  final type = msg['type'];
                  if (!mounted) return;
                  setState(() {
                    if (type == 'ready') {
                      _ready = true;
                    } else if (type == 'status') {
                      _status = '○ ${msg['data']}';
                    } else if (type == 'error') {
                      _status = '✕ ${msg['data']}';
                    }
                  });
                },
              );
            },
            onConsoleMessage: (controller, msg) {
              debugPrint('[webr-webview] ${msg.message}');
            },
          ),
        ),
      ],
    );
  }
}
