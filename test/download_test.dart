import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vitrine/features/import/download.dart';

void main() {
  final url = Uri.parse('https://example.test/app.zip');

  test('receives a bounded chunked download', () async {
    final client = MockClient.streaming(
      (_, _) async => http.StreamedResponse(
        Stream.fromIterable([
          [1, 2],
          [3],
        ]),
        200,
      ),
    );
    expect(await downloadZip(url, maxBytes: 3, client: client), [1, 2, 3]);
  });

  test('rejects declared and actual oversize responses', () async {
    for (final length in [null, 100]) {
      final client = MockClient.streaming(
        (_, _) async => http.StreamedResponse(
          Stream.fromIterable([
            [1, 2],
            [3, 4],
          ]),
          200,
          contentLength: length,
        ),
      );
      await expectLater(
        downloadZip(url, maxBytes: 3, client: client),
        throwsFormatException,
      );
    }
  });

  test('HTTP failure and invalid schemes do not reach the importer', () async {
    final client = MockClient.streaming(
      (_, _) async => http.StreamedResponse(const Stream.empty(), 403),
    );
    await expectLater(
      downloadZip(url, maxBytes: 3, client: client),
      throwsFormatException,
    );
    await expectLater(
      downloadZip(Uri.parse('file:///secret'), maxBytes: 3, client: client),
      throwsFormatException,
    );
  });

  test('stalled responses time out', () async {
    final controller = StreamController<List<int>>();
    final client = MockClient.streaming(
      (_, _) async => http.StreamedResponse(controller.stream, 200),
    );
    await expectLater(
      downloadZip(
        url,
        maxBytes: 3,
        client: client,
        timeout: const Duration(milliseconds: 10),
      ),
      throwsA(isA<TimeoutException>()),
    );
    await controller.close();
  });
}
