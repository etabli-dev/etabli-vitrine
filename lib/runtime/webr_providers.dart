// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'webr_runtime.dart';

/// Single long-lived WebR runtime (extraction + loopback server).
final webrRuntimeProvider = Provider<WebRRuntime>((ref) {
  final runtime = WebRRuntime();
  ref.onDispose(runtime.dispose);
  return runtime;
});

/// Resolves to the loopback base URL once the runtime is extracted + serving.
final webrBaseUriProvider = FutureProvider.autoDispose((ref) {
  // Keep the runtime alive while a consumer is mounted.
  ref.keepAlive();
  return ref.watch(webrRuntimeProvider).start();
});
