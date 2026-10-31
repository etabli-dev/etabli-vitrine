import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitrine/data/models/resolution_status.dart';
import 'package:vitrine/data/models/shiny_app.dart';
import 'package:vitrine/data/models/source_type.dart';
import 'package:vitrine/data/repositories/library_repository.dart';
import 'package:vitrine/features/runner/shinylive_runner_page.dart';
import 'package:vitrine/runtime/staging_service.dart';

class _FailingMetadata implements LibraryRepository {
  @override
  Future<void> touchLastRun(String id, DateTime when) async {
    throw StateError('Injected metadata write failure');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _SocketObserver extends IOOverrides {
  final ports = <int>[];

  @override
  Future<ServerSocket> serverSocketBind(
    dynamic address,
    int port, {
    int backlog = 0,
    bool v6Only = false,
    bool shared = false,
  }) async {
    final socket = await super.serverSocketBind(
      address,
      port,
      backlog: backlog,
      v6Only: v6Only,
      shared: shared,
    );
    ports.add(socket.port);
    return socket;
  }
}

void main() {
  late Directory support;
  late StagingService staging;
  setUp(() async {
    support = await Directory.systemTemp.createTemp('vitrine-runner-');
    staging = StagingService(supportDirectory: support);
    await staging.writeStagedFile(
      'sample',
      'index.html',
      '<p>Sample</p>'.codeUnits,
    );
  });
  tearDown(() => support.delete(recursive: true));
  testWidgets('failed last-run write releases the actual runner socket', (
    tester,
  ) async {
    final sockets = _SocketObserver();
    await IOOverrides.runWithIOOverrides(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stagingServiceProvider.overrideWithValue(staging),
            libraryRepositoryProvider.overrideWithValue(_FailingMetadata()),
          ],
          child: MaterialApp(
            home: ShinyliveRunnerPage(
              app: ShinyApp(
                id: 'sample',
                name: 'Sample',
                sourceType: SourceType.shinyliveZip,
                resolutionState: ResolutionState.ready,
                stagedPath: 'sample',
                importedAt: DateTime(2026),
              ),
            ),
          ),
        ),
      );
      // Socket binding and filesystem calls need the real event loop, while
      // the widget animation clock remains controlled by the test binding.
      for (var i = 0; i < 100; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)),
        );
        await tester.pump(const Duration(milliseconds: 10));
        if (find
            .textContaining('Injected metadata write failure')
            .evaluate()
            .isNotEmpty) {
          break;
        }
      }
      expect(
        find.textContaining('Injected metadata write failure'),
        findsOneWidget,
      );
      expect(sockets.ports, hasLength(1));
      final releasedPort = sockets.ports.single;
      await tester.runAsync(() async {
        final rebound = await ServerSocket.bind(
          InternetAddress.loopbackIPv4,
          releasedPort,
        );
        await rebound.close();
      });
      await tester.pumpWidget(const SizedBox());
    }, sockets);
  });
}
