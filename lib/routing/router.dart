import 'package:go_router/go_router.dart';

import '../data/models/shiny_app.dart';
import '../data/models/source_type.dart';
import '../features/library/app_detail_screen.dart';
import '../features/library/library_screen.dart';
import '../features/runner/shinylive_runner_page.dart';
import '../features/runner/webr_console_page.dart';
import '../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LibraryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/console',
      builder: (context, state) => const WebRConsolePage(),
    ),
    GoRoute(
      path: '/app/:id',
      builder: (context, state) =>
          AppDetailScreen(appId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/run',
      builder: (context, state) {
        final app = state.extra as ShinyApp;
        return switch (app.sourceType) {
          SourceType.shinyliveZip => ShinyliveRunnerPage(app: app),
          // Raw source (WebR), package apps and live URLs arrive in later
          // milestones; until then they fall back to the runner stub.
          _ => ShinyliveRunnerPage(app: app),
        };
      },
    ),
  ],
);
